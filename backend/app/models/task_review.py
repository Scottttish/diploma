import enum
from sqlalchemy import Column, Integer, Text, DateTime, ForeignKey, Enum as SAEnum
from sqlalchemy.orm import relationship
from datetime import datetime, timezone
from app.models.base import Base


class ReviewDecision(str, enum.Enum):
    approved = "approved"
    rejected = "rejected"


class TaskReview(Base):
    __tablename__ = "task_reviews"

    id          = Column(Integer, primary_key=True, index=True)
    task_id     = Column(Integer, ForeignKey("tasks.id", ondelete="CASCADE"), nullable=False, index=True)
    reviewed_by = Column(Integer, ForeignKey("users.id"), nullable=False)
    decision    = Column(SAEnum(ReviewDecision), nullable=False)
    comment     = Column(Text, nullable=True)
    reviewed_at = Column(
        DateTime(timezone=True),
        default=lambda: datetime.now(timezone.utc),
        nullable=False,
    )

    task     = relationship("Task", back_populates="reviews")
    reviewer = relationship("User", back_populates="task_reviews")
