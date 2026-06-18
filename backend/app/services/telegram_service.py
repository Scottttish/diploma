from typing import Optional
from sqlalchemy.orm import Session
from app.repositories.client_repo import ClientRepository
from app.repositories.task_repo import TaskRepository
from app.models.client import Client
from app.models.task import Task
from app.core.config import settings
from app.core.exceptions import NotFoundError
from app.schemas.task import TaskCreate


class TelegramService:
    def __init__(self, db: Session):
        self.db          = db
        self.client_repo = ClientRepository(db)
        self.task_repo   = TaskRepository(db)

    def get_or_create_client(self, telegram_id: str, full_name: str, phone: Optional[str] = None) -> Client:
        client = self.client_repo.get_by_telegram_id(telegram_id)
        if not client:
            client = Client(telegram_id=telegram_id, full_name=full_name, phone=phone)
            self.client_repo.create(client)
        return client

    def handle_task_request(self, telegram_id: str, title: str, description: Optional[str], service_type_id: Optional[int]) -> Task:
        client = self.client_repo.get_by_telegram_id(telegram_id)
        if not client:
            raise NotFoundError(f"No client registered for telegram_id {telegram_id}. Please register first.")

        from app.services.task_service import TaskService
        data = TaskCreate(
            title=title,
            description=description,
            service_type_id=service_type_id,
            priority=3,
            client_name=client.full_name,
            client_phone=client.phone,
        )
        task = TaskService(self.db).create_task(data, creator_id=1)

        # link the client record (not part of TaskCreate schema)
        task.client_id = client.id
        self.task_repo.update(task)

        # self.send_message(telegram_id, f"Your request has been received. Task #{task.id} created.")
        return task

    def get_client_tasks(self, telegram_id: str) -> list[Task]:
        client = self.client_repo.get_by_telegram_id(telegram_id)
        if not client:
            raise NotFoundError(f"Client with telegram_id {telegram_id} not found")
        return self.task_repo.get_by_client_id(client.id)

    def get_task(self, task_id: int) -> Task:
        task = self.task_repo.get_by_id(task_id)
        if not task:
            raise NotFoundError(f"Task with id {task_id} not found")
        return task

    def send_message(self, telegram_id: str, text: str) -> None:
        if not settings.TELEGRAM_BOT_TOKEN:
            return
        try:
            import httpx
            url = f"https://api.telegram.org/bot{settings.TELEGRAM_BOT_TOKEN}/sendMessage"
            httpx.post(url, json={"chat_id": telegram_id, "text": text}, timeout=5)
        except Exception:
            pass

    def send_photo(self, telegram_id: str, caption: str, file_path: str) -> None:
        if not settings.TELEGRAM_BOT_TOKEN:
            return
        try:
            import httpx
            url = f"https://api.telegram.org/bot{settings.TELEGRAM_BOT_TOKEN}/sendPhoto"
            with open(file_path, "rb") as photo:
                httpx.post(
                    url,
                    data={"chat_id": telegram_id, "caption": caption},
                    files={"photo": photo},
                    timeout=10,
                )
        except Exception:
            pass

    def notify_task_completed(self, task) -> None:
        if not task.client_id or not task.client:
            return
        telegram_id = task.client.telegram_id
        if not telegram_id:
            return

        lines = [
            f"✅ Task #{task.id} has been completed.",
            f"📋 {task.title}",
        ]
        if task.address:
            lines.append(f"📍 {task.address}")
        caption = "\n".join(lines)

        photo_path = next(
            (p for p in (task.attachment_urls or []) if p.lower().endswith((".jpg", ".jpeg", ".png", ".webp"))),
            None,
        )
        if photo_path:
            self.send_photo(telegram_id, caption, photo_path)
        else:
            self.send_message(telegram_id, caption)
