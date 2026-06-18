from pydantic import BaseModel, ConfigDict
from typing import Optional


class EquipmentTranslationIn(BaseModel):
    lang: str
    name: str
    type_name: Optional[str] = None


class EquipmentTranslationOut(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    lang: str
    name: str
    type_name: Optional[str] = None


class EquipmentOut(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: int
    key: str
    is_active: bool
    name: str
    type: str
    location: Optional[str] = None
    service_type_id: Optional[int] = None
    translations: list[EquipmentTranslationOut] = []


class EquipmentCreate(BaseModel):
    key: str
    translations: list[EquipmentTranslationIn]
    location: Optional[str] = None
    service_type_id: Optional[int] = None


class EquipmentUpdate(BaseModel):
    key: Optional[str] = None
    is_active: Optional[bool] = None
    location: Optional[str] = None
    service_type_id: Optional[int] = None
    translations: Optional[list[EquipmentTranslationIn]] = None
