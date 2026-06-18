from typing import Optional
from sqlalchemy.orm import Session
from app.models.client import Client
from app.repositories.base import BaseRepository


class ClientRepository(BaseRepository[Client]):
    def __init__(self, db: Session):
        super().__init__(Client, db)

    def get_by_telegram_id(self, telegram_id: str) -> Optional[Client]:
        return self.db.query(Client).filter(Client.telegram_id == telegram_id).first()
