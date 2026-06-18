from typing import Optional, List
from sqlalchemy.orm import Session
from app.models.user import User, UserRole
from app.models.worker_skill import WorkerSkill
from app.repositories.base import BaseRepository


class UserRepository(BaseRepository[User]):
    def __init__(self, db: Session):
        super().__init__(User, db)

    def get_by_email(self, email: str) -> Optional[User]:
        return self.db.query(User).filter(User.email == email).first()

    def get_by_telegram_id(self, telegram_id: str) -> Optional[User]:
        return self.db.query(User).filter(User.telegram_id == telegram_id).first()

    def get_workers_by_service_type(self, service_type_id: int) -> List[User]:
        # only pull workers who are active and actually have the skill we need
        return (
            self.db.query(User)
            .join(WorkerSkill, WorkerSkill.worker_id == User.id)
            .filter(
                WorkerSkill.service_type_id == service_type_id,
                User.role == UserRole.worker,
                User.is_active == True,
            )
            .all()
        )

    def get_all_active_workers(self) -> List[User]:
        return (
            self.db.query(User)
            .filter(User.role == UserRole.worker, User.is_active == True)
            .all()
        )
