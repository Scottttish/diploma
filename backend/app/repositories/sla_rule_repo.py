from typing import Optional, List
from sqlalchemy.orm import Session
from app.models.sla_rule import SLARule
from app.repositories.base import BaseRepository


class SLARuleRepository(BaseRepository[SLARule]):
    def __init__(self, db: Session):
        super().__init__(SLARule, db)

    def get_by_service_and_priority(self, service_type_id: int, priority: int) -> Optional[SLARule]:
        return (
            self.db.query(SLARule)
            .filter(SLARule.service_type_id == service_type_id, SLARule.priority == priority)
            .first()
        )

    def get_by_service_type(self, service_type_id: int) -> List[SLARule]:
        return self.db.query(SLARule).filter(SLARule.service_type_id == service_type_id).all()
