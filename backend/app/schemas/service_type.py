from pydantic import BaseModel, ConfigDict
from typing import Optional


class ServiceTypeTranslationIn(BaseModel):
    lang: str
    name: str
    description: Optional[str] = None


class ServiceTypeTranslationOut(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    lang: str
    name: str
    description: Optional[str] = None


class ServiceTypeOut(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: int
    key: str
    is_active: bool
    name: str
    description: Optional[str] = None
    translations: list[ServiceTypeTranslationOut] = []


class ServiceTypeCreate(BaseModel):
    key: str
    translations: list[ServiceTypeTranslationIn]


class ServiceTypeUpdate(BaseModel):
    key: Optional[str] = None
    is_active: Optional[bool] = None
    translations: Optional[list[ServiceTypeTranslationIn]] = None
