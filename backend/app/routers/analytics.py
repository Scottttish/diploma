from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session
from app.core.database import get_db
from app.core.dependencies import require_roles, get_current_user
from app.models.user import UserRole
from app.services.analytics_service import AnalyticsService

router = APIRouter(prefix="/analytics", tags=["Analytics"])


@router.get("/overview")
def overview(
    db: Session = Depends(get_db),
    user=Depends(require_roles(UserRole.administrator, UserRole.manager)),
):
    return AnalyticsService(db).get_overview()


@router.get("/workers")
def workers(
    db: Session = Depends(get_db),
    user=Depends(require_roles(UserRole.administrator, UserRole.manager)),
):
    return AnalyticsService(db).get_worker_stats()


@router.get("/me")
def my_stats(
    db: Session = Depends(get_db),
    user=Depends(get_current_user),
):
    return AnalyticsService(db).get_my_stats(worker_id=user.id)


@router.get("/service-types")
def service_type_stats(
    db: Session = Depends(get_db),
    user=Depends(require_roles(UserRole.administrator, UserRole.manager)),
):
    return AnalyticsService(db).get_service_type_stats()
