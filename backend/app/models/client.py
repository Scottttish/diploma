from sqlalchemy import Column, Integer, String, DateTime
from datetime import datetime, timezone
from app.models.base import Base


class Client(Base):
    __tablename__ = "clients"

    id          = Column(Integer, primary_key=True, index=True)
    telegram_id = Column(String(64), unique=True, nullable=False, index=True)
    full_name   = Column(String(255), nullable=False)
    phone       = Column(String(32), nullable=True)
    created_at  = Column(
        DateTime(timezone=True),
        default=lambda: datetime.now(timezone.utc),
        nullable=False,
    )
