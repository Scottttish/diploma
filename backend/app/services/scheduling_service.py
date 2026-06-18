from datetime import datetime, timezone
from typing import Optional
from sqlalchemy.orm import Session
from app.repositories.task_repo import TaskRepository
from app.repositories.user_repo import UserRepository
from app.models.task import Task, TaskStatus
from app.models.task_history import TaskHistory
from app.models.user import User


class SchedulingService:
    def __init__(self, db: Session):
        self.db        = db
        self.task_repo = TaskRepository(db)
        self.user_repo = UserRepository(db)

    def auto_assign(self, task_ids: list[int], assigner_id: int) -> list[dict]:
        tasks = [self.task_repo.get_by_id(tid) for tid in task_ids]
        tasks = [t for t in tasks if t and t.status == TaskStatus.new]

        # process highest priority (lowest int value) and earliest deadline first
        tasks.sort(key=lambda t: (
            t.priority,
            t.reaction_deadline or datetime.max.replace(tzinfo=timezone.utc),
        ))

        results = []
        for task in tasks:
            best_worker = self._pick_best_worker(task)
            if best_worker is None:
                results.append({"task_id": task.id, "assigned_to": None, "reason": "no eligible worker found"})
                continue

            old_status       = task.status.value
            task.assigned_to = best_worker.id
            task.status      = TaskStatus.assigned
            task.updated_at  = datetime.now(timezone.utc)
            self.task_repo.update(task)

            history = TaskHistory(
                task_id=task.id,
                changed_by=assigner_id,
                old_status=old_status,
                new_status=TaskStatus.assigned.value,
                comment=f"Auto-assigned to worker {best_worker.id} by scheduler",
            )
            self.db.add(history)
            self.db.commit()

            from app.services.notification_service import NotificationService
            NotificationService(self.db).notify_task_assigned(task)

            results.append({"task_id": task.id, "assigned_to": best_worker.id})

        return results

    def _pick_best_worker(self, task: Task) -> Optional[User]:
        if task.service_type_id:
            candidates = self.user_repo.get_workers_by_service_type(task.service_type_id)
        else:
            candidates = self.user_repo.get_all_active_workers()

        if not candidates:
            return None

        scored = [(w, self._score_worker(w, task)) for w in candidates]
        scored.sort(key=lambda x: x[1], reverse=True)
        return scored[0][0]

    def _score_worker(self, worker: User, task: Task) -> float:
        active_count = self.task_repo.count_active_by_worker(worker.id)
        score = -active_count * 10.0

        if task.service_type_id:
            experience_count = self._count_completions_by_service_type(worker.id, task.service_type_id)
            score += min(experience_count, 5) * 1.0

        return score

    def _count_completions_by_service_type(self, worker_id: int, service_type_id: int) -> int:
        return (
            self.db.query(Task)
            .filter(
                Task.assigned_to == worker_id,
                Task.service_type_id == service_type_id,
                Task.status == TaskStatus.completed,
            )
            .count()
        )
