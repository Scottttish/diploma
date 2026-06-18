from pydantic import BaseModel


class OverviewResponse(BaseModel):
    by_status: dict[str, int]
    total: int
    overdue_count: int


class WorkerStat(BaseModel):
    worker_id: int
    full_name: str
    completed_tasks: int
    avg_completion_seconds: float


class TelegramTaskRequest(BaseModel):
    telegram_id: str
    title: str
    description: str | None = None
    service_type_id: int | None = None
