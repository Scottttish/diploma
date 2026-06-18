from pydantic import BaseModel, EmailStr, ConfigDict
from datetime import datetime
from typing import Optional
from app.models.user import UserRole


class UserOut(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: int
    email: str
    full_name: str
    role: UserRole
    telegram_id: Optional[str]
    is_active: bool
    created_at: datetime


class UserCreate(BaseModel):
    email: EmailStr
    password: str
    full_name: str
    role: UserRole = UserRole.worker


class UserUpdate(BaseModel):
    full_name: Optional[str] = None
    role: Optional[UserRole] = None
    telegram_id: Optional[str] = None
    is_active: Optional[bool] = None


class PasswordReset(BaseModel):
    # Manager resetting another user's password - no current password required
    new_password: str


class PasswordChange(BaseModel):
    # Self-service change - current password must be verified before applying new one
    current_password: str
    new_password: str
