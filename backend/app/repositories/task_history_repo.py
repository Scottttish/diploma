from typing import List
from sqlalchemy.orm import Session
from app.models.task_history import TaskHistory
from app.repositories.base import BaseRepository


class TaskHistoryRepository(BaseRepository[TaskHistory]):
    def __init__(self, db: Session):
        super().__init__(TaskHistory, db)

    def get_for_task(self, task_id: int) -> List[TaskHistory]:
        return (
            self.db.query(TaskHistory)
            .filter(TaskHistory.task_id == task_id)
            .order_by(TaskHistory.changed_at.asc())
            .all()
        )
