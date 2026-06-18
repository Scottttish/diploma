import logging

from aiogram import Bot
from aiohttp import web

logger = logging.getLogger(__name__)


async def handle_notify(request: web.Request) -> web.Response:
    """Receive a push notification from the backend and forward it to the Telegram user.

    The backend calls this endpoint whenever a task event occurs (assigned, completed,
    rejected, etc.). The bot instance lives in app["bot"] so there are no globals.
    """
    try:
        data: dict = await request.json()
    except Exception:
        return web.json_response({"error": "invalid JSON body"}, status=400)

    telegram_id: str = data.get("telegram_id", "").strip()
    message_text: str = data.get("message", "").strip()

    if not telegram_id or not message_text:
        return web.json_response(
            {"error": "telegram_id and message are required"}, status=400
        )

    bot: Bot = request.app["bot"]

    try:
        await bot.send_message(chat_id=int(telegram_id), text=message_text)
    except ValueError:
        return web.json_response(
            {"error": f"telegram_id must be an integer, got '{telegram_id}'"}, status=400
        )
    except Exception as exc:
        logger.error(
            "Failed to deliver notification to telegram_id=%s: %s", telegram_id, exc
        )
        return web.json_response({"error": str(exc)}, status=500)

    logger.info("Notification delivered to telegram_id=%s", telegram_id)
    return web.json_response({"ok": True})


def create_notify_app(bot: Bot) -> web.Application:
    """Build the aiohttp application for the notification receiver endpoint.

    Storing the bot in app["bot"] follows the standard aiohttp pattern for
    shared resources and avoids module-level globals.
    """
    app = web.Application()
    app["bot"] = bot
    app.router.add_post("/notify", handle_notify)
    return app
