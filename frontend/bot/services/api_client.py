from typing import Any

import aiohttp

from config import get_settings

_service_types_cache: list[dict[str, Any]] | None = None


class BackendError(Exception):
    """Raised when the backend returns a non-2xx response."""

    def __init__(self, status: int, detail: str) -> None:
        self.status = status
        self.detail = detail
        super().__init__(f"Backend {status}: {detail}")


class BackendClient:
    """Single long-lived HTTP client for all communication with the FastAPI backend.

    One instance is created at process startup and reused for every request.
    This is the correct aiohttp pattern because ClientSession is not thread-safe
    and creating a new session per request leaks file descriptors.
    """

    def __init__(self) -> None:
        self._settings = get_settings()
        self._session: aiohttp.ClientSession | None = None

    def _require_session(self) -> aiohttp.ClientSession:
        """Guard that blows up with a clear message if start() was never called."""
        if self._session is None:
            raise RuntimeError(
                "BackendClient.start() must be called before making requests. "
                "Wire it into the on_startup lifecycle hook in main.py."
            )
        return self._session

    async def start(self) -> None:
        """Open the shared session once when the bot process starts."""
        self._session = aiohttp.ClientSession(
            base_url=self._settings.BACKEND_URL+"/api/",
            headers={
                "x-telegram-bot-api-secret-token": self._settings.TELEGRAM_WEBHOOK_SECRET,
                "Content-Type": "application/json",
                "Accept-Language": "ru",
            },
        )

    async def stop(self) -> None:
        """Gracefully close the session when the bot shuts down."""
        if self._session is not None:
            await self._session.close()
            self._session = None

    async def _handle_response(self, resp: aiohttp.ClientResponse) -> Any:
        """Parse JSON and raise BackendError for any non-2xx status."""
        if resp.status >= 400:
            try:
                body = await resp.json()
                detail: str = body.get("detail", "unknown error")
            except Exception:
                detail = await resp.text()
            raise BackendError(resp.status, detail)
        return await resp.json()

    async def register_client(
        self,
        telegram_id: str,
        full_name: str,
        phone: str | None,
    ) -> dict[str, Any]:
        """Register or update a Telegram client profile.

        The backend endpoint is idempotent so calling this multiple times
        (e.g. on repeated /start) is safe and simply updates the record.
        """
        session = self._require_session()
        payload: dict[str, Any] = {
            "telegram_id": telegram_id,
            "full_name": full_name,
        }
        if phone is not None:
            payload["phone"] = phone

        async with session.post("telegram/register", json=payload) as resp:
            return await self._handle_response(resp)

    async def create_task(
        self,
        telegram_id: str,
        title: str,
        description: str | None,
        service_type_id: int | None,
    ) -> dict[str, Any]:
        """Submit a new service request on behalf of the Telegram client."""
        session = self._require_session()
        payload: dict[str, Any] = {
            "telegram_id": telegram_id,
            "title": title,
        }
        if description is not None:
            payload["description"] = description
        if service_type_id is not None:
            payload["service_type_id"] = service_type_id

        async with session.post("telegram/request", json=payload) as resp:
            return await self._handle_response(resp)

    async def get_client_tasks(self, telegram_id: str) -> list[dict[str, Any]]:
        """Fetch all tasks that belong to the given Telegram client."""
        session = self._require_session()
        async with session.get(f"clients/{telegram_id}/tasks") as resp:
            return await self._handle_response(resp)

    async def get_task(self, task_id: int) -> dict[str, Any]:
        """Fetch a single task by its numeric ID, including the current status."""
        session = self._require_session()
        async with session.get(f"telegram/tasks/{task_id}") as resp:
            return await self._handle_response(resp)

    async def get_service_types(self) -> list[dict[str, Any]]:
        """Fetch service types from the backend, returning a cached copy after the first call."""
        global _service_types_cache
        if _service_types_cache is not None:
            return _service_types_cache
        session = self._require_session()
        async with session.get("telegram/service-types") as resp:
            result: list[dict[str, Any]] = await self._handle_response(resp)
        _service_types_cache = result
        return result

    async def send_task_reply(
        self,
        task_id: int,
        message: str,
        telegram_id: str,
    ) -> dict[str, Any]:
        """Send a reply/message to a task from the Telegram client."""
        session = self._require_session()
        payload: dict[str, Any] = {
            "message": message,
            "telegram_id": telegram_id,
        }
        async with session.post(f"tasks/{task_id}/reply", json=payload) as resp:
            return await self._handle_response(resp)
