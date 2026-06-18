from sqlalchemy import Column, Integer, String, Text, ForeignKey, UniqueConstraint
from sqlalchemy.orm import relationship
from app.models.base import Base


class ServiceTypeTranslation(Base):
    __tablename__ = "service_type_translations"
    __table_args__ = (
        UniqueConstraint("service_type_id", "lang", name="uq_stt_service_lang"),
    )

    id              = Column(Integer, primary_key=True, index=True)
    service_type_id = Column(
        Integer,
        ForeignKey("service_types.id", ondelete="CASCADE"),
        nullable=False,
        index=True,
    )
    lang        = Column(String(8), nullable=False)
    name        = Column(String(255), nullable=False)
    description = Column(Text, nullable=True)

    service_type = relationship("ServiceType", back_populates="translations")
