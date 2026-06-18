from typing import Optional
from fastapi import APIRouter, Depends, Header, HTTPException, Query, status
from sqlalchemy.orm import Session
from app.core.database import get_db
from app.core.config import settings
from app.core.i18n import resolve_lang
from app.services.telegram_service import TelegramService
from app.schemas.analytics import TelegramTaskRequest
from app.schemas.client import ClientCreate, ClientOut
from app.schemas.task import TaskOut
from app.repositories.service_type_repo import ServiceTypeRepository
from app.schemas.service_type import ServiceTypeOut
from app.routers.directories import _st_dict

router = APIRouter(tags=["Telegram"])


def _verify_webhook_secret(x_telegram_bot_api_secret_token: str | None = Header(default=None)) -> None:
    if settings.TELEGRAM_WEBHOOK_SECRET and x_telegram_bot_api_secret_token != settings.TELEGRAM_WEBHOOK_SECRET:
        raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail="Invalid webhook secret")


@router.post("/telegram/register", response_model=ClientOut, status_code=201)
def register_client(
    data: ClientCreate,
    db: Session = Depends(get_db),
    _=Depends(_verify_webhook_secret),
):
    svc = TelegramService(db)
    client = svc.get_or_create_client(data.telegram_id, data.full_name, data.phone)
    return client


@router.post("/telegram/request", response_model=TaskOut, status_code=201)
def telegram_request(
    data: TelegramTaskRequest,
    db: Session = Depends(get_db),
    _=Depends(_verify_webhook_secret),
):
    svc  = TelegramService(db)
    task = svc.handle_task_request(
        telegram_id=data.telegram_id,
        title=data.title,
        description=data.description,
        service_type_id=data.service_type_id,
    )
    return task


@router.get("/clients/{telegram_id}/tasks", response_model=list[TaskOut])
def client_tasks(
    telegram_id: str,
    db: Session = Depends(get_db),
    _=Depends(_verify_webhook_secret),
):
    return TelegramService(db).get_client_tasks(telegram_id)


@router.get("/telegram/service-types", response_model=list[ServiceTypeOut])
def list_service_types(
    lang: Optional[str] = Query(None, description="Language code: en, ru, kk"),
    accept_language: Optional[str] = Header(None, alias="Accept-Language"),
    db: Session = Depends(get_db),
    _=Depends(_verify_webhook_secret),
):
    resolved = resolve_lang(lang, accept_language)
    items = ServiceTypeRepository(db).get_all_active()
    return [ServiceTypeOut.model_validate(_st_dict(obj, resolved)) for obj in items]


@router.get("/telegram/tasks/{task_id}", response_model=TaskOut)
def get_telegram_task(
    task_id: int,
    db: Session = Depends(get_db),
    _=Depends(_verify_webhook_secret),
):
    return TelegramService(db).get_task(task_id)
