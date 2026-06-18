from fastapi import APIRouter, Depends, HTTPException, status, Query
from sqlalchemy.orm import Session
from datetime import datetime, timezone
from pydantic import BaseModel, ConfigDict
from typing import Optional
from app.core.database import get_db
from app.core.dependencies import get_current_user
from app.models.conversation import Conversation
from app.models.message import Message, SenderType

router = APIRouter(prefix="/conversations", tags=["Conversations"])


class ConversationOut(BaseModel):
    model_config = ConfigDict(from_attributes=True)
    id: int
    task_id: Optional[int]
    created_at: datetime


class MessageOut(BaseModel):
    model_config = ConfigDict(from_attributes=True)
    id: int
    conversation_id: int
    sender_type: str
    message_text: str
    sent_at: datetime


class SendMessageRequest(BaseModel):
    message_text: str
    sender_type: str = "worker"


def _get_or_create_conversation(task_id: int, db: Session) -> Conversation:
    conv = db.query(Conversation).filter(Conversation.task_id == task_id).first()
    if not conv:
        conv = Conversation(task_id=task_id)
        db.add(conv)
        db.commit()
        db.refresh(conv)
    return conv


def _get_or_create_support_conversation(worker_id: int, db: Session) -> Conversation:
    conv = (
        db.query(Conversation)
        .filter(Conversation.task_id.is_(None), Conversation.worker_id == worker_id)
        .first()
    )
    if not conv:
        conv = Conversation(task_id=None, worker_id=worker_id)
        db.add(conv)
        db.commit()
        db.refresh(conv)
    return conv


@router.get("/support", response_model=ConversationOut)
def get_support_conversation(
    db: Session = Depends(get_db),
    user=Depends(get_current_user),
):
    conv = _get_or_create_support_conversation(user.id, db)
    return conv


@router.get("/worker/{worker_id}", response_model=ConversationOut)
def get_worker_support_conversation(
    worker_id: int,
    db: Session = Depends(get_db),
    user=Depends(get_current_user),
):
    return _get_or_create_support_conversation(worker_id, db)


@router.get("/", response_model=ConversationOut)
def get_conversation(
    task_id: int = Query(...),
    db: Session = Depends(get_db),
    user=Depends(get_current_user),
):
    conv = _get_or_create_conversation(task_id, db)
    return conv


@router.get("/{conversation_id}/messages", response_model=list[MessageOut])
def get_messages(
    conversation_id: int,
    db: Session = Depends(get_db),
    user=Depends(get_current_user),
):
    conv = db.query(Conversation).filter(Conversation.id == conversation_id).first()
    if not conv:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Conversation not found")
    return conv.messages


@router.post("/{conversation_id}/messages", response_model=MessageOut, status_code=201)
def send_message(
    conversation_id: int,
    data: SendMessageRequest,
    db: Session = Depends(get_db),
    user=Depends(get_current_user),
):
    conv = db.query(Conversation).filter(Conversation.id == conversation_id).first()
    if not conv:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Conversation not found")
    try:
        sender = SenderType(data.sender_type)
    except ValueError:
        sender = SenderType.worker
    msg = Message(
        conversation_id=conversation_id,
        sender_type=sender,
        message_text=data.message_text,
        sent_at=datetime.now(timezone.utc),
    )
    db.add(msg)
    db.commit()
    db.refresh(msg)

    # Relay to client Telegram only for task-specific conversations
    if sender == SenderType.worker and conv.task_id is not None:
        _relay_to_telegram(conv, data.message_text, db)

    return msg


def _relay_to_telegram(conv: Conversation, text: str, db: Session) -> None:
    try:
        from app.core.config import settings
        from app.models.task import Task
        from app.models.client import Client
        import httpx
        if not settings.TELEGRAM_BOT_TOKEN:
            return
        task = db.query(Task).filter(Task.id == conv.task_id).first()
        if not task or not task.client_name:
            return
        client = db.query(Client).filter(Client.full_name == task.client_name).first()
        if not client:
            return
        url = f"https://api.telegram.org/bot{settings.TELEGRAM_BOT_TOKEN}/sendMessage"
        httpx.post(
            url,
            json={"chat_id": client.telegram_id, "text": f"[Task {task.order_number}] Worker: {text}"},
            timeout=5,
        )
    except Exception:
        pass
