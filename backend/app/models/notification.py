import enum
from sqlalchemy import Column, Integer, String, Text, Boolean, DateTime, ForeignKey, Enum as SAEnum
from sqlalchemy.orm import relationship
from datetime import datetime, timezone
from app.models.base import Base


class NotificationType(str, enum.Enum):
    new_task       = "new_task"
    task_assigned  = "task_assigned"
    status_changed = "status_changed"
    task_finished  = "task_finished"
    sla_breached   = "sla_breached"


class Notification(Base):
    __tablename__ = "notifications"

    id         = Column(Integer, primary_key=True, index=True)
    user_id    = Column(Integer, ForeignKey("users.id", ondelete="CASCADE"), nullable=False, index=True)
    title      = Column(String(512), nullable=False)
    message    = Column(Text, nullable=False)
    type       = Column(SAEnum(NotificationType), nullable=False)
    is_read    = Column(Boolean, default=False, nullable=False)
    created_at = Column(
        DateTime(timezone=True),
        default=lambda: datetime.now(timezone.utc),
        nullable=False,
    )

    user = relationship("User", back_populates="notifications")
