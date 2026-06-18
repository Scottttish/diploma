"""seed_initial_data

Revision ID: 6c221e6261bc
Revises: 7668f27f8e12
Create Date: 2026-06-15 23:20:10.121713

"""
from typing import Sequence, Union
from datetime import datetime, timezone

from alembic import op
import sqlalchemy as sa


revision: str = '6c221e6261bc'
down_revision: Union[str, None] = '7668f27f8e12'
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None

_SERVICE_TYPE_NAMES = [
    'Emergency Repair',
    'Scheduled Maintenance',
    'Diagnostics',
    'Installation / Setup',
    'Repair / Fix',
    'Parts Replacement',
    'Technical Consultation',
    'Equipment Relocation',
    'Software/Firmware Update',
    'Audit / Inspection',
]

_EQUIPMENT_NAMES = [
    'Boiler Unit #1',
    'Backup Generator',
    'Central HVAC Unit',
    'Passenger Elevator #1',
    'Main Electrical Panel',
    'Fire Suppression System',
    'Air Compressor',
    'UPS System',
    'Water Pump Station',
    'CCTV Control System',
]


def upgrade() -> None:
    from app.core.security import hash_password

    service_types_table = sa.table(
        'service_types',
        sa.column('id', sa.Integer),
        sa.column('name', sa.String),
        sa.column('description', sa.Text),
    )
    op.bulk_insert(service_types_table, [
        {'id': 1,  'name': 'Emergency Repair',         'description': 'Critical breakdown requiring immediate response (equipment failure, system outage)'},
        {'id': 2,  'name': 'Scheduled Maintenance',    'description': 'Regular preventive maintenance (inspection, lubrication, calibration)'},
        {'id': 3,  'name': 'Diagnostics',              'description': 'Identifying the root cause of a malfunction; no immediate repair guaranteed'},
        {'id': 4,  'name': 'Installation / Setup',     'description': 'New equipment installation, initial configuration and commissioning'},
        {'id': 5,  'name': 'Repair / Fix',             'description': 'Standard non-critical repair — part replacement, issue resolution'},
        {'id': 6,  'name': 'Parts Replacement',        'description': 'Replacement of worn or broken components, typically follows diagnostics'},
        {'id': 7,  'name': 'Technical Consultation',   'description': 'Remote or on-site technical guidance; no physical repair'},
        {'id': 8,  'name': 'Equipment Relocation',     'description': 'Moving equipment between locations including disassembly and reinstallation'},
        {'id': 9,  'name': 'Software/Firmware Update', 'description': 'Updating embedded systems or controllers with configuration verification'},
        {'id': 10, 'name': 'Audit / Inspection',       'description': 'Full technical condition check for reporting and compliance'},
    ])

    sla_rules_table = sa.table(
        'sla_rules',
        sa.column('service_type_id', sa.Integer),
        sa.column('priority', sa.Integer),
        sa.column('reaction_minutes', sa.Integer),
        sa.column('completion_minutes', sa.Integer),
    )
    # priority: 1=critical, 2=high, 3=normal, 4=low
    op.bulk_insert(sla_rules_table, [
        # 1 — Emergency Repair
        {'service_type_id': 1, 'priority': 1, 'reaction_minutes': 15,   'completion_minutes': 120},
        {'service_type_id': 1, 'priority': 2, 'reaction_minutes': 30,   'completion_minutes': 240},
        {'service_type_id': 1, 'priority': 3, 'reaction_minutes': 60,   'completion_minutes': 480},
        {'service_type_id': 1, 'priority': 4, 'reaction_minutes': 120,  'completion_minutes': 720},
        # 2 — Scheduled Maintenance
        {'service_type_id': 2, 'priority': 1, 'reaction_minutes': 240,  'completion_minutes': 1440},
        {'service_type_id': 2, 'priority': 2, 'reaction_minutes': 480,  'completion_minutes': 2880},
        {'service_type_id': 2, 'priority': 3, 'reaction_minutes': 1440, 'completion_minutes': 4320},
        {'service_type_id': 2, 'priority': 4, 'reaction_minutes': 2880, 'completion_minutes': 7200},
        # 3 — Diagnostics
        {'service_type_id': 3, 'priority': 1, 'reaction_minutes': 60,   'completion_minutes': 480},
        {'service_type_id': 3, 'priority': 2, 'reaction_minutes': 120,  'completion_minutes': 1440},
        {'service_type_id': 3, 'priority': 3, 'reaction_minutes': 480,  'completion_minutes': 2880},
        {'service_type_id': 3, 'priority': 4, 'reaction_minutes': 1440, 'completion_minutes': 4320},
        # 4 — Installation / Setup
        {'service_type_id': 4, 'priority': 1, 'reaction_minutes': 240,  'completion_minutes': 1440},
        {'service_type_id': 4, 'priority': 2, 'reaction_minutes': 480,  'completion_minutes': 2880},
        {'service_type_id': 4, 'priority': 3, 'reaction_minutes': 1440, 'completion_minutes': 7200},
        {'service_type_id': 4, 'priority': 4, 'reaction_minutes': 2880, 'completion_minutes': 14400},
        # 5 — Repair / Fix
        {'service_type_id': 5, 'priority': 1, 'reaction_minutes': 30,   'completion_minutes': 240},
        {'service_type_id': 5, 'priority': 2, 'reaction_minutes': 60,   'completion_minutes': 480},
        {'service_type_id': 5, 'priority': 3, 'reaction_minutes': 240,  'completion_minutes': 1440},
        {'service_type_id': 5, 'priority': 4, 'reaction_minutes': 480,  'completion_minutes': 2880},
        # 6 — Parts Replacement
        {'service_type_id': 6, 'priority': 1, 'reaction_minutes': 60,   'completion_minutes': 480},
        {'service_type_id': 6, 'priority': 2, 'reaction_minutes': 120,  'completion_minutes': 1440},
        {'service_type_id': 6, 'priority': 3, 'reaction_minutes': 480,  'completion_minutes': 2880},
        {'service_type_id': 6, 'priority': 4, 'reaction_minutes': 1440, 'completion_minutes': 7200},
        # 7 — Technical Consultation
        {'service_type_id': 7, 'priority': 1, 'reaction_minutes': 30,   'completion_minutes': 120},
        {'service_type_id': 7, 'priority': 2, 'reaction_minutes': 60,   'completion_minutes': 240},
        {'service_type_id': 7, 'priority': 3, 'reaction_minutes': 120,  'completion_minutes': 480},
        {'service_type_id': 7, 'priority': 4, 'reaction_minutes': 480,  'completion_minutes': 1440},
        # 8 — Equipment Relocation
        {'service_type_id': 8, 'priority': 1, 'reaction_minutes': 240,  'completion_minutes': 1440},
        {'service_type_id': 8, 'priority': 2, 'reaction_minutes': 480,  'completion_minutes': 2880},
        {'service_type_id': 8, 'priority': 3, 'reaction_minutes': 1440, 'completion_minutes': 4320},
        {'service_type_id': 8, 'priority': 4, 'reaction_minutes': 2880, 'completion_minutes': 7200},
        # 9 — Software/Firmware Update
        {'service_type_id': 9, 'priority': 1, 'reaction_minutes': 120,  'completion_minutes': 480},
        {'service_type_id': 9, 'priority': 2, 'reaction_minutes': 240,  'completion_minutes': 1440},
        {'service_type_id': 9, 'priority': 3, 'reaction_minutes': 480,  'completion_minutes': 2880},
        {'service_type_id': 9, 'priority': 4, 'reaction_minutes': 1440, 'completion_minutes': 4320},
        # 10 — Audit / Inspection
        {'service_type_id': 10, 'priority': 1, 'reaction_minutes': 240,  'completion_minutes': 1440},
        {'service_type_id': 10, 'priority': 2, 'reaction_minutes': 480,  'completion_minutes': 2880},
        {'service_type_id': 10, 'priority': 3, 'reaction_minutes': 1440, 'completion_minutes': 4320},
        {'service_type_id': 10, 'priority': 4, 'reaction_minutes': 2880, 'completion_minutes': 7200},
    ])

    equipment_table = sa.table(
        'equipment',
        sa.column('name', sa.String),
        sa.column('type', sa.String),
        sa.column('location', sa.String),
        sa.column('service_type_id', sa.Integer),
    )
    op.bulk_insert(equipment_table, [
        {'name': 'Boiler Unit #1',          'type': 'Heating',            'location': 'Boiler Room B1',  'service_type_id': 2},
        {'name': 'Backup Generator',        'type': 'Power Supply',       'location': 'Technical Room',  'service_type_id': 1},
        {'name': 'Central HVAC Unit',       'type': 'Climate Control',    'location': 'Roof',            'service_type_id': 2},
        {'name': 'Passenger Elevator #1',   'type': 'Vertical Transport', 'location': 'Main Building',   'service_type_id': 5},
        {'name': 'Main Electrical Panel',   'type': 'Electrical',         'location': 'Electrical Room', 'service_type_id': 3},
        {'name': 'Fire Suppression System', 'type': 'Safety',             'location': 'All Floors',      'service_type_id': 10},
        {'name': 'Air Compressor',          'type': 'Pneumatics',         'location': 'Workshop',        'service_type_id': 5},
        {'name': 'UPS System',              'type': 'Power Supply',       'location': 'Server Room',     'service_type_id': 3},
        {'name': 'Water Pump Station',      'type': 'Plumbing',           'location': 'Basement',        'service_type_id': 1},
        {'name': 'CCTV Control System',     'type': 'Security',           'location': 'Security Room',   'service_type_id': 9},
    ])

    now = datetime.now(timezone.utc)
    users_table = sa.table(
        'users',
        sa.column('email', sa.String),
        sa.column('hashed_password', sa.String),
        sa.column('full_name', sa.String),
        sa.column('role', sa.String),
        sa.column('is_active', sa.Boolean),
        sa.column('created_at', sa.DateTime),
        sa.column('updated_at', sa.DateTime),
    )
    op.bulk_insert(users_table, [{
        'email': 'admin@asar.kz',
        'hashed_password': hash_password('Admin1234!'),
        'full_name': 'Administrator',
        'role': 'administrator',
        'is_active': True,
        'created_at': now,
        'updated_at': now,
    }])


def downgrade() -> None:
    eq_names = ', '.join(f"'{n}'" for n in _EQUIPMENT_NAMES)
    st_names = ', '.join(f"'{n}'" for n in _SERVICE_TYPE_NAMES)

    op.execute(sa.text("DELETE FROM users WHERE email = 'admin@asar.kz'"))
    op.execute(sa.text(f"DELETE FROM equipment WHERE name IN ({eq_names})"))
    op.execute(sa.text("DELETE FROM sla_rules WHERE service_type_id IN (1,2,3,4,5,6,7,8,9,10)"))
    op.execute(sa.text(f"DELETE FROM service_types WHERE name IN ({st_names})"))
