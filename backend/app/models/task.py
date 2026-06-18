import enum
from sqlalchemy import Column, Integer, String, Text, Float, DateTime, ForeignKey, Enum as SAEnum
from sqlalchemy.orm import relationship
from app.models.base import Base, TimestampMixin


class TaskStatus(str, enum.Enum):
    new         = "new"
    assigned    = "assigned"
    in_progress = "in_progress"
    completed   = "completed"
    approved    = "approved"
    rejected    = "rejected"
    overdue     = "overdue"


class TaskPriority(int, enum.Enum):
    critical = 1
    high     = 2
    normal   = 3
    low      = 4


_PRIORITY_LABELS = {1: "critical", 2: "high", 3: "normal", 4: "low"}
_STATUS_MAP = {
    "new":         "pending",
    "assigned":    "assigned",
    "in_progress": "in_progress",
    "completed":   "completed",
    "approved":    "completed",
    "rejected":    "cancelled",
    "overdue":     "in_progress",
}


class Task(Base, TimestampMixin):
    __tablename__ = "tasks"

    id                  = Column(Integer, primary_key=True, index=True)
    title               = Column(String(512), nullable=False)
    description         = Column(Text, nullable=True)
    status              = Column(SAEnum(TaskStatus), nullable=False, default=TaskStatus.new, index=True)
    priority            = Column(Integer, nullable=False, default=TaskPriority.normal)
    sla_rule_id         = Column(Integer, ForeignKey("sla_rules.id"), nullable=True)
    assigned_to         = Column(Integer, ForeignKey("users.id"), nullable=True, index=True)
    created_by          = Column(Integer, ForeignKey("users.id"), nullable=False)
    service_type_id     = Column(Integer, ForeignKey("service_types.id"), nullable=True)
    equipment_id        = Column(Integer, ForeignKey("equipment.id"), nullable=True)
    client_id           = Column(Integer, ForeignKey("clients.id"), nullable=True, index=True)
    deadline            = Column(DateTime(timezone=True), nullable=True)
    reaction_deadline   = Column(DateTime(timezone=True), nullable=True)
    completion_deadline = Column(DateTime(timezone=True), nullable=True)

    # Mobile-facing fields
    address             = Column(String(512), nullable=True)
    latitude            = Column(Float, nullable=True)
    longitude           = Column(Float, nullable=True)
    client_name         = Column(String(255), nullable=True)
    client_phone        = Column(String(50), nullable=True)
    accepted_at         = Column(DateTime(timezone=True), nullable=True)
    started_at          = Column(DateTime(timezone=True), nullable=True)
    completed_at        = Column(DateTime(timezone=True), nullable=True)

    client       = relationship("Client", foreign_keys=[client_id])
    assignee     = relationship("User", foreign_keys=[assigned_to], back_populates="assigned_tasks")
    creator      = relationship("User", foreign_keys=[created_by], back_populates="created_tasks")
    sla_rule     = relationship("SLARule", back_populates="tasks")
    service_type = relationship("ServiceType", back_populates="tasks")
    equipment    = relationship("Equipment", back_populates="tasks")
    history      = relationship(
        "TaskHistory",
        back_populates="task",
        cascade="all, delete-orphan",
        order_by="TaskHistory.changed_at",
    )
    reviews      = relationship("TaskReview", back_populates="task", cascade="all, delete-orphan")
    files        = relationship("TaskFile", back_populates="task", cascade="all, delete-orphan")
    conversation = relationship("Conversation", back_populates="task", uselist=False)

    @property
    def order_number(self) -> str:
        return f"WO-{self.id:04d}"

    @property
    def mobile_status(self) -> str:
        return _STATUS_MAP.get(self.status.value, "pending")

    @property
    def mobile_priority(self) -> str:
        return _PRIORITY_LABELS.get(self.priority, "normal")

    @property
    def service_type_name(self) -> str | None:
        if not self.service_type:
            return None
        from app.core.i18n import pick_translation
        t = pick_translation(self.service_type.translations, "en")
        return t.name if t else self.service_type.name

    @property
    def attachment_urls(self) -> list[str]:
        return [f.file_path for f in self.files] if self.files else []

    @property
    def conversation_id_val(self) -> int | None:
        return self.conversation.id if self.conversation else None
