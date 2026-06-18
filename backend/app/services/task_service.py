from datetime import datetime, timezone, date
from fastapi import UploadFile
from sqlalchemy.orm import Session
from app.repositories.task_repo import TaskRepository
from app.repositories.task_history_repo import TaskHistoryRepository
from app.repositories.sla_rule_repo import SLARuleRepository
from app.models.task import Task, TaskStatus
from app.models.task_history import TaskHistory
from app.models.task_review import TaskReview, ReviewDecision
from app.models.task_file import TaskFile
from app.models.user import User, UserRole
from app.core.exceptions import NotFoundError, ForbiddenError, UnprocessableError
from app.schemas.task import TaskCreate, TaskUpdate, TaskStatusUpdate, AssignRequest, ReviewRequest
from app.utils.file_upload import save_upload

ALLOWED_TRANSITIONS: dict[TaskStatus, list[TaskStatus]] = {
    TaskStatus.new:         [TaskStatus.assigned],
    TaskStatus.assigned:    [TaskStatus.in_progress, TaskStatus.new],
    TaskStatus.in_progress: [TaskStatus.completed],
    TaskStatus.completed:   [TaskStatus.approved, TaskStatus.rejected],
    TaskStatus.rejected:    [TaskStatus.in_progress],
    TaskStatus.overdue:     [TaskStatus.in_progress, TaskStatus.completed],
}


