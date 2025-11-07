# app/core/config.py
from pydantic_settings import BaseSettings
from pathlib import Path


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

    # Triton
    TRITON_URL: str

    # Data
    INFER_DATA_SAVE_PATH: str

    class Config:
        env_file = ".env"
        env_file_encoding = "utf-8"


settings = Settings()
Path(settings.INFER_DATA_SAVE_PATH).mkdir(parents=True, exist_ok=True)
