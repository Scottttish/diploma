from fastapi import APIRouter, Depends, HTTPException, UploadFile, File, Query, status
from sqlalchemy.orm import Session
from typing import Optional, List
from app.core.database import get_db
from app.core.dependencies import get_current_user, require_roles
from app.models.user import UserRole
from app.models.task import TaskStatus
from app.services.task_service import TaskService
from app.services.scheduling_service import SchedulingService
from app.schemas.task import (
    TaskCreate, TaskUpdate, TaskStatusUpdate, TaskOut,
    AssignRequest, ReviewRequest, AutoAssignRequest,
)
from app.schemas.task_file import TaskFileOut

router = APIRouter(prefix="/tasks", tags=["Tasks"])


@router.post("/", response_model=TaskOut, status_code=201)
def create_task(
    data: TaskCreate,
    db: Session = Depends(get_db),
    user=Depends(require_roles(UserRole.dispatcher, UserRole.manager, UserRole.administrator)),
):
    return TaskService(db).create_task(data, creator_id=user.id)


@router.post("/auto-assign")
def auto_assign(
    data: AutoAssignRequest,
    db: Session = Depends(get_db),
    user=Depends(require_roles(UserRole.dispatcher, UserRole.manager, UserRole.administrator)),
):
    return SchedulingService(db).auto_assign(data.task_ids, assigner_id=user.id)


@router.get("/today", response_model=list[TaskOut])
def get_today_tasks(
    db: Session = Depends(get_db),
    user=Depends(get_current_user),
):
    return TaskService(db).get_today_tasks(user=user)


@router.get("/", response_model=list[TaskOut])
def list_tasks(
    skip: int = Query(0, ge=0),
    limit: int = Query(50, ge=1, le=200),
    page: Optional[int] = Query(None, ge=1),
    status: Optional[TaskStatus] = None,
    db: Session = Depends(get_db),
    user=Depends(get_current_user),
):
    if page is not None:
        skip = (page - 1) * limit
    return TaskService(db).list_tasks(user=user, skip=skip, limit=limit, status=status)


@router.get("/{task_id}", response_model=TaskOut)
def get_task(task_id: int, db: Session = Depends(get_db), user=Depends(get_current_user)):
    task = TaskService(db).get_task(task_id)
    # if user.role == UserRole.worker and task.assigned_to != user.id:
    #     raise HTTPException(status_code=status.HTTP_403_FORBIDDEN,
    #                         detail="Workers can only view their own assigned tasks")
    return task


@router.patch("/{task_id}/status", response_model=TaskOut)
def update_task_status(
    task_id: int,
    data: TaskStatusUpdate,
    db: Session = Depends(get_db),
    user=Depends(get_current_user),
):
    return TaskService(db).update_task_status(task_id, data, actor=user)


@router.patch("/{task_id}", response_model=TaskOut)
def update_task(
    task_id: int,
    data: TaskUpdate,
    db: Session = Depends(get_db),
    user=Depends(get_current_user),
):
    if user.role == UserRole.worker:
        task = TaskService(db).get_task(task_id)
        if task.assigned_to != user.id:
            raise HTTPException(status_code=status.HTTP_403_FORBIDDEN,
                                detail="Workers can only update their own assigned tasks")
        data = TaskUpdate(status=data.status, comment=data.comment)
    return TaskService(db).update_task(task_id, data, actor=user)


@router.post("/{task_id}/assign", response_model=TaskOut)
def assign_task(
    task_id: int,
    data: AssignRequest,
    db: Session = Depends(get_db),
    user=Depends(require_roles(UserRole.dispatcher, UserRole.manager, UserRole.administrator)),
):
    return TaskService(db).assign_task(task_id, worker_id=data.worker_id, actor=user)


@router.post("/{task_id}/files", response_model=TaskFileOut, status_code=201)
def upload_file(
    task_id: int,
    file: UploadFile = File(...),
    db: Session = Depends(get_db),
    user=Depends(get_current_user),
):
    if user.role == UserRole.worker:
        task = TaskService(db).get_task(task_id)
        if task.assigned_to != user.id:
            raise HTTPException(status_code=status.HTTP_403_FORBIDDEN,
                                detail="Workers can only upload files to their own tasks")
    return TaskService(db).upload_file(task_id, file, uploader_id=user.id)


@router.post("/{task_id}/attachments", response_model=list[str], status_code=201)
def upload_attachments(
    task_id: int,
    files: List[UploadFile] = File(...),
    db: Session = Depends(get_db),
    user=Depends(get_current_user),
):
    if user.role == UserRole.worker:
        task = TaskService(db).get_task(task_id)
        if task.assigned_to != user.id:
            raise HTTPException(status_code=status.HTTP_403_FORBIDDEN,
                                detail="Workers can only upload to their own tasks")
    return TaskService(db).upload_attachments(task_id, files, uploader_id=user.id)


@router.post("/{task_id}/review", response_model=TaskOut)
def review_task(
    task_id: int,
    data: ReviewRequest,
    db: Session = Depends(get_db),
    user=Depends(require_roles(UserRole.manager, UserRole.administrator)),
):
    return TaskService(db).submit_review(task_id, data, reviewer_id=user.id)
