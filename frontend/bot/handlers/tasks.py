import asyncio
import logging
import re
from typing import Any, Union

from aiogram import Bot, F, Router
from aiogram.filters import Command, StateFilter
from aiogram.fsm.context import FSMContext
from aiogram.fsm.state import default_state
from aiogram.types import CallbackQuery, Message, ReplyKeyboardRemove

from keyboards.main_menu import build_main_menu
from keyboards.task_creation import (
    build_address_keyboard,
    build_confirm_keyboard,
    build_service_type_keyboard,
)
from services.api_client import BackendClient, BackendError
from services.geocoder import GeocoderError, reverse_geocode
from states.task_creation import (
    RegistrationStates,
    TaskCreationStates,
    TaskStatusStates,
)

logger = logging.getLogger(__name__)

router = Router(name="tasks")

STATUS_LABELS: dict[str, str] = {
    "new":         "Новая",
    "assigned":    "Назначена",
    "in_progress": "В работе",
    "completed":   "Завершена",
    "approved":    "Принята",
    "rejected":    "Отклонена",
    "overdue":     "Просрочена",
}

PRIORITY_LABELS: dict[int, str] = {
    1: "Критический",
    2: "Высокий",
    3: "Нормальный",
    4: "Низкий",
}

#  Inactivity timer helpers 

_timers: dict[int, asyncio.Task] = {}  # chat_id → pending expiry task


def _cancel_timer(chat_id: int) -> None:
    if task := _timers.pop(chat_id, None):
        task.cancel()


def _start_timer(bot: Bot, chat_id: int, message_id: int, state: FSMContext) -> None:
    _cancel_timer(chat_id)
    _timers[chat_id] = asyncio.create_task(
        _inactivity_expire(bot, chat_id, message_id, state)
    )


async def _inactivity_expire(
    bot: Bot, chat_id: int, message_id: int, state: FSMContext
) -> None:
    await asyncio.sleep(300)  # 5 minutes
    if await state.get_state() is None:
        _timers.pop(chat_id, None)
        return
    await state.clear()
    try:
        await bot.edit_message_reply_markup(
            chat_id=chat_id, message_id=message_id, reply_markup=None
        )
    except Exception:
        pass
    await bot.send_message(
        chat_id,
        "Время ожидания истекло. Нажмите кнопку меню, чтобы продолжить.",
        reply_markup=build_main_menu(),
    )
    _timers.pop(chat_id, None)


#  Utilities 

def format_task(task: dict[str, Any]) -> str:
    status_label = STATUS_LABELS.get(task.get("status", ""), task.get("status", ""))
    priority_label = PRIORITY_LABELS.get(task.get("priority", 3), str(task.get("priority", "")))
    created = str(task.get("created_at", ""))[:10]
    deadline = str(task.get("deadline", ""))[:10] if task.get("deadline") else "не задан"
    description = task.get("description") or "нет описания"

    return (
        f"<b>Заявка #{task['id']}</b>\n"
        f"Тема: {task.get('title', '')}\n"
        f"Описание: {description}\n"
        f"Статус: <b>{status_label}</b>\n"
        f"Приоритет: {priority_label}\n"
        f"Создана: {created}\n"
        f"Дедлайн: {deadline}"
    )


#  Cancel 

@router.message(
    StateFilter(TaskCreationStates, TaskStatusStates, RegistrationStates),
    Command("cancel"),
)
@router.callback_query(
    StateFilter(TaskCreationStates, TaskStatusStates, RegistrationStates),
    F.data == "cancel",
)
async def handle_cancel(
    update: Union[Message, CallbackQuery],
    state: FSMContext,
) -> None:
    await state.clear()

    if isinstance(update, CallbackQuery):
        chat_id = update.message.chat.id  # type: ignore[union-attr]
        _cancel_timer(chat_id)
        await update.answer()
        try:
            await update.message.edit_reply_markup(reply_markup=None)  # type: ignore[union-attr]
        except Exception:
            pass
        await update.message.answer(  # type: ignore[union-attr]
            "Действие отменено.",
            reply_markup=build_main_menu(),
        )
    else:
        _cancel_timer(update.chat.id)
        await update.answer("Действие отменено.", reply_markup=build_main_menu())


