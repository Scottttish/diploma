import enum
from sqlalchemy import Column, Integer, Text, DateTime, ForeignKey, Enum as SAEnum
from sqlalchemy.orm import relationship
from datetime import datetime, timezone
from app.models.base import Base


class SenderType(str, enum.Enum):
    worker     = "worker"
    client     = "client"
    dispatcher = "dispatcher"


class Message(Base):
    __tablename__ = "messages"

    id              = Column(Integer, primary_key=True, index=True)
    conversation_id = Column(Integer, ForeignKey("conversations.id", ondelete="CASCADE"), nullable=False, index=True)
    sender_type     = Column(SAEnum(SenderType), nullable=False)
    message_text    = Column(Text, nullable=False)
    sent_at         = Column(DateTime(timezone=True), default=lambda: datetime.now(timezone.utc), nullable=False, index=True)

    conversation = relationship("Conversation", back_populates="messages")