class TaskService:
    def __init__(self, db: Session):
        self.db = db
        self.task_repo    = TaskRepository(db)
        self.history_repo = TaskHistoryRepository(db)
        self.sla_repo     = SLARuleRepository(db)

    def _record_history(self, task: Task, actor_id: int, old_status: str | None, comment: str | None = None) -> None:
        entry = TaskHistory(
            task_id=task.id,
            changed_by=actor_id,
            old_status=old_status,
            new_status=task.status.value,
            comment=comment,
        )
        self.history_repo.create(entry)

    def _apply_timeline_timestamp(self, task: Task, new_status: TaskStatus) -> None:
        now = datetime.now(timezone.utc)
        if new_status == TaskStatus.in_progress:
            if task.accepted_at is None:
                task.accepted_at = now
            if task.started_at is None:
                task.started_at = now
        elif new_status == TaskStatus.completed:
            task.completed_at = now

    def _auto_assign(self, task: Task) -> None:
        from app.repositories.user_repo import UserRepository
        user_repo = UserRepository(self.db)
        if task.service_type_id:
            candidates = user_repo.get_workers_by_service_type(task.service_type_id)
        else:
            candidates = user_repo.get_all_active_workers()
        if not candidates:
            return
        worker = min(candidates, key=lambda w: self.task_repo.count_active_by_worker(w.id))
        task.assigned_to = worker.id
        task.status = TaskStatus.assigned

    def create_task(self, data: TaskCreate, creator_id: int) -> Task:
        task = Task(
            title=data.title,
            description=data.description,
            priority=data.priority,
            service_type_id=data.service_type_id,
            equipment_id=data.equipment_id,
            sla_rule_id=data.sla_rule_id,
            created_by=creator_id,
            status=TaskStatus.new,
            address=data.address,
            latitude=data.latitude,
            longitude=data.longitude,
            client_name=data.client_name,
            client_phone=data.client_phone,
        )
        if data.sla_rule_id:
            sla_rule = self.sla_repo.get_by_id(data.sla_rule_id)
            if sla_rule:
                from app.services.sla_service import SLAService
                SLAService(self.db).compute_deadlines(task, sla_rule)

        self._auto_assign(task)
        self.task_repo.create(task)
        comment = "Task created and auto-assigned" if task.assigned_to else "Task created"
        self._record_history(task, actor_id=creator_id, old_status=None, comment=comment)
        if task.assigned_to:
            from app.services.notification_service import NotificationService
            NotificationService(self.db).notify_task_assigned(task)
        return task

    def list_tasks(self, user: User, skip: int = 0, limit: int = 50, status: TaskStatus | None = None) -> list[Task]:
        assigned_to = user.id if user.role == UserRole.worker else None
        return self.task_repo.get_all_filtered(status=status, assigned_to=assigned_to, skip=skip, limit=limit)

    def get_today_tasks(self, user: User) -> list[Task]:
        assigned_to = user.id if user.role == UserRole.worker else None
        return self.task_repo.get_today_tasks(assigned_to=assigned_to)

    def get_task(self, task_id: int) -> Task:
        task = self.task_repo.get_by_id(task_id)
        if not task:
            raise NotFoundError(f"Task {task_id} not found")
        return task

    def update_task(self, task_id: int, data: TaskUpdate, actor: User) -> Task:
        task = self.get_task(task_id)
        old_status = task.status.value

        if data.status and data.status != task.status:
            allowed = ALLOWED_TRANSITIONS.get(task.status, [])
            if data.status not in allowed:
                raise UnprocessableError(
                    f"Cannot move task from {task.status.value} to {data.status.value}"
                )
            self._apply_timeline_timestamp(task, data.status)
            task.status = data.status

        if data.title is not None:
            task.title = data.title
        if data.description is not None:
            task.description = data.description
        if data.priority is not None:
            task.priority = data.priority
        if data.service_type_id is not None:
            task.service_type_id = data.service_type_id
        if data.equipment_id is not None:
            task.equipment_id = data.equipment_id
        if data.address is not None:
            task.address = data.address
        if data.latitude is not None:
            task.latitude = data.latitude
        if data.longitude is not None:
            task.longitude = data.longitude

        task.updated_at = datetime.now(timezone.utc)
        self.task_repo.update(task)

        if data.status and data.status.value != old_status:
            self._record_history(task, actor_id=actor.id, old_status=old_status, comment=data.comment)
            self._fire_status_notification(task, data.status.value, actor.id)

        return task

    def update_task_status(self, task_id: int, data: TaskStatusUpdate, actor: User) -> Task:
        task = self.get_task(task_id)
        if actor.role == UserRole.worker and task.assigned_to != actor.id:
            raise ForbiddenError("Workers can only update status of their own assigned tasks")
        return self.update_task(task_id, TaskUpdate(status=data.status), actor=actor)

    def assign_task(self, task_id: int, worker_id: int, actor: User) -> Task:
        task = self.get_task(task_id)
        old_status = task.status.value

        task.assigned_to = worker_id
        task.status      = TaskStatus.assigned
        task.updated_at  = datetime.now(timezone.utc)
        self.task_repo.update(task)
        self._record_history(task, actor_id=actor.id, old_status=old_status, comment=f"Assigned to worker {worker_id}")

        from app.services.notification_service import NotificationService
        NotificationService(self.db).notify_task_assigned(task)
        return task

    def upload_file(self, task_id: int, file: UploadFile, uploader_id: int) -> TaskFile:
        task = self.get_task(task_id)
        path = save_upload(file, task_id)
        record = TaskFile(task_id=task.id, file_path=path, uploaded_by=uploader_id)
        self.db.add(record)
        self.db.commit()
        self.db.refresh(record)
        return record

    def upload_attachments(self, task_id: int, files: list[UploadFile], uploader_id: int) -> list[str]:
        task = self.get_task(task_id)
        urls = []
        for file in files:
            path = save_upload(file, task_id)
            record = TaskFile(task_id=task.id, file_path=path, uploaded_by=uploader_id)
            self.db.add(record)
            urls.append(path)
        self.db.commit()
        self.db.refresh(task)
        return task.attachment_urls

    def submit_review(self, task_id: int, data: ReviewRequest, reviewer_id: int) -> Task:
        task = self.get_task(task_id)
        if task.status != TaskStatus.completed:
            raise UnprocessableError("Can only review tasks that are in completed status")

        review = TaskReview(
            task_id=task.id,
            reviewed_by=reviewer_id,
            decision=data.decision,
            comment=data.comment,
        )
        self.db.add(review)

        old_status  = task.status.value
        task.status = TaskStatus.approved if data.decision == ReviewDecision.approved else TaskStatus.rejected
        task.updated_at = datetime.now(timezone.utc)
        self.task_repo.update(task)
        self._record_history(task, actor_id=reviewer_id, old_status=old_status, comment=data.comment)
        return task

    def _fire_status_notification(self, task: Task, new_status: str, actor_id: int) -> None:
        from app.services.notification_service import NotificationService
        notif = NotificationService(self.db)
        if task.created_by and task.created_by != actor_id:
            notif.notify_status_change(task, new_status, task.created_by)
        if task.assigned_to and task.assigned_to != actor_id and task.assigned_to != task.created_by:
            notif.notify_status_change(task, new_status, task.assigned_to)
        if new_status == TaskStatus.completed.value:
            from app.services.telegram_service import TelegramService
            TelegramService(self.db).notify_task_completed(task)
