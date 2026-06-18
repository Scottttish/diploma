from pydantic import BaseModel, ConfigDict
from datetime import datetime
from app.models.notification import NotificationType


class NotificationOut(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: int
    user_id: int
    title: str
    message: str
    type: NotificationType
    is_read: bool
    created_at: datetime


class NotificationSendRequest(BaseModel):
    user_id: int
    title: str
    message: str
    type: NotificationType
