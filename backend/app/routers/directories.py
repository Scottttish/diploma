from typing import Optional
from fastapi import APIRouter, Depends, Header, Query
from sqlalchemy.orm import Session
from app.core.database import get_db
from app.core.dependencies import require_roles
from app.core.exceptions import NotFoundError, ConflictError, UnprocessableError
from app.core.i18n import pick_translation, resolve_lang
from app.models.user import UserRole
from app.models.service_type import ServiceType
from app.models.sla_rule import SLARule
from app.models.equipment import Equipment
from app.models.worker_skill import WorkerSkill
from app.repositories.service_type_repo import ServiceTypeRepository
from app.repositories.sla_rule_repo import SLARuleRepository
from app.repositories.equipment_repo import EquipmentRepository
from app.repositories.worker_skill_repo import WorkerSkillRepository
from app.schemas.service_type import ServiceTypeOut, ServiceTypeCreate, ServiceTypeUpdate
from app.schemas.sla_rule import SLARuleOut, SLARuleCreate, SLARuleUpdate
from app.schemas.equipment import EquipmentOut, EquipmentCreate, EquipmentUpdate
from app.schemas.worker_skill import WorkerSkillOut, WorkerSkillCreate

router = APIRouter(prefix="/directories", tags=["Directories"])

admin_only  = require_roles(UserRole.administrator)
read_roles  = require_roles(UserRole.administrator, UserRole.manager, UserRole.dispatcher)
skill_roles = require_roles(UserRole.administrator, UserRole.manager)


def _st_dict(obj: ServiceType, lang: str) -> dict:
    t = pick_translation(obj.translations, lang)
    return {
        "id": obj.id,
        "key": obj.key,
        "is_active": obj.is_active,
        "name": t.name if t else obj.name,
        "description": t.description if t else obj.description,
        "translations": obj.translations,
    }


def _eq_dict(obj: Equipment, lang: str) -> dict:
    t = pick_translation(obj.translations, lang)
    return {
        "id": obj.id,
        "key": obj.key,
        "is_active": obj.is_active,
        "name": t.name if t else obj.name,
        "type": t.type_name if (t and t.type_name) else obj.type,
        "location": obj.location,
        "service_type_id": obj.service_type_id,
        "translations": obj.translations,
    }


# ── Service Types ────────────────────────────────────────────────────────────

@router.get("/service-types", response_model=list[ServiceTypeOut])
def list_service_types(
    lang: Optional[str] = Query(None, description="Language code: en, ru, kk"),
    accept_language: Optional[str] = Header(None, alias="Accept-Language"),
    db: Session = Depends(get_db),
    user=Depends(read_roles),
):
    resolved = resolve_lang(lang, accept_language)
    items = ServiceTypeRepository(db).get_all_active()
    return [ServiceTypeOut.model_validate(_st_dict(obj, resolved)) for obj in items]


@router.post("/service-types", response_model=ServiceTypeOut, status_code=201)
def create_service_type(
    data: ServiceTypeCreate,
    db: Session = Depends(get_db),
    user=Depends(admin_only),
):
    repo = ServiceTypeRepository(db)
    if repo.get_by_key(data.key):
        raise ConflictError(f"Service type key '{data.key}' already exists")
    en_t = next((t for t in data.translations if t.lang == "en"), None)
    if not en_t:
        raise UnprocessableError("At least one 'en' translation is required")
    obj = repo.create(ServiceType(key=data.key, name=en_t.name, description=en_t.description))
    for t in data.translations:
        repo.upsert_translation(obj.id, t.lang, t.name, t.description)
    db.refresh(obj)
    return ServiceTypeOut.model_validate(_st_dict(obj, "en"))


