from typing import List, Optional
from sqlalchemy.orm import Session
from app.models.service_type import ServiceType
from app.models.service_type_translation import ServiceTypeTranslation
from app.repositories.base import BaseRepository


class ServiceTypeRepository(BaseRepository[ServiceType]):
    def __init__(self, db: Session):
        super().__init__(ServiceType, db)

    def get_by_name(self, name: str) -> Optional[ServiceType]:
        return self.db.query(ServiceType).filter(ServiceType.name == name).first()

    def get_by_key(self, key: str) -> Optional[ServiceType]:
        return self.db.query(ServiceType).filter(ServiceType.key == key).first()

    def get_all_active(self, skip: int = 0, limit: int = 200) -> List[ServiceType]:
        return (
            self.db.query(ServiceType)
            .filter(ServiceType.is_active == True)
            .offset(skip)
            .limit(limit)
            .all()
        )

    def upsert_translation(
        self,
        service_type_id: int,
        lang: str,
        name: str,
        description: Optional[str],
    ) -> ServiceTypeTranslation:
        existing = (
            self.db.query(ServiceTypeTranslation)
            .filter_by(service_type_id=service_type_id, lang=lang)
            .first()
        )
        if existing:
            existing.name = name
            existing.description = description
        else:
            existing = ServiceTypeTranslation(
                service_type_id=service_type_id,
                lang=lang,
                name=name,
                description=description,
            )
            self.db.add(existing)
        self.db.commit()
        self.db.refresh(existing)
        return existing
