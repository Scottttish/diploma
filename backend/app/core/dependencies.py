from fastapi import Depends, HTTPException, status
from fastapi.security import OAuth2PasswordBearer
from sqlalchemy.orm import Session
from jose import JWTError
from app.core.database import get_db
from app.core.security import decode_token

oauth2_scheme = OAuth2PasswordBearer(tokenUrl="/auth/login")


def get_current_user(token: str = Depends(oauth2_scheme), db: Session = Depends(get_db)):
    credentials_error = HTTPException(
        status_code=status.HTTP_401_UNAUTHORIZED,
        detail="Could not validate credentials",
        headers={"WWW-Authenticate": "Bearer"},
    )
    try:
        payload = decode_token(token)
        user_id = int(payload.get("sub"))
    except (JWTError, TypeError, ValueError):
        raise credentials_error

    # we do a lazy import here to avoid a circular dependency between this module and user_repo
    from app.repositories.user_repo import UserRepository
    from app.models.user import User

    user = UserRepository(db).get_by_id(user_id)
    if user is None or not user.is_active:
        raise credentials_error
    return user


def require_roles(*roles):
    """
    Returns a FastAPI dependency that checks the current user has one of the given roles.
    Usage: Depends(require_roles(UserRole.manager, UserRole.administrator))
    """
    def guard(current_user=Depends(get_current_user)):
        from app.models.user import UserRole
        allowed = [r.value if hasattr(r, "value") else r for r in roles]
        user_role = current_user.role.value if hasattr(current_user.role, "value") else current_user.role
        if user_role not in allowed:
            raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail="Insufficient permissions")
        return current_user
    return guard
