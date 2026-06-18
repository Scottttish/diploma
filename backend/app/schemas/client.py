from pydantic import BaseModel, ConfigDict
from datetime import datetime
from typing import Optional


class ClientOut(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: int
    telegram_id: str
    full_name: str
    phone: Optional[str]
    created_at: datetime


class ClientCreate(BaseModel):
    telegram_id: str
    full_name: str
    phone: Optional[str] = None
