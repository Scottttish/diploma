"""add multilingual dictionaries

Revision ID: a1b2c3d4e5f6
Revises: f3a8c9d12e45
Create Date: 2026-06-16 00:00:00.000000

Adds:
- key, is_active columns to service_types and equipment
- service_type_translations and equipment_translations tables
- Backfills keys from existing names (slug derived)
- Seeds English translations from existing name/description/type fields
"""
from alembic import op
import sqlalchemy as sa
from sqlalchemy import text

revision = 'a1b2c3d4e5f6'
down_revision = 'f3a8c9d12e45'
branch_labels = None
depends_on = None


def upgrade() -> None:
    conn = op.get_bind()

    # ── Step 1: add nullable columns first to avoid NOT NULL violations ──────
    op.add_column('service_types', sa.Column('key', sa.String(128), nullable=True))
    op.add_column('service_types', sa.Column('is_active', sa.Boolean(), nullable=False,
                                              server_default=sa.text('true')))

    op.add_column('equipment', sa.Column('key', sa.String(128), nullable=True))
    op.add_column('equipment', sa.Column('is_active', sa.Boolean(), nullable=False,
                                          server_default=sa.text('true')))

    # ── Step 2: backfill keys from names ────────────────────────────────────
    # service_types.name is UNIQUE so the derived slug is safe to be unique too
    conn.execute(text("""
        UPDATE service_types
        SET key = lower(
            regexp_replace(
                regexp_replace(name, '[^a-zA-Z0-9]+', '_', 'g'),
                '^_|_$', '', 'g'
            )
        )
        WHERE key IS NULL
    """))

    # equipment names are NOT unique — append _<id> to guarantee uniqueness
    conn.execute(text("""
        UPDATE equipment
        SET key = lower(
            regexp_replace(
                regexp_replace(name, '[^a-zA-Z0-9]+', '_', 'g'),
                '^_|_$', '', 'g'
            )
        ) || '_' || id::text
        WHERE key IS NULL
    """))

    # ── Step 3: apply NOT NULL + UNIQUE constraints on key ──────────────────
    op.alter_column('service_types', 'key', nullable=False)
    op.create_unique_constraint('uq_service_types_key', 'service_types', ['key'])

    op.alter_column('equipment', 'key', nullable=False)
    op.create_unique_constraint('uq_equipment_key', 'equipment', ['key'])

    # ── Step 4: create translation tables ───────────────────────────────────
    op.create_table(
        'service_type_translations',
        sa.Column('id', sa.Integer(), nullable=False),
        sa.Column('service_type_id', sa.Integer(), nullable=False),
        sa.Column('lang', sa.String(8), nullable=False),
        sa.Column('name', sa.String(255), nullable=False),
        sa.Column('description', sa.Text(), nullable=True),
        sa.ForeignKeyConstraint(['service_type_id'], ['service_types.id'], ondelete='CASCADE'),
        sa.PrimaryKeyConstraint('id'),
        sa.UniqueConstraint('service_type_id', 'lang', name='uq_stt_service_lang'),
    )
    op.create_index('ix_stt_service_type_id', 'service_type_translations', ['service_type_id'])

    op.create_table(
        'equipment_translations',
        sa.Column('id', sa.Integer(), nullable=False),
        sa.Column('equipment_id', sa.Integer(), nullable=False),
        sa.Column('lang', sa.String(8), nullable=False),
        sa.Column('name', sa.String(255), nullable=False),
        sa.Column('type_name', sa.String(128), nullable=True),
        sa.ForeignKeyConstraint(['equipment_id'], ['equipment.id'], ondelete='CASCADE'),
        sa.PrimaryKeyConstraint('id'),
        sa.UniqueConstraint('equipment_id', 'lang', name='uq_eqt_equipment_lang'),
    )
    op.create_index('ix_eqt_equipment_id', 'equipment_translations', ['equipment_id'])

    # ── Step 5: seed English translations from existing data (idempotent) ───
    stt = sa.table(
        'service_type_translations',
        sa.column('service_type_id', sa.Integer),
        sa.column('lang', sa.String),
        sa.column('name', sa.String),
        sa.column('description', sa.Text),
    )
    rows = conn.execute(
        text("SELECT id, name, description FROM service_types")
    ).fetchall()
    if rows:
        op.bulk_insert(stt, [
            {
                'service_type_id': r.id,
                'lang': 'en',
                'name': r.name,
                'description': r.description,
            }
            for r in rows
        ])

    eqt = sa.table(
        'equipment_translations',
        sa.column('equipment_id', sa.Integer),
        sa.column('lang', sa.String),
        sa.column('name', sa.String),
        sa.column('type_name', sa.String),
    )
    rows = conn.execute(
        text("SELECT id, name, type FROM equipment")
    ).fetchall()
    if rows:
        op.bulk_insert(eqt, [
            {
                'equipment_id': r.id,
                'lang': 'en',
                'name': r.name,
                'type_name': r.type,
            }
            for r in rows
        ])


def downgrade() -> None:
    op.drop_index('ix_eqt_equipment_id', table_name='equipment_translations')
    op.drop_table('equipment_translations')

    op.drop_index('ix_stt_service_type_id', table_name='service_type_translations')
    op.drop_table('service_type_translations')

    op.drop_constraint('uq_equipment_key', 'equipment', type_='unique')
    op.drop_column('equipment', 'is_active')
    op.drop_column('equipment', 'key')

    op.drop_constraint('uq_service_types_key', 'service_types', type_='unique')
    op.drop_column('service_types', 'is_active')
    op.drop_column('service_types', 'key')
