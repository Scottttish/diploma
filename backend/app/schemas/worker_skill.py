from pydantic import BaseModel, ConfigDict


class WorkerSkillOut(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: int
    worker_id: int
    service_type_id: int


class WorkerSkillCreate(BaseModel):
    worker_id: int
    service_type_id: int
