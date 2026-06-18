"""seed ru and kk translations for service_type_translations and equipment_translations

Revision ID: d5e6f7a8b9c0
Revises: 50a7650f5d1e
Create Date: 2026-06-16 14:00:00.000000

"""
from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa
from sqlalchemy import text

revision: str = 'd5e6f7a8b9c0'
down_revision: Union[str, None] = '50a7650f5d1e'
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


# key (slug) → {lang: (name, description)}
_ST_TRANSLATIONS: dict[str, dict[str, tuple[str, str]]] = {
    'emergency_repair': {
        'ru': ('Аварийный ремонт',                   'Критическая поломка, требующая немедленного реагирования (отказ оборудования, сбой системы)'),
        'kk': ('Апаттық жөндеу',                     'Жедел жауап талап ететін критикалық ақаулар (жабдық істен шығуы, жүйе ақаулары)'),
    },
    'scheduled_maintenance': {
        'ru': ('Плановое техническое обслуживание',  'Регулярное профилактическое обслуживание (осмотр, смазка, калибровка)'),
        'kk': ('Жоспарлы техникалық қызмет көрсету', 'Тұрақты алдын алу жұмыстары (тексеру, майлау, калибрлеу)'),
    },
    'diagnostics': {
        'ru': ('Диагностика',                        'Определение первопричины неисправности; немедленный ремонт не гарантируется'),
        'kk': ('Диагностика',                        'Ақаулардың түпкі себебін анықтау; жедел жөндеу кепілдік берілмейді'),
    },
    'installation_setup': {
        'ru': ('Установка / Наладка',                'Монтаж нового оборудования, начальная конфигурация и ввод в эксплуатацию'),
        'kk': ('Орнату / Баптау',                    'Жаңа жабдықты орнату, бастапқы конфигурациялау және іске қосу'),
    },
    'repair_fix': {
        'ru': ('Ремонт / Устранение неисправности',  'Стандартный некритический ремонт — замена запчастей, устранение проблем'),
        'kk': ('Жөндеу / Түзету',                    'Стандартты сыни емес жөндеу — бөлшектерді ауыстыру, мәселелерді шешу'),
    },
    'parts_replacement': {
        'ru': ('Замена деталей',                     'Замена изношенных или сломанных компонентов, как правило после диагностики'),
        'kk': ('Бөлшектерді ауыстыру',               'Тозған немесе сынған компоненттерді ауыстыру, әдетте диагностикадан кейін'),
    },
    'technical_consultation': {
        'ru': ('Техническая консультация',           'Удалённое или выездное техническое сопровождение; без физического ремонта'),
        'kk': ('Техникалық кеңес беру',              'Қашықтан немесе орындағы техникалық нұсқаулық; физикалық жөндеусіз'),
    },
    'equipment_relocation': {
        'ru': ('Перемещение оборудования',           'Перенос оборудования между объектами с демонтажем и повторной установкой'),
        'kk': ('Жабдықты ауыстыру',                  'Жабдықты бөлшектеп, қайта орнатып басқа орынға тасымалдау'),
    },
    'software_firmware_update': {
        'ru': ('Обновление ПО/прошивки',             'Обновление встроенных систем или контроллеров с проверкой конфигурации'),
        'kk': ('Бағдарламалық/микробағдарлама жаңартуы', 'Конфигурацияны тексерумен енгізілген жүйелерді немесе контроллерлерді жаңарту'),
    },
    'audit_inspection': {
        'ru': ('Аудит / Проверка',                   'Полная проверка технического состояния для отчётности и соответствия требованиям'),
        'kk': ('Аудит / Тексеру',                    'Есептілік пен сәйкестік үшін толық техникалық жай-күй тексеруі'),
    },
}

