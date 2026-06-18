from app.tasks.celery_app import celery_app


@celery_app.task(name="app.tasks.sla_tasks.check_overdue")
def check_overdue() -> dict:
    from app.core.database import SessionLocal
    from app.services.sla_service import SLAService
    from app.services.notification_service import NotificationService
    from app.repositories.task_repo import TaskRepository
    from app.models.task import TaskStatus

    db = SessionLocal()
    try:
        sla_service  = SLAService(db)
        marked_count = sla_service.mark_overdue_tasks()

        notif_service = NotificationService(db)
        overdue_tasks = TaskRepository(db).get_by_status(TaskStatus.overdue)
        for task in overdue_tasks:
            notif_service.notify_sla_breach(task)

        return {"marked_overdue": marked_count}
    finally:
        db.close()
