from datetime import datetime, timezone, timedelta
from sqlalchemy.orm import Session
from app.repositories.task_repo import TaskRepository
from app.models.task import Task, TaskStatus
from app.models.sla_rule import SLARule


class SLAService:
    def __init__(self, db: Session):
        self.task_repo = TaskRepository(db)

    def compute_deadlines(self, task: Task, sla_rule: SLARule) -> Task:
        now = datetime.now(timezone.utc)
        task.reaction_deadline   = now + timedelta(minutes=sla_rule.reaction_minutes)
        task.completion_deadline = now + timedelta(minutes=sla_rule.completion_minutes)
        task.deadline            = task.completion_deadline
        return task

    def mark_overdue_tasks(self) -> int:
        now = datetime.now(timezone.utc)
        candidates = self.task_repo.get_overdue_candidates(now)
        count = 0
        for task in candidates:
            task.status = TaskStatus.overdue
            self.task_repo.update(task)
            count += 1
        return count