#  My tasks 

@router.message(F.text == "Мои заявки")
@router.message(Command("tasks"))
async def handle_my_tasks(
    message: Message,
    backend: BackendClient,
) -> None:
    telegram_id = str(message.from_user.id) if message.from_user else "0"

    try:
        tasks: list[dict[str, Any]] = await backend.get_client_tasks(telegram_id)
    except BackendError as exc:
        await message.answer(f"Ошибка загрузки заявок ({exc.status}). Попробуйте позже.")
        return
    except Exception:
        await message.answer("Сервис временно недоступен. Попробуйте через минуту.")
        return

    if not tasks:
        await message.answer("У вас пока нет заявок.", reply_markup=build_main_menu())
        return

    shown = tasks[:10]
    body = "\n\n".join(format_task(t) for t in shown)
    if len(tasks) > 10:
        body += f"\n\n...и ещё {len(tasks) - 10} заявок."

    await message.answer(body, reply_markup=build_main_menu())


#  Task status 

@router.message(F.text == "Статус заявки")
@router.message(Command("status"))
async def handle_task_status_prompt(
    message: Message,
    state: FSMContext,
) -> None:
    await state.set_state(TaskStatusStates.waiting_for_id)
    await message.answer("Введите номер заявки:")


@router.message(TaskStatusStates.waiting_for_id)
async def handle_task_id_input(
    message: Message,
    state: FSMContext,
    backend: BackendClient,
) -> None:
    text = (message.text or "").strip()
    if not text.isdigit():
        await message.answer("Номер заявки должен быть числом. Попробуйте ещё раз:")
        return

    task_id = int(text)

    try:
        task = await backend.get_task(task_id)
    except BackendError as exc:
        if exc.status == 404:
            await message.answer(
                f"Заявка #{task_id} не найдена. Проверьте номер и попробуйте ещё раз:"
            )
            return
        await message.answer(f"Ошибка сервера ({exc.status}). Попробуйте позже.")
        await state.clear()
        return
    except Exception:
        await message.answer("Сервис временно недоступен. Попробуйте через минуту.")
        await state.clear()
        return

    await state.clear()
    await message.answer(format_task(task), reply_markup=build_main_menu())


#  Task creation 

@router.message(F.text == "Создать заявку")
@router.message(Command("create"))
async def handle_create_task(
    message: Message,
    state: FSMContext,
    backend: BackendClient,
    bot: Bot,
) -> None:
    try:
        service_types = await backend.get_service_types()
    except (BackendError, Exception):
        await message.answer(
            "Не удалось загрузить типы услуг. Попробуйте позже.",
            reply_markup=build_main_menu(),
        )
        return

    await state.set_state(TaskCreationStates.choose_service_type)
    await state.update_data(service_types=service_types)

    sent = await message.answer(
        "Выберите тип услуги или напишите его вручную:",
        reply_markup=build_service_type_keyboard(service_types),
    )
    _start_timer(bot, message.chat.id, sent.message_id, state)


@router.callback_query(
    TaskCreationStates.choose_service_type,
    F.data.startswith("svc:"),
)
async def handle_service_type_chosen(
    callback: CallbackQuery,
    state: FSMContext,
) -> None:
    service_type_id = int(callback.data.split(":")[1])  # type: ignore[union-attr]
    data = await state.get_data()
    service_types: list[dict[str, Any]] = data.get("service_types", [])
    label = next(
        (st["name"] for st in service_types if st["id"] == service_type_id),
        "Услуга",
    )

    _cancel_timer(callback.message.chat.id)  # type: ignore[union-attr]

    await state.update_data(service_type_id=service_type_id, service_type_label=label)
    await state.set_state(TaskCreationStates.describe_problem)

    await callback.answer()
    await callback.message.edit_text(  # type: ignore[union-attr]
        f"Тип услуги: <b>{label}</b>\n\nОпишите проблему подробнее:"
    )


