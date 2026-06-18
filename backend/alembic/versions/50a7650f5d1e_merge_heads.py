"""merge heads

Revision ID: 50a7650f5d1e
Revises: a1b2c3d4e5f6, b9e4f1a2c3d7
Create Date: 2026-06-16 13:27:00.251665

"""
from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa


revision: str = '50a7650f5d1e'
down_revision: Union[str, None] = ('a1b2c3d4e5f6', 'b9e4f1a2c3d7')
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    pass


def downgrade() -> None:
    pass
