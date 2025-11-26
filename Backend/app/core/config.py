from pydantic_settings import BaseSettings
from pathlib import Path
from zoneinfo import ZoneInfo


class Settings(BaseSettings):
    # FastAPI
    APP_NAME: str
    APP_ENV: str
    DEBUG: bool
    LOG_LEVEL: str
    BIND_HOST: str
    BIND_PORT: int
    MAX_WORKERS: int

    # PostgreSQL
    DB_HOST: str
    DB_PORT: int
    DB_USER: str
    DB_PASSWORD: str
    DB_NAME: str

    # ClickHouse
    CHK_HOST: str
    CHK_DB: str
    CHK_PORT: str
    CHK_USER: str
    CHK_PASSWORD: str

    # Triton
    TRITON_GRPC_URL: str
    TRITON_HTTP_URL: str  # ex: http://localhost:8000
    TRITON_IMAGE: str
    TRITON_CONTAINER_NAME: str
    TRITON_MODEL_PATH: str
    TRITON_COMPOSE_PATH: str

    # Prometheus
    PROM_URL: str

    # Data
    INFER_DATA_SAVE_PATH: str

    ALLOW_OVERWRITE: bool = False

    TIMEZONE: str

    class Config:
        env_file = ".env"
        env_file_encoding = "utf-8"


settings = Settings()
Path(settings.INFER_DATA_SAVE_PATH).mkdir(parents=True, exist_ok=True)
TIMEZONE = ZoneInfo(settings.TIMEZONE)