@router.message(TaskCreationStates.choose_service_type)
async def handle_service_type_text(
    message: Message,
    state: FSMContext,
) -> None:
    label = (message.text or "").strip()
    if not label:
        await message.answer("Введите тип услуги или выберите из предложенных вариантов.")
        return

    _cancel_timer(message.chat.id)

    await state.update_data(service_type_id=None, service_type_label=label)
    await state.set_state(TaskCreationStates.describe_problem)
    await message.answer(f"Тип услуги: <b>{label}</b>\n\nОпишите проблему подробнее:")


@router.message(TaskCreationStates.describe_problem)
async def handle_description_entered(
    message: Message,
    state: FSMContext,
    bot: Bot,
) -> None:
    description = (message.text or "").strip()
    if not description:
        await message.answer("Описание не может быть пустым. Опишите проблему:")
        return

    await state.update_data(description=description)
    await state.set_state(TaskCreationStates.enter_address)
    sent = await message.answer(
        "Укажите адрес объекта, поделитесь геолокацией или нажмите <b>Пропустить</b>:",
        reply_markup=build_address_keyboard(),
    )
    _start_timer(bot, message.chat.id, sent.message_id, state)


@router.message(TaskCreationStates.enter_address, F.location)
async def handle_location_received(
    message: Message,
    state: FSMContext,
    bot: Bot,
) -> None:
    loc = message.location
    lat: float = loc.latitude  # type: ignore[union-attr]
    lon: float = loc.longitude  # type: ignore[union-attr]

    logger.info("Location from user %s: lat=%.6f, lon=%.6f", message.from_user.id, lat, lon)

    _cancel_timer(message.chat.id)

    try:
        geo = await reverse_geocode(lat, lon)
    except GeocoderError as exc:
        await message.answer(
            f"Не удалось определить адрес: {exc}\n"
            "Введите адрес вручную или нажмите <b>Пропустить</b>.",
            reply_markup=build_address_keyboard(),
        )
        return
    except Exception:
        await message.answer(
            "Сервис геокодирования временно недоступен. "
            "Введите адрес вручную или нажмите <b>Пропустить</b>.",
            reply_markup=build_address_keyboard(),
        )
        return

    lines = [
        "📍 Геолокация получена\n",
        f"Адрес: {geo.full_address}",
        f"Широта: {geo.latitude:.6f}",
        f"Долгота: {geo.longitude:.6f}",
        f"Город: {geo.city or '-'}",
        f"Регион: {geo.region or '-'}",
        f"Страна: {geo.country or '-'}",
    ]
    if geo.postal_code:
        lines.append(f"Индекс: {geo.postal_code}")

    await state.update_data(
        address=geo.full_address,
        latitude=geo.latitude,
        longitude=geo.longitude,
    )

    # ReplyKeyboardRemove dismisses the location keyboard before the confirm screen
    await message.answer("\n".join(lines), reply_markup=ReplyKeyboardRemove())
    await _show_confirm(message, state, bot)


@router.message(TaskCreationStates.enter_address, F.text == "Пропустить")
async def handle_address_skip_text(
    message: Message,
    state: FSMContext,
    bot: Bot,
) -> None:
    _cancel_timer(message.chat.id)
    await state.update_data(address=None)
    await message.answer("Адрес пропущен.", reply_markup=ReplyKeyboardRemove())
    await _show_confirm(message, state, bot)


@router.message(TaskCreationStates.enter_address)
async def handle_address_entered(
    message: Message,
    state: FSMContext,
    bot: Bot,
) -> None:
    address = (message.text or "").strip()
    if not address:
        await message.answer(
            "Введите адрес или нажмите <b>Пропустить</b>:",
            reply_markup=build_address_keyboard(),
        )
        return

    _cancel_timer(message.chat.id)
    await state.update_data(address=address)
    await _show_confirm(message, state, bot)


@router.callback_query(
    TaskCreationStates.enter_address,
    F.data == "skip:address",
)
async def handle_address_skipped(
    callback: CallbackQuery,
    state: FSMContext,
    bot: Bot,
) -> None:
    chat_id = callback.message.chat.id  # type: ignore[union-attr]
    _cancel_timer(chat_id)
    await state.update_data(address=None)
    await callback.answer()
    try:
        await callback.message.edit_reply_markup(reply_markup=None)  # type: ignore[union-attr]
    except Exception:
        pass
    await _show_confirm(callback.message, state, bot)  # type: ignore[arg-type]


