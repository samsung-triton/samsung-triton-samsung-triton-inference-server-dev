from pydantic_settings import BaseSettings


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
    TRITON_URL: str                     # ex: http://localhost:8000
    TRITON_IMAGE: str
    TRITON_CONTAINER_NAME: str
    TRITON_MODEL_PATH: str
    TRITON_COMPOSE_PATH: str

    class Config:
        env_file = ".env"
        env_file_encoding = "utf-8"


settings = Settings()
