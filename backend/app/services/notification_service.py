from sqlalchemy.orm import Session
from app.repositories.notification_repo import NotificationRepository
from app.models.notification import Notification, NotificationType
from app.models.task import Task


class NotificationService:
    def __init__(self, db: Session):
        self.repo = NotificationRepository(db)

    def notify(self, user_id: int, title: str, message: str, ntype: NotificationType) -> Notification:
        n = Notification(user_id=user_id, title=title, message=message, type=ntype)
        self.repo.create(n)
        # hand delivery off to Celery so the HTTP response is not blocked by Telegram network calls
        try:
            from app.tasks.notification_tasks import deliver_notification
            deliver_notification.delay(n.id)
        except Exception:
            # if Redis is not available we still want the DB record to survive
            pass
        return n

    def notify_task_assigned(self, task: Task) -> None:
        if task.assigned_to:
            self.notify(
                user_id=task.assigned_to,
                title="New task assigned to you",
                message=f"Task #{task.id}: {task.title}",
                ntype=NotificationType.task_assigned,
            )

    def notify_status_change(self, task: Task, new_status: str, recipient_id: int) -> None:
        self.notify(
            user_id=recipient_id,
            title="Task status updated",
            message=f"Task #{task.id} is now {new_status}",
            ntype=NotificationType.status_changed,
        )

    def notify_sla_breach(self, task: Task) -> None:
        # tell the creator that their task has gone overdue
        if task.created_by:
            self.notify(
                user_id=task.created_by,
                title="SLA breached",
                message=f"Task #{task.id}: {task.title} is overdue",
                ntype=NotificationType.sla_breached,
            )
        # also let the assigned worker know if there is one
        if task.assigned_to and task.assigned_to != task.created_by:
            self.notify(
                user_id=task.assigned_to,
                title="SLA breached on your task",
                message=f"Task #{task.id}: {task.title} exceeded its deadline",
                ntype=NotificationType.sla_breached,
            )
