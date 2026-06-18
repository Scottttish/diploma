"""add support conversation (nullable task_id, worker_id)

Revision ID: b9e4f1a2c3d7
Revises: f3a8c9d12e45
Create Date: 2026-06-16 14:00:00.000000

"""
from typing import Sequence, Union
from alembic import op
import sqlalchemy as sa

revision: str = 'b9e4f1a2c3d7'
down_revision: Union[str, None] = 'f3a8c9d12e45'
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    # Drop the unique constraint on task_id so multiple support convs can coexist
    op.drop_index('ix_conversations_task_id', table_name='conversations')
    op.drop_constraint('conversations_task_id_key', 'conversations', type_='unique')

    # Make task_id nullable to allow support conversations (task_id = NULL)
    op.alter_column('conversations', 'task_id', nullable=True)

    # Add worker_id FK — links a support conversation to its initiating worker
    op.add_column(
        'conversations',
        sa.Column('worker_id', sa.Integer(), sa.ForeignKey('users.id', ondelete='SET NULL'), nullable=True),
    )
    op.create_index(op.f('ix_conversations_task_id'), 'conversations', ['task_id'], unique=False)
    op.create_index(op.f('ix_conversations_worker_id'), 'conversations', ['worker_id'], unique=False)


def downgrade() -> None:
    op.drop_index(op.f('ix_conversations_worker_id'), table_name='conversations')
    op.drop_index(op.f('ix_conversations_task_id'), table_name='conversations')
    op.drop_column('conversations', 'worker_id')
    op.alter_column('conversations', 'task_id', nullable=False)
    op.create_unique_constraint('conversations_task_id_key', 'conversations', ['task_id'])
    op.create_index('ix_conversations_task_id', 'conversations', ['task_id'], unique=True)
