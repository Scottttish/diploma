from typing import List, Optional
from sqlalchemy.orm import Session
from app.models.equipment import Equipment
from app.models.equipment_translation import EquipmentTranslation
from app.repositories.base import BaseRepository


class EquipmentRepository(BaseRepository[Equipment]):
    def __init__(self, db: Session):
        super().__init__(Equipment, db)

    def get_by_service_type(self, service_type_id: int) -> List[Equipment]:
        return self.db.query(Equipment).filter(Equipment.service_type_id == service_type_id).all()

    def get_by_key(self, key: str) -> Optional[Equipment]:
        return self.db.query(Equipment).filter(Equipment.key == key).first()

    def get_all_active(self, skip: int = 0, limit: int = 200) -> List[Equipment]:
        return (
            self.db.query(Equipment)
            .filter(Equipment.is_active == True)
            .offset(skip)
            .limit(limit)
            .all()
        )

    def upsert_translation(
        self,
        equipment_id: int,
        lang: str,
        name: str,
        type_name: Optional[str],
    ) -> EquipmentTranslation:
        existing = (
            self.db.query(EquipmentTranslation)
            .filter_by(equipment_id=equipment_id, lang=lang)
            .first()
        )
        if existing:
            existing.name = name
            existing.type_name = type_name
        else:
            existing = EquipmentTranslation(
                equipment_id=equipment_id,
                lang=lang,
                name=name,
                type_name=type_name,
            )
            self.db.add(existing)
        self.db.commit()
        self.db.refresh(existing)
        return existing
