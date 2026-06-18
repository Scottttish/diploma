import enum
from sqlalchemy import Column, Integer, String, Boolean, Enum as SAEnum
from sqlalchemy.orm import relationship
from app.models.base import Base, TimestampMixin


class UserRole(str, enum.Enum):
    manager       = "manager"
    administrator = "administrator"
    dispatcher    = "dispatcher"
    worker        = "worker"


class User(Base, TimestampMixin):
    __tablename__ = "users"

    id              = Column(Integer, primary_key=True, index=True)
    email           = Column(String(255), unique=True, index=True, nullable=False)
    hashed_password = Column(String(255), nullable=False)
    full_name       = Column(String(255), nullable=False)
    role            = Column(SAEnum(UserRole), nullable=False, default=UserRole.worker)
    telegram_id     = Column(String(64), unique=True, nullable=True)
    is_active       = Column(Boolean, default=True, nullable=False)

    skills         = relationship("WorkerSkill", back_populates="worker", cascade="all, delete-orphan")
    assigned_tasks = relationship("Task", foreign_keys="Task.assigned_to", back_populates="assignee")
    created_tasks  = relationship("Task", foreign_keys="Task.created_by", back_populates="creator")
    notifications  = relationship("Notification", back_populates="user", cascade="all, delete-orphan")
    task_reviews   = relationship("TaskReview", back_populates="reviewer")
    task_history   = relationship("TaskHistory", back_populates="changed_by_user")
