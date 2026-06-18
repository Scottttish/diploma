from functools import lru_cache

from pydantic_settings import BaseSettings


class Settings(BaseSettings):
    BOT_TOKEN: str
    BACKEND_URL: str = "http://localhost:8000"
    TELEGRAM_WEBHOOK_SECRET: str = ""
    NOTIFY_SERVER_HOST: str = "0.0.0.0"
    NOTIFY_SERVER_PORT: int = 8080

    model_config = {"env_file": ".env", "extra": "ignore"}


@lru_cache
def get_settings() -> Settings:
    return Settings()
