from aiogram.types import KeyboardButton, ReplyKeyboardMarkup


def build_main_menu() -> ReplyKeyboardMarkup:
    """Build the persistent bottom keyboard shown after registration and after every action.

    persistent=True keeps the keyboard attached even when the user sends messages,
    so they never accidentally dismiss it and get stuck with no navigation.
    """
    return ReplyKeyboardMarkup(
        keyboard=[
            [
                KeyboardButton(text="Создать заявку"),
                KeyboardButton(text="Мои заявки"),
            ],
            [
                KeyboardButton(text="Статус заявки"),
                KeyboardButton(text="Помощь"),
            ],
        ],
        resize_keyboard=True,
        persistent=True,
    )
