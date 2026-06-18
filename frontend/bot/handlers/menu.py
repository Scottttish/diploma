from aiogram import Router
from aiogram.filters import Command, StateFilter
from aiogram.fsm.state import default_state
from aiogram.types import Message

from keyboards.main_menu import build_main_menu

router = Router(name="menu")

HELP_TEXT = (
    "<b>Справка по боту</b>\n\n"
    "Бот может:\n"
    "  <b>Создать заявку</b> - оформить новую заявку на обслуживание.\n"
    "  <b>Мои заявки</b> - посмотреть список всех ваших заявок.\n"
    "  <b>Статус заявки</b> - узнать статус конкретной заявки по номеру.\n\n"
    "<b>Статусы заявок:</b>\n"
    "  Новая - заявка принята и ожидает обработки.\n"
    "  Назначена - исполнитель назначен.\n"
    "  В работе - исполнитель приступил к работе.\n"
    "  Завершена - работа выполнена, ожидает вашего подтверждения.\n"
    "  Принята - вы подтвердили выполнение работы.\n"
    "  Отклонена - заявка отклонена.\n"
    "  Просрочена - срок выполнения истек.\n\n"
    "Для отмены любого действия напишите /cancel."
)


@router.message(StateFilter(default_state), lambda m: m.text == "Помощь")
@router.message(StateFilter(default_state), Command("help"))
async def handle_help(message: Message) -> None:
    """Show static help text. Registered only in default state so it does not
    fire while the user is mid-flow in a task creation FSM.
    """
    await message.answer(HELP_TEXT, reply_markup=build_main_menu())


@router.message(StateFilter(default_state))
async def handle_unknown(message: Message) -> None:
    """Catch any unrecognised message in the default state and guide the user.

    This handler is last in the router chain so it only fires when nothing
    else matched. Without it, silently ignoring unknown input would confuse users.
    """
    await message.answer(
        "Я не понимаю эту команду. Используйте кнопки меню или напишите /start.",
        reply_markup=build_main_menu(),
    )
