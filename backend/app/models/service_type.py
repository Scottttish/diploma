from sqlalchemy import Boolean, Column, Integer, String, Text
from sqlalchemy.orm import relationship
from app.models.base import Base


class ServiceType(Base):
    __tablename__ = "service_types"

    id          = Column(Integer, primary_key=True, index=True)
    key         = Column(String(128), unique=True, nullable=False)
    name        = Column(String(255), unique=True, nullable=False)
    description = Column(Text, nullable=True)
    is_active   = Column(Boolean, default=True, nullable=False)

    translations  = relationship(
        "ServiceTypeTranslation",
        back_populates="service_type",
        cascade="all, delete-orphan",
        lazy="selectin",
    )
    sla_rules     = relationship("SLARule", back_populates="service_type")
    equipment     = relationship("Equipment", back_populates="service_type")
    worker_skills = relationship("WorkerSkill", back_populates="service_type")
    tasks         = relationship("Task", back_populates="service_type")
