from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session
from app.core.database import get_db
from app.core.dependencies import require_roles
from app.models.user import UserRole
from app.repositories.client_repo import ClientRepository
from app.schemas.client import ClientOut

router = APIRouter(prefix="/clients", tags=["Clients"])


@router.get("/", response_model=list[ClientOut])
def list_clients(
    skip: int = 0,
    limit: int = 100,
    db: Session = Depends(get_db),
    user=Depends(require_roles(UserRole.manager)),
):
    return ClientRepository(db).get_all(skip=skip, limit=limit)
