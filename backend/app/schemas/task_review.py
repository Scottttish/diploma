from pydantic import BaseModel, ConfigDict
from datetime import datetime
from typing import Optional
from app.models.task_review import ReviewDecision


class TaskReviewOut(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: int
    task_id: int
    reviewed_by: int
    decision: ReviewDecision
    comment: Optional[str]
    reviewed_at: datetime
