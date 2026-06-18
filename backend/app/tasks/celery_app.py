from celery import Celery
from celery.schedules import crontab
from app.core.config import settings

celery_app = Celery(
    "asar_worker",
    broker=settings.REDIS_URL,
    backend=settings.REDIS_URL,
    include=["app.tasks.sla_tasks", "app.tasks.notification_tasks"],
)

celery_app.conf.beat_schedule = {
    "check-overdue-every-5-minutes": {
        "task": "app.tasks.sla_tasks.check_overdue",
        "schedule": crontab(minute="*/5"),
    },
}

celery_app.conf.timezone = "UTC"
celery_app.conf.task_serializer   = "json"
celery_app.conf.result_serializer = "json"
celery_app.conf.accept_content    = ["json"]
