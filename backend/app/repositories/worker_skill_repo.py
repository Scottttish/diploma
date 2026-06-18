from typing import List, Optional
from sqlalchemy.orm import Session
from app.models.worker_skill import WorkerSkill
from app.repositories.base import BaseRepository


class WorkerSkillRepository(BaseRepository[WorkerSkill]):
    def __init__(self, db: Session):
        super().__init__(WorkerSkill, db)

    def get_for_worker(self, worker_id: int) -> List[WorkerSkill]:
        return self.db.query(WorkerSkill).filter(WorkerSkill.worker_id == worker_id).all()

    def get_for_service_type(self, service_type_id: int) -> List[WorkerSkill]:
        return self.db.query(WorkerSkill).filter(WorkerSkill.service_type_id == service_type_id).all()

    def get_by_worker_and_service(self, worker_id: int, service_type_id: int) -> Optional[WorkerSkill]:
        return (
            self.db.query(WorkerSkill)
            .filter(WorkerSkill.worker_id == worker_id, WorkerSkill.service_type_id == service_type_id)
            .first()
        )