# equipment English name → {lang: (translated_name, translated_type_name)}
_EQ_TRANSLATIONS: dict[str, dict[str, tuple[str, str]]] = {
    'Boiler Unit #1': {
        'ru': ('Котельный агрегат №1',                   'Отопление'),
        'kk': ('Қазандық агрегат №1',                   'Жылыту'),
    },
    'Backup Generator': {
        'ru': ('Резервный генератор',                    'Электроснабжение'),
        'kk': ('Резервтік генератор',                    'Электрмен қамту'),
    },
    'Central HVAC Unit': {
        'ru': ('Центральная система ОВК',                'Климат-контроль'),
        'kk': ('Орталық ОЖЖ жүйесі',                    'Климаттық бақылау'),
    },
    'Passenger Elevator #1': {
        'ru': ('Пассажирский лифт №1',                   'Вертикальный транспорт'),
        'kk': ('Жолаушылар лифті №1',                   'Тік тасымалдау'),
    },
    'Main Electrical Panel': {
        'ru': ('Главный электрический щит',              'Электрооборудование'),
        'kk': ('Басты электр щиті',                     'Электр жабдығы'),
    },
    'Fire Suppression System': {
        'ru': ('Система пожаротушения',                  'Безопасность'),
        'kk': ('Өрт сөндіру жүйесі',                    'Қауіпсіздік'),
    },
    'Air Compressor': {
        'ru': ('Воздушный компрессор',                   'Пневматика'),
        'kk': ('Ауа компрессоры',                        'Пневматика'),
    },
    'UPS System': {
        'ru': ('Система ИБП',                            'Электроснабжение'),
        'kk': ('ҮАА жүйесі',                             'Электрмен қамту'),
    },
    'Water Pump Station': {
        'ru': ('Водонасосная станция',                   'Водоснабжение'),
        'kk': ('Сумен жабдықтау сорғы станциясы',       'Сантехника'),
    },
    'CCTV Control System': {
        'ru': ('Система управления видеонаблюдением',    'Безопасность'),
        'kk': ('Бейнебақылау басқару жүйесі',           'Қауіпсіздік'),
    },
}

_LANGS = ('ru', 'kk')


def upgrade() -> None:
    conn = op.get_bind()

    # ── service_type_translations ──────────────────────────────────────────────
    st_rows = conn.execute(text("SELECT id, key FROM service_types")).fetchall()
    key_to_st_id = {r.key: r.id for r in st_rows}

    stt = sa.table(
        'service_type_translations',
        sa.column('service_type_id', sa.Integer),
        sa.column('lang', sa.String),
        sa.column('name', sa.String),
        sa.column('description', sa.Text),
    )
    st_insert_rows = []
    for key, langs in _ST_TRANSLATIONS.items():
        st_id = key_to_st_id.get(key)
        if st_id is None:
            continue
        for lang in _LANGS:
            name, description = langs[lang]
            st_insert_rows.append({
                'service_type_id': st_id,
                'lang': lang,
                'name': name,
                'description': description,
            })

    if st_insert_rows:
        op.bulk_insert(stt, st_insert_rows)

    # ── equipment_translations ─────────────────────────────────────────────────
    eq_rows = conn.execute(text("SELECT id, name FROM equipment")).fetchall()
    eq_name_to_id = {r.name: r.id for r in eq_rows}

    eqt = sa.table(
        'equipment_translations',
        sa.column('equipment_id', sa.Integer),
        sa.column('lang', sa.String),
        sa.column('name', sa.String),
        sa.column('type_name', sa.String),
    )
    eq_insert_rows = []
    for en_name, langs in _EQ_TRANSLATIONS.items():
        eq_id = eq_name_to_id.get(en_name)
        if eq_id is None:
            continue
        for lang in _LANGS:
            name, type_name = langs[lang]
            eq_insert_rows.append({
                'equipment_id': eq_id,
                'lang': lang,
                'name': name,
                'type_name': type_name,
            })

    if eq_insert_rows:
        op.bulk_insert(eqt, eq_insert_rows)


def downgrade() -> None:
    op.execute(sa.text(
        "DELETE FROM service_type_translations WHERE lang IN ('ru', 'kk')"
    ))
    op.execute(sa.text(
        "DELETE FROM equipment_translations WHERE lang IN ('ru', 'kk')"
    ))
