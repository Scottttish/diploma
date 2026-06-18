from pydantic import BaseModel, ConfigDict
from datetime import datetime
from typing import Optional


class TaskHistoryOut(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: int
    task_id: int
    changed_by: int
    old_status: Optional[str]
    new_status: str
    comment: Optional[str]
    changed_at: datetime
