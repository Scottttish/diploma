import asyncio
import logging

from aiogram import Bot, Dispatcher
from aiogram.client.default import DefaultBotProperties
from aiogram.enums import ParseMode
from aiogram.types import BotCommand
from aiohttp import web

from config import get_settings
from handlers import menu, start, tasks
from notifications import create_notify_app
from services import BackendClient

settings = get_settings()

backend = BackendClient()


async def on_startup(bot: Bot) -> None:
    await backend.start()

    await bot.set_my_commands([
        BotCommand(command="create", description="Создать новую заявку"),
        BotCommand(command="tasks",  description="Мои заявки"),
        BotCommand(command="status", description="Статус заявки по номеру"),
        BotCommand(command="help",   description="Справка"),
        BotCommand(command="cancel", description="Отменить текущее действие"),
    ])

    notify_app = create_notify_app(bot)
    runner = web.AppRunner(notify_app)
    await runner.setup()

    site = web.TCPSite(
        runner,
        host=settings.NOTIFY_SERVER_HOST,
        port=settings.NOTIFY_SERVER_PORT,
    )
    await site.start()

    logging.info(
        "Notification server listening on %s:%d",
        settings.NOTIFY_SERVER_HOST,
        settings.NOTIFY_SERVER_PORT,
    )


async def on_shutdown(bot: Bot) -> None:
    """Close the shared aiohttp session gracefully on SIGINT or SIGTERM."""
    await backend.stop()


def build_dispatcher() -> Dispatcher:
    """Wire routers and lifecycle hooks into the dispatcher.

    Router order is critical: start and tasks must be registered before menu
    so the fallback handler in menu.router does not swallow FSM-state messages.
    The backend instance is passed as a keyword argument so aiogram injects it
    automatically into any handler that declares a 'backend' parameter.
    """
    dp = Dispatcher(backend=backend)

    dp.startup.register(on_startup)
    dp.shutdown.register(on_shutdown)

    dp.include_router(start.router)
    dp.include_router(tasks.router)
    dp.include_router(menu.router)

    return dp


async def main() -> None:
    logging.basicConfig(
        level=logging.INFO,
        format="%(asctime)s [%(levelname)s] %(name)s: %(message)s",
    )

    bot = Bot(
        token=settings.BOT_TOKEN,
        default=DefaultBotProperties(parse_mode=ParseMode.HTML),
    )

    dp = build_dispatcher()

    logging.info("Starting bot in polling mode...")
    await dp.start_polling(bot, allowed_updates=["message", "callback_query"])


if __name__ == "__main__":
    asyncio.run(main())
