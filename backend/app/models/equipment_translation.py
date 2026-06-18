from sqlalchemy import Column, Integer, String, ForeignKey, UniqueConstraint
from sqlalchemy.orm import relationship
from app.models.base import Base


class EquipmentTranslation(Base):
    __tablename__ = "equipment_translations"
    __table_args__ = (
        UniqueConstraint("equipment_id", "lang", name="uq_eqt_equipment_lang"),
    )

    id           = Column(Integer, primary_key=True, index=True)
    equipment_id = Column(
        Integer,
        ForeignKey("equipment.id", ondelete="CASCADE"),
        nullable=False,
        index=True,
    )
    lang      = Column(String(8), nullable=False)
    name      = Column(String(255), nullable=False)
    type_name = Column(String(128), nullable=True)

    equipment = relationship("Equipment", back_populates="translations")
