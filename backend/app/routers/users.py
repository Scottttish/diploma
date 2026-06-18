from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from app.core.database import get_db
from app.core.dependencies import get_current_user, require_roles
from app.core.exceptions import NotFoundError, ConflictError
from app.models.user import UserRole, User
from app.repositories.user_repo import UserRepository
from app.core.security import hash_password, verify_password
from app.schemas.user import UserOut, UserCreate, UserUpdate, PasswordReset, PasswordChange

router = APIRouter(prefix="/users", tags=["Users"])


@router.get("/", response_model=list[UserOut])
def list_users(
    skip: int = 0,
    limit: int = 50,
    db: Session = Depends(get_db),
    user=Depends(require_roles(UserRole.manager, UserRole.dispatcher)),
):
    return UserRepository(db).get_all(skip=skip, limit=limit)


@router.post("/", response_model=UserOut, status_code=201)
def create_user(
    data: UserCreate,
    db: Session = Depends(get_db),
    user=Depends(require_roles(UserRole.manager)),
):
    repo = UserRepository(db)
    if repo.get_by_email(data.email):
        raise ConflictError("A user with this email already exists")
    new_user = User(
        email=data.email,
        hashed_password=hash_password(data.password),
        full_name=data.full_name,
        role=data.role,
    )
    return repo.create(new_user)


@router.patch("/me/password", status_code=204)
def change_my_password(
    data: PasswordChange,
    db: Session = Depends(get_db),
    user=Depends(get_current_user),
):
    if user.role == UserRole.worker:
        raise HTTPException(status_code=status.HTTP_403_FORBIDDEN,
                            detail="Workers cannot access the admin panel")
    if not verify_password(data.current_password, user.hashed_password):
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST,
                            detail="Current password is incorrect")
    user.hashed_password = hash_password(data.new_password)
    UserRepository(db).update(user)


@router.patch("/{user_id}", response_model=UserOut)
def update_user(
    user_id: int,
    data: UserUpdate,
    db: Session = Depends(get_db),
    user=Depends(require_roles(UserRole.manager)),
):
    repo   = UserRepository(db)
    target = repo.get_by_id(user_id)
    if not target:
        raise NotFoundError(f"User {user_id} not found")
    if data.full_name is not None:
        target.full_name = data.full_name
    if data.role is not None:
        target.role = data.role
    if data.telegram_id is not None:
        target.telegram_id = data.telegram_id
    if data.is_active is not None:
        target.is_active = data.is_active
    return repo.update(target)


@router.patch("/{user_id}/password", status_code=204)
def reset_user_password(
    user_id: int,
    data: PasswordReset,
    db: Session = Depends(get_db),
    user=Depends(require_roles(UserRole.manager)),
):
    # Manager can overwrite any user's password without knowing the old one
    repo   = UserRepository(db)
    target = repo.get_by_id(user_id)
    if not target:
        raise NotFoundError(f"User {user_id} not found")
    target.hashed_password = hash_password(data.new_password)
    repo.update(target)
