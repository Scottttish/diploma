"""add client_id to tasks

Revision ID: e1f2a3b4c5d6
Revises: d5e6f7a8b9c0
Create Date: 2026-06-16 15:00:00.000000

"""
from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa


revision: str = 'e1f2a3b4c5d6'
down_revision: Union[str, None] = 'd5e6f7a8b9c0'
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    op.add_column('tasks', sa.Column('client_id', sa.Integer(), nullable=True))
    op.create_index(op.f('ix_tasks_client_id'), 'tasks', ['client_id'], unique=False)
    op.create_foreign_key(
        'fk_tasks_client_id_clients',
        'tasks', 'clients',
        ['client_id'], ['id'],
    )


def downgrade() -> None:
    op.drop_constraint('fk_tasks_client_id_clients', 'tasks', type_='foreignkey')
    op.drop_index(op.f('ix_tasks_client_id'), table_name='tasks')
    op.drop_column('tasks', 'client_id')