@router.patch("/service-types/{st_id}", response_model=ServiceTypeOut)
def update_service_type(
    st_id: int,
    data: ServiceTypeUpdate,
    lang: Optional[str] = Query(None),
    accept_language: Optional[str] = Header(None, alias="Accept-Language"),
    db: Session = Depends(get_db),
    user=Depends(admin_only),
):
    repo = ServiceTypeRepository(db)
    obj  = repo.get_by_id(st_id)
    if not obj:
        raise NotFoundError(f"ServiceType {st_id} not found")
    if data.key is not None:
        existing = repo.get_by_key(data.key)
        if existing and existing.id != st_id:
            raise ConflictError(f"Service type key '{data.key}' already exists")
        obj.key = data.key
    if data.is_active is not None:
        obj.is_active = data.is_active
    if data.translations is not None:
        for t in data.translations:
            repo.upsert_translation(obj.id, t.lang, t.name, t.description)
        en_t = next((tr for tr in data.translations if tr.lang == "en"), None)
        if en_t:
            obj.name = en_t.name
            obj.description = en_t.description
    obj = repo.update(obj)
    resolved = resolve_lang(lang, accept_language)
    return ServiceTypeOut.model_validate(_st_dict(obj, resolved))


@router.delete("/service-types/{st_id}", status_code=204)
def delete_service_type(
    st_id: int,
    db: Session = Depends(get_db),
    user=Depends(admin_only),
):
    repo = ServiceTypeRepository(db)
    obj  = repo.get_by_id(st_id)
    if not obj:
        raise NotFoundError(f"ServiceType {st_id} not found")
    if obj.tasks:
        raise ConflictError("Cannot delete: service type has associated tasks. Deactivate it instead.")
    repo.delete(obj)


# ── SLA Rules ────────────────────────────────────────────────────────────────

@router.get("/sla-rules", response_model=list[SLARuleOut])
def list_sla_rules(db: Session = Depends(get_db), user=Depends(read_roles)):
    return SLARuleRepository(db).get_all(limit=200)


@router.post("/sla-rules", response_model=SLARuleOut, status_code=201)
def create_sla_rule(data: SLARuleCreate, db: Session = Depends(get_db), user=Depends(admin_only)):
    return SLARuleRepository(db).create(
        SLARule(
            service_type_id=data.service_type_id,
            priority=data.priority,
            reaction_minutes=data.reaction_minutes,
            completion_minutes=data.completion_minutes,
        )
    )


@router.patch("/sla-rules/{rule_id}", response_model=SLARuleOut)
def update_sla_rule(rule_id: int, data: SLARuleUpdate, db: Session = Depends(get_db), user=Depends(admin_only)):
    repo = SLARuleRepository(db)
    obj  = repo.get_by_id(rule_id)
    if not obj:
        raise NotFoundError(f"SLARule {rule_id} not found")
    if data.priority is not None:
        obj.priority = data.priority
    if data.reaction_minutes is not None:
        obj.reaction_minutes = data.reaction_minutes
    if data.completion_minutes is not None:
        obj.completion_minutes = data.completion_minutes
    return repo.update(obj)


@router.delete("/sla-rules/{rule_id}", status_code=204)
def delete_sla_rule(
    rule_id: int,
    db: Session = Depends(get_db),
    user=Depends(admin_only),
):
    repo = SLARuleRepository(db)
    obj  = repo.get_by_id(rule_id)
    if not obj:
        raise NotFoundError(f"SLARule {rule_id} not found")
    repo.delete(obj)


# ── Equipment ────────────────────────────────────────────────────────────────

@router.get("/equipment", response_model=list[EquipmentOut])
def list_equipment(
    lang: Optional[str] = Query(None, description="Language code: en, ru, kk"),
    accept_language: Optional[str] = Header(None, alias="Accept-Language"),
    db: Session = Depends(get_db),
    user=Depends(read_roles),
):
    resolved = resolve_lang(lang, accept_language)
    items = EquipmentRepository(db).get_all_active()
    return [EquipmentOut.model_validate(_eq_dict(obj, resolved)) for obj in items]


