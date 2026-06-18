from app.tasks.celery_app import celery_app


@celery_app.task(name="app.tasks.notification_tasks.deliver_notification", bind=True, max_retries=3)
def deliver_notification(self, notification_id: int) -> None:
    from app.core.database import SessionLocal
    from app.repositories.notification_repo import NotificationRepository
    from app.repositories.user_repo import UserRepository

    db = SessionLocal()
    try:
        notif = NotificationRepository(db).get_by_id(notification_id)
        if not notif:
            return

        user = UserRepository(db).get_by_id(notif.user_id)
        if user and user.telegram_id:
            from app.services.telegram_service import TelegramService
            TelegramService(db).send_message(user.telegram_id, f"{notif.title}\n{notif.message}")

    except Exception as exc:
        raise self.retry(exc=exc, countdown=60)
    finally:
        db.close()
