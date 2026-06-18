import re

from aiogram import F, Router
from aiogram.enums import ContentType
from aiogram.filters import CommandStart
from aiogram.fsm.context import FSMContext
from aiogram.types import (
    KeyboardButton,
    Message,
    ReplyKeyboardMarkup,
    ReplyKeyboardRemove,
)

from keyboards.main_menu import build_main_menu
from services.api_client import BackendClient, BackendError
from states.task_creation import RegistrationStates

router = Router(name="start")

PHONE_RE = re.compile(r"^\+?[\d\s]{7,15}$")

_PHONE_REQUEST_KEYBOARD = ReplyKeyboardMarkup(
    keyboard=[
        [KeyboardButton(text="Поделиться номером", request_contact=True)],
        [KeyboardButton(text="Пропустить")],
    ],
    resize_keyboard=True,
    one_time_keyboard=True,
)


@router.message(CommandStart())
async def cmd_start(
    message: Message,
    state: FSMContext,
    backend: BackendClient,
) -> None:
    """Entry point for the bot. Clears any stale FSM state and begins registration.

    We do a partial register here (phone=None) immediately so a client record
    exists even if the user closes the app before sharing their phone number.
    This prevents a situation where the user can send a /start and then immediately
    type a menu command before the phone step is complete, resulting in no client record.
    """
    await state.clear()

    user = message.from_user
    if user is None:
        await message.answer("Не удалось определить пользователя. Попробуйте ещё раз.")
        return

    telegram_id: str = str(user.id)
    full_name: str = (user.full_name or "").strip() or "Без имени"

    try:
        await backend.register_client(
            telegram_id=telegram_id,
            full_name=full_name,
            phone=None,
        )
    except BackendError as exc:
        await message.answer(
            f"Ошибка регистрации ({exc.status}). Попробуйте /start снова."
        )
        return
    except Exception:
        await message.answer("Сервис временно недоступен. Попробуйте через минуту.")
        return

    await state.set_state(RegistrationStates.waiting_for_phone)
    await state.update_data(full_name=full_name)

    await message.answer(
        f"Добро пожаловать, <b>{full_name}</b>!\n\n"
        "Поделитесь номером телефона, чтобы менеджер мог с вами связаться, "
        "или нажмите <b>Пропустить</b>.",
        reply_markup=_PHONE_REQUEST_KEYBOARD,
    )


@router.message(
    RegistrationStates.waiting_for_phone,
    F.content_type.in_({ContentType.CONTACT, ContentType.TEXT}),
)
async def handle_phone(
    message: Message,
    state: FSMContext,
    backend: BackendClient,
) -> None:
    """Collect the phone number from a shared contact or manual text, then finish registration.

    The upsert call here updates the record created in cmd_start with the phone number.
    Using upsert on both sides means the client record is always consistent regardless
    of which step the user completes.
    """
    phone: str | None = None

    if message.contact is not None:
        phone = message.contact.phone_number
    elif message.text and message.text.strip() != "Пропустить":
        candidate = message.text.strip()
        if PHONE_RE.match(candidate):
            phone = candidate
        else:
            await message.answer(
                "Неверный формат номера. Введите номер в формате +7XXXXXXXXXX "
                "или нажмите <b>Пропустить</b>."
            )
            return

    data = await state.get_data()
    full_name: str = data.get("full_name", "Без имени")
    telegram_id: str = str(message.from_user.id) if message.from_user else "0"

    try:
        await backend.register_client(
            telegram_id=telegram_id,
            full_name=full_name,
            phone=phone,
        )
    except BackendError as exc:
        await message.answer(
            f"Ошибка регистрации ({exc.status}). Попробуйте /start снова."
        )
        return
    except Exception:
        await message.answer("Сервис временно недоступен. Попробуйте через минуту.")
        return

    await state.clear()

    greeting = (
        "Регистрация завершена! Номер телефона сохранён."
        if phone
        else "Регистрация завершена! Номер телефона не указан."
    )

    await message.answer(
        f"{greeting}\n\nВыберите действие из меню ниже:",
        reply_markup=ReplyKeyboardRemove(),
    )
    await message.answer("Главное меню:", reply_markup=build_main_menu())
