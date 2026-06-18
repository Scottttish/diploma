from sqlalchemy import Column, Integer, ForeignKey, UniqueConstraint
from sqlalchemy.orm import relationship
from app.models.base import Base


class WorkerSkill(Base):
    __tablename__ = "worker_skills"
    __table_args__ = (UniqueConstraint("worker_id", "service_type_id", name="uq_worker_service"),)

    id              = Column(Integer, primary_key=True, index=True)
    worker_id       = Column(Integer, ForeignKey("users.id", ondelete="CASCADE"), nullable=False)
    service_type_id = Column(Integer, ForeignKey("service_types.id"), nullable=False)

    worker       = relationship("User", back_populates="skills")
    service_type = relationship("ServiceType", back_populates="worker_skills")
