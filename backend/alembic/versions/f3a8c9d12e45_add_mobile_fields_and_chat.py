"""add mobile fields and chat system

Revision ID: f3a8c9d12e45
Revises: 6c221e6261bc
Create Date: 2026-06-16 12:00:00.000000

"""
from typing import Sequence, Union
from alembic import op
import sqlalchemy as sa

revision: str = 'f3a8c9d12e45'
down_revision: Union[str, None] = '6c221e6261bc'
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    # Add mobile-facing columns to tasks
    op.add_column('tasks', sa.Column('address', sa.String(512), nullable=True))
    op.add_column('tasks', sa.Column('latitude', sa.Float(), nullable=True))
    op.add_column('tasks', sa.Column('longitude', sa.Float(), nullable=True))
    op.add_column('tasks', sa.Column('client_name', sa.String(255), nullable=True))
    op.add_column('tasks', sa.Column('client_phone', sa.String(50), nullable=True))
    op.add_column('tasks', sa.Column('accepted_at', sa.DateTime(timezone=True), nullable=True))
    op.add_column('tasks', sa.Column('started_at', sa.DateTime(timezone=True), nullable=True))
    op.add_column('tasks', sa.Column('completed_at', sa.DateTime(timezone=True), nullable=True))

    # Create conversations table
    op.create_table(
        'conversations',
        sa.Column('id', sa.Integer(), nullable=False),
        sa.Column('task_id', sa.Integer(), sa.ForeignKey('tasks.id', ondelete='CASCADE'), nullable=False),
        sa.Column('created_at', sa.DateTime(timezone=True), nullable=False),
        sa.PrimaryKeyConstraint('id'),
        sa.UniqueConstraint('task_id'),
    )
    op.create_index(op.f('ix_conversations_id'), 'conversations', ['id'], unique=False)
    op.create_index(op.f('ix_conversations_task_id'), 'conversations', ['task_id'], unique=True)

    # Create messages table
    op.create_table(
        'messages',
        sa.Column('id', sa.Integer(), nullable=False),
        sa.Column('conversation_id', sa.Integer(), sa.ForeignKey('conversations.id', ondelete='CASCADE'), nullable=False),
        sa.Column('sender_type', sa.Enum('worker', 'client', 'dispatcher', name='sendertype'), nullable=False),
        sa.Column('message_text', sa.Text(), nullable=False),
        sa.Column('sent_at', sa.DateTime(timezone=True), nullable=False),
        sa.PrimaryKeyConstraint('id'),
    )
    op.create_index(op.f('ix_messages_id'), 'messages', ['id'], unique=False)
    op.create_index(op.f('ix_messages_conversation_id'), 'messages', ['conversation_id'], unique=False)
    op.create_index(op.f('ix_messages_sent_at'), 'messages', ['sent_at'], unique=False)


def downgrade() -> None:
    op.drop_index(op.f('ix_messages_sent_at'), table_name='messages')
    op.drop_index(op.f('ix_messages_conversation_id'), table_name='messages')
    op.drop_index(op.f('ix_messages_id'), table_name='messages')
    op.drop_table('messages')
    op.drop_index(op.f('ix_conversations_task_id'), table_name='conversations')
    op.drop_index(op.f('ix_conversations_id'), table_name='conversations')
    op.drop_table('conversations')
    op.drop_column('tasks', 'completed_at')
    op.drop_column('tasks', 'started_at')
    op.drop_column('tasks', 'accepted_at')
    op.drop_column('tasks', 'client_phone')
    op.drop_column('tasks', 'client_name')
    op.drop_column('tasks', 'longitude')
    op.drop_column('tasks', 'latitude')
    op.drop_column('tasks', 'address')