@router.post("/equipment", response_model=EquipmentOut, status_code=201)
def create_equipment(
    data: EquipmentCreate,
    db: Session = Depends(get_db),
    user=Depends(admin_only),
):
    repo = EquipmentRepository(db)
    if repo.get_by_key(data.key):
        raise ConflictError(f"Equipment key '{data.key}' already exists")
    en_t = next((t for t in data.translations if t.lang == "en"), None)
    if not en_t:
        raise UnprocessableError("At least one 'en' translation is required")
    obj = repo.create(Equipment(
        key=data.key,
        name=en_t.name,
        type=en_t.type_name or "",
        location=data.location,
        service_type_id=data.service_type_id,
    ))
    for t in data.translations:
        repo.upsert_translation(obj.id, t.lang, t.name, t.type_name)
    db.refresh(obj)
    return EquipmentOut.model_validate(_eq_dict(obj, "en"))


@router.patch("/equipment/{eq_id}", response_model=EquipmentOut)
def update_equipment(
    eq_id: int,
    data: EquipmentUpdate,
    lang: Optional[str] = Query(None),
    accept_language: Optional[str] = Header(None, alias="Accept-Language"),
    db: Session = Depends(get_db),
    user=Depends(admin_only),
):
    repo = EquipmentRepository(db)
    obj  = repo.get_by_id(eq_id)
    if not obj:
        raise NotFoundError(f"Equipment {eq_id} not found")
    if data.key is not None:
        existing = repo.get_by_key(data.key)
        if existing and existing.id != eq_id:
            raise ConflictError(f"Equipment key '{data.key}' already exists")
        obj.key = data.key
    if data.is_active is not None:
        obj.is_active = data.is_active
    if data.location is not None:
        obj.location = data.location
    if data.service_type_id is not None:
        obj.service_type_id = data.service_type_id
    if data.translations is not None:
        for t in data.translations:
            repo.upsert_translation(obj.id, t.lang, t.name, t.type_name)
        en_t = next((tr for tr in data.translations if tr.lang == "en"), None)
        if en_t:
            obj.name = en_t.name
            obj.type = en_t.type_name or obj.type
    obj = repo.update(obj)
    resolved = resolve_lang(lang, accept_language)
    return EquipmentOut.model_validate(_eq_dict(obj, resolved))


@router.delete("/equipment/{eq_id}", status_code=204)
def delete_equipment(
    eq_id: int,
    db: Session = Depends(get_db),
    user=Depends(admin_only),
):
    repo = EquipmentRepository(db)
    obj  = repo.get_by_id(eq_id)
    if not obj:
        raise NotFoundError(f"Equipment {eq_id} not found")
    if obj.tasks:
        raise ConflictError("Cannot delete: equipment has associated tasks. Deactivate it instead.")
    repo.delete(obj)


# ── Worker Skills ────────────────────────────────────────────────────────────

@router.get("/worker-skills", response_model=list[WorkerSkillOut])
def list_worker_skills(db: Session = Depends(get_db), user=Depends(read_roles)):
    return WorkerSkillRepository(db).get_all(limit=500)


@router.post("/worker-skills", response_model=WorkerSkillOut, status_code=201)
def create_worker_skill(data: WorkerSkillCreate, db: Session = Depends(get_db), user=Depends(skill_roles)):
    repo      = WorkerSkillRepository(db)
    duplicate = repo.get_by_worker_and_service(data.worker_id, data.service_type_id)
    if duplicate:
        raise ConflictError("This worker already has this skill assigned")
    return repo.create(WorkerSkill(worker_id=data.worker_id, service_type_id=data.service_type_id))


@router.delete("/worker-skills/{skill_id}", status_code=204)
def delete_worker_skill(skill_id: int, db: Session = Depends(get_db), user=Depends(skill_roles)):
    repo = WorkerSkillRepository(db)
    obj  = repo.get_by_id(skill_id)
    if not obj:
        raise NotFoundError(f"WorkerSkill {skill_id} not found")
    repo.delete(obj)
