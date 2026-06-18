from pydantic import BaseModel, ConfigDict
from typing import Optional


class SLARuleOut(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: int
    service_type_id: int
    priority: int
    reaction_minutes: int
    completion_minutes: int


class SLARuleCreate(BaseModel):
    service_type_id: int
    priority: int
    reaction_minutes: int
    completion_minutes: int


class SLARuleUpdate(BaseModel):
    priority: Optional[int] = None
    reaction_minutes: Optional[int] = None
    completion_minutes: Optional[int] = None
