from typing import List, Optional
from datetime import datetime, date, timezone
from sqlalchemy import func, or_
from sqlalchemy.orm import Session
from app.models.task import Task, TaskStatus
from app.repositories.base import BaseRepository


class TaskRepository(BaseRepository[Task]):
    def __init__(self, db: Session):
        super().__init__(Task, db)

    def get_by_status(self, status: TaskStatus) -> List[Task]:
        return self.db.query(Task).filter(Task.status == status).all()

    def get_assigned_to(self, worker_id: int) -> List[Task]:
        return (
            self.db.query(Task)
            .filter(
                Task.assigned_to == worker_id,
                Task.status.in_([TaskStatus.assigned, TaskStatus.in_progress]),
            )
            .all()
        )

    def get_all_filtered(
        self,
        status: Optional[TaskStatus] = None,
        assigned_to: Optional[int] = None,
        created_by: Optional[int] = None,
        skip: int = 0,
        limit: int = 50,
    ) -> List[Task]:
        q = self.db.query(Task)
        if status:
            q = q.filter(Task.status == status)
        if assigned_to is not None:
            q = q.filter(Task.assigned_to == assigned_to)
        if created_by is not None:
            q = q.filter(Task.created_by == created_by)
        return q.order_by(Task.created_at.desc()).offset(skip).limit(limit).all()

    def get_today_tasks(self, assigned_to: Optional[int] = None) -> List[Task]:
        today = date.today()
        active_statuses = [TaskStatus.assigned, TaskStatus.in_progress]
        q = self.db.query(Task).filter(
            or_(
                Task.status.in_(active_statuses),
                func.date(Task.created_at) == today,
            )
        )
        if assigned_to is not None:
            q = q.filter(Task.assigned_to == assigned_to)
        return q.order_by(Task.created_at.asc()).all()

    def get_overdue_candidates(self, now: datetime) -> List[Task]:
        # find tasks that have blown past their deadline and are not yet in a terminal state
        terminal = [TaskStatus.completed, TaskStatus.approved, TaskStatus.rejected, TaskStatus.overdue]
        return (
            self.db.query(Task)
            .filter(
                Task.completion_deadline < now,
                Task.status.notin_(terminal),
            )
            .all()
        )

    def get_by_client_id(self, client_id: int) -> List[Task]:
        return (
            self.db.query(Task)
            .filter(Task.client_id == client_id)
            .order_by(Task.created_at.desc())
            .all()
        )

    def count_active_by_worker(self, worker_id: int) -> int:
        return (
            self.db.query(Task)
            .filter(
                Task.assigned_to == worker_id,
                Task.status.in_([TaskStatus.assigned, TaskStatus.in_progress]),
            )
            .count()
        )