async def _show_confirm(message: Message, state: FSMContext, bot: Bot) -> None:
    data = await state.get_data()
    label: str = data.get("service_type_label", "")
    description: str = data.get("description", "")
    address: str | None = data.get("address")

    summary_lines = [
        "<b>Проверьте данные заявки:</b>",
        f"Тип услуги: {label}",
        f"Описание: {description}",
    ]
    if address:
        summary_lines.append(f"Адрес: {address}")

    await state.set_state(TaskCreationStates.confirm)
    sent = await message.answer(
        "\n".join(summary_lines),
        reply_markup=build_confirm_keyboard(),
    )
    _start_timer(bot, message.chat.id, sent.message_id, state)


@router.callback_query(
    TaskCreationStates.confirm,
    F.data == "confirm:yes",
)
async def handle_confirm_submit(
    callback: CallbackQuery,
    state: FSMContext,
    backend: BackendClient,
    bot: Bot,
) -> None:
    chat_id = callback.message.chat.id  # type: ignore[union-attr]
    _cancel_timer(chat_id)

    data = await state.get_data()
    label: str = data.get("service_type_label", "Заявка")
    description: str = data.get("description", "")
    address: str | None = data.get("address")
    service_type_id: int | None = data.get("service_type_id")

    title = f"Заявка: {label}"
    full_description: str | None = description or None
    if address:
        full_description = f"{description}\nАдрес: {address}" if description else f"Адрес: {address}"

    telegram_id = str(callback.from_user.id)

    await callback.answer()
    try:
        await callback.message.edit_reply_markup(reply_markup=None)  # type: ignore[union-attr]
    except Exception:
        pass

    try:
        task = await backend.create_task(
            telegram_id=telegram_id,
            title=title,
            description=full_description,
            service_type_id=service_type_id,
        )
    except BackendError as exc:
        await callback.message.answer(  # type: ignore[union-attr]
            f"Не удалось создать заявку ({exc.status}). Попробуйте ещё раз.",
            reply_markup=build_main_menu(),
        )
        await state.clear()
        return
    except Exception:
        await callback.message.answer(  # type: ignore[union-attr]
            "Сервис временно недоступен. Попробуйте через минуту.",
            reply_markup=build_main_menu(),
        )
        await state.clear()
        return

    await state.clear()

    status_label = STATUS_LABELS.get(task.get("status", "new"), "Новая")
    await callback.message.answer(  # type: ignore[union-attr]
        f"Заявка создана успешно!\n\n"
        f"<b>Задача #{task['id']}</b>\n"
        f"Статус: {status_label}",
        reply_markup=build_main_menu(),
    )


#  Task reply from app


def _is_task_reply(message: Message) -> bool:
    if not message.text:
        return False
    return message.text.strip().startswith("[Task")


def _parse_task_reply(text: str) -> tuple[int, str] | None:
    match = re.match(r"\[Task\s+WO-(\d+)\]\s+Worker:\s*(.*)", text, re.DOTALL)
    if not match:
        return None
    task_id = int(match.group(1))
    reply_text = match.group(2).strip()
    return (task_id, reply_text)


@router.message(StateFilter(default_state), _is_task_reply)
async def handle_task_reply(
    message: Message,
    backend: BackendClient,
) -> None:
    text = (message.text or "").strip()
    parsed = _parse_task_reply(text)

    if not parsed:
        await message.answer("Неверный формат сообщения. Ожидается: [Task WO-XXXX] Worker: ваше сообщение")
        return

    task_id, reply_text = parsed

    if not reply_text:
        await message.answer("Сообщение не может быть пустым.")
        return

    telegram_id = str(message.from_user.id) if message.from_user else "0"

    try:
        await backend.send_task_reply(task_id, reply_text, telegram_id)
    except BackendError as exc:
        await message.answer(f"Ошибка отправки ответа ({exc.status}). Попробуйте позже.")
        return
    except Exception:
        await message.answer("Сервис временно недоступен. Попробуйте через минуту.")
        return

    await message.answer(f"✓ Ответ на заявку #{task_id} отправлен.", reply_markup=build_main_menu())
