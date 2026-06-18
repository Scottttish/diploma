from fastapi import APIRouter, Depends, Query
from sqlalchemy.orm import Session
from app.core.database import get_db
from app.core.dependencies import get_current_user, require_roles
from app.models.user import UserRole
from app.repositories.notification_repo import NotificationRepository
from app.services.notification_service import NotificationService
from app.schemas.notification import NotificationOut, NotificationSendRequest

router = APIRouter(prefix="/notifications", tags=["Notifications"])


@router.get("/", response_model=list[NotificationOut])
def list_notifications(
    unread_only: bool = Query(False),
    db: Session = Depends(get_db),
    user=Depends(get_current_user),
):
    return NotificationRepository(db).get_for_user(user.id, unread_only=unread_only)


@router.post("/send", response_model=NotificationOut, status_code=201)
def send_notification(
    data: NotificationSendRequest,
    db: Session = Depends(get_db),
    user=Depends(require_roles(UserRole.administrator, UserRole.manager)),
):
    return NotificationService(db).notify(data.user_id, data.title, data.message, data.type)


@router.post("/mark-read")
def mark_all_read(db: Session = Depends(get_db), user=Depends(get_current_user)):
    NotificationRepository(db).mark_all_read(user.id)
    return {"detail": "All notifications marked as read"}
