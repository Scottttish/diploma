from sqlalchemy import Column, Integer, ForeignKey, DateTime
from sqlalchemy.orm import relationship
from datetime import datetime, timezone
from app.models.base import Base


class Conversation(Base):
    __tablename__ = "conversations"

    id         = Column(Integer, primary_key=True, index=True)
    # task_id is NULL for support conversations (worker ↔ dispatcher)
    task_id    = Column(Integer, ForeignKey("tasks.id", ondelete="CASCADE"), nullable=True, unique=False, index=True)
    worker_id  = Column(Integer, ForeignKey("users.id", ondelete="SET NULL"), nullable=True, index=True)
    created_at = Column(DateTime(timezone=True), default=lambda: datetime.now(timezone.utc), nullable=False)

    task     = relationship("Task", back_populates="conversation")
    worker   = relationship("User", foreign_keys=[worker_id])
    messages = relationship(
        "Message",
        back_populates="conversation",
        cascade="all, delete-orphan",
        order_by="Message.sent_at",
    )
