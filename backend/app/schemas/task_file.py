from pydantic import BaseModel, ConfigDict
from datetime import datetime


class TaskFileOut(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: int
    task_id: int
    file_path: str
    uploaded_by: int
    uploaded_at: datetime
