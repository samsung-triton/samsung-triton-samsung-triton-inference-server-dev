from sqlalchemy import Column, BigInteger, String, Enum, TIMESTAMP, text
from app.core.database import Base
import enum


class ModelType(str, enum.Enum):
    NORMAL = "NORMAL"
    ENSEMBLE = "ENSEMBLE"


class Model(Base):
    __tablename__ = "models"

    model_id = Column(BigInteger, primary_key=True, autoincrement=True, nullable=False)
    name = Column(String(64), nullable=False)
    type = Column(Enum(ModelType, name="model_type"), nullable=False)
    storage_dir = Column(String(128), nullable=False, server_default=text("'/storage/models/{name}/'"))
    created_at = Column(TIMESTAMP(timezone=True), server_default=text("now()"))
    updated_at = Column(TIMESTAMP(timezone=True), server_default=text("now()"))
