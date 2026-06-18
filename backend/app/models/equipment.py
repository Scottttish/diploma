from sqlalchemy import Boolean, Column, Integer, String, ForeignKey
from sqlalchemy.orm import relationship
from app.models.base import Base


class Equipment(Base):
    __tablename__ = "equipment"

    id              = Column(Integer, primary_key=True, index=True)
    key             = Column(String(128), unique=True, nullable=False)
    name            = Column(String(255), nullable=False)
    type            = Column(String(128), nullable=False)
    location        = Column(String(255), nullable=True)
    service_type_id = Column(Integer, ForeignKey("service_types.id"), nullable=True)
    is_active       = Column(Boolean, default=True, nullable=False)

    translations = relationship(
        "EquipmentTranslation",
        back_populates="equipment",
        cascade="all, delete-orphan",
        lazy="selectin",
    )
    service_type = relationship("ServiceType", back_populates="equipment")
    tasks        = relationship("Task", back_populates="equipment")
