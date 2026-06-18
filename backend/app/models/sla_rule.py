from sqlalchemy import Column, Integer, ForeignKey
from sqlalchemy.orm import relationship
from app.models.base import Base


class SLARule(Base):
    __tablename__ = "sla_rules"

    id                 = Column(Integer, primary_key=True, index=True)
    service_type_id    = Column(Integer, ForeignKey("service_types.id"), nullable=False)
    priority           = Column(Integer, nullable=False)  # 1=critical, 2=high, 3=normal, 4=low
    reaction_minutes   = Column(Integer, nullable=False)
    completion_minutes = Column(Integer, nullable=False)

    service_type = relationship("ServiceType", back_populates="sla_rules")
    tasks        = relationship("Task", back_populates="sla_rule")
