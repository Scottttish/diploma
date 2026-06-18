from pydantic import BaseModel, ConfigDict, model_validator
from datetime import datetime
from typing import Optional, Any
from app.models.task import TaskStatus
from app.models.task_review import ReviewDecision


class TaskCreate(BaseModel):
    title: str
    description: Optional[str] = None
    priority: int = 3
    service_type_id: Optional[int] = None
    equipment_id: Optional[int] = None
    sla_rule_id: Optional[int] = None
    address: Optional[str] = None
    latitude: Optional[float] = None
    longitude: Optional[float] = None
    client_name: Optional[str] = None
    client_phone: Optional[str] = None


class TaskUpdate(BaseModel):
    title: Optional[str] = None
    description: Optional[str] = None
    status: Optional[TaskStatus] = None
    priority: Optional[int] = None
    service_type_id: Optional[int] = None
    equipment_id: Optional[int] = None
    comment: Optional[str] = None
    address: Optional[str] = None
    latitude: Optional[float] = None
    longitude: Optional[float] = None


class TaskStatusUpdate(BaseModel):
    status: TaskStatus


class AssignRequest(BaseModel):
    worker_id: int


class AutoAssignRequest(BaseModel):
    task_ids: list[int]


class ReviewRequest(BaseModel):
    decision: ReviewDecision
    comment: Optional[str] = None


class TaskOut(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    # Mobile app fields
    id: int
    order_number: str
    title: str
    service_type: Optional[str] = None
    description: Optional[str] = None
    address: Optional[str] = None
    latitude: Optional[float] = None
    longitude: Optional[float] = None
    status: str
    priority: str
    client_name: Optional[str] = None
    client_phone: Optional[str] = None
    scheduled_at: datetime
    accepted_at: Optional[datetime] = None
    started_at: Optional[datetime] = None
    completed_at: Optional[datetime] = None
    attachment_urls: list[str] = []
    conversation_id: Optional[int] = None

    # Admin/backend fields kept for admin panel
    service_type_key: Optional[str] = None
    raw_status: Optional[str] = None
    raw_priority: Optional[int] = None
    sla_rule_id: Optional[int] = None
    assigned_to: Optional[int] = None
    created_by: int
    service_type_id: Optional[int] = None
    equipment_id: Optional[int] = None
    deadline: Optional[datetime] = None
    reaction_deadline: Optional[datetime] = None
    completion_deadline: Optional[datetime] = None
    created_at: datetime
    updated_at: datetime

    @model_validator(mode='before')
    @classmethod
    def from_orm_object(cls, obj: Any) -> Any:
        if isinstance(obj, dict):
            return obj
        return {
            'id': obj.id,
            'order_number': obj.order_number,
            'title': obj.title,
            'service_type': obj.service_type_name,
            'service_type_key': obj.service_type.key if obj.service_type else None,
            'description': obj.description,
            'address': obj.address,
            'latitude': obj.latitude,
            'longitude': obj.longitude,
            'status': obj.mobile_status,
            'priority': obj.mobile_priority,
            'client_name': obj.client_name,
            'client_phone': obj.client_phone,
            'scheduled_at': obj.created_at,
            'accepted_at': obj.accepted_at,
            'started_at': obj.started_at,
            'completed_at': obj.completed_at,
            'attachment_urls': obj.attachment_urls,
            'conversation_id': obj.conversation_id_val,
            'raw_status': obj.status.value,
            'raw_priority': obj.priority,
            'sla_rule_id': obj.sla_rule_id,
            'assigned_to': obj.assigned_to,
            'created_by': obj.created_by,
            'service_type_id': obj.service_type_id,
            'equipment_id': obj.equipment_id,
            'deadline': obj.deadline,
            'reaction_deadline': obj.reaction_deadline,
            'completion_deadline': obj.completion_deadline,
            'created_at': obj.created_at,
            'updated_at': obj.updated_at,
        }
