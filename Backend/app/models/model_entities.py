from sqlalchemy import Column, Integer, String, BigInteger, Text, ForeignKey, DateTime, Boolean, Enum, func

from sqlalchemy.orm import relationship
from app.core.database import Base

from enum import Enum as PyEnum


class ModelType(PyEnum):
    NORMAL = "NORMAL"
    ENSEMBLE = "ENSEMBLE"


class ReleaseType(PyEnum):
    CONFIG = "CONFIG"
    MODEL = "MODEL"
    VERSION = "VERSION"


class ReleaseAction(PyEnum):
    CREATE = "CREATE"
    UPDATE = "UPDATE"
    DELETE = "DELETE"


class Model(Base):
    __tablename__ = "models"

    model_id = Column(BigInteger, primary_key=True, autoincrement=True)
    name = Column(String(64), unique=True, nullable=False)
    type = Column(Enum(ModelType, name="model_type"), nullable=False)
    storage_dir = Column(String(128), nullable=False)
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    updated_at = Column(DateTime(timezone=True), server_default=func.now(), onupdate=func.now())

    versions = relationship("ModelVersion", back_populates="model", cascade="all, delete")
    configs = relationship("ModelConfig", back_populates="model", cascade="all, delete")
    # release log 연결은 model_id를 target_id로 참조하므로 역참조 필요 없음


class ModelVersion(Base):
    __tablename__ = "model_versions"

    model_version_id = Column(BigInteger, primary_key=True, autoincrement=True)
    model_id = Column(BigInteger, ForeignKey("models.model_id", ondelete="CASCADE"), nullable=False)
    version = Column(Integer, nullable=False)
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    created_by = Column(BigInteger, ForeignKey("users.user_id", ondelete="SET NULL"))

    # relationships
    model = relationship("Model", back_populates="versions")
    files = relationship("ModelVersionFile", back_populates="version", cascade="all, delete")


class ModelVersionFile(Base):
    __tablename__ = "model_version_files"

    model_version_file_id = Column(BigInteger, primary_key=True, autoincrement=True)
    model_version_id = Column(
        BigInteger,
        ForeignKey("model_versions.model_version_id", ondelete="CASCADE"),
        nullable=False,
    )
    file_name = Column(String(128))
    file_path = Column(String(256), nullable=False)
    created_at = Column(DateTime(timezone=True), server_default=func.now())

    # relationship
    version = relationship("ModelVersion", back_populates="files")


class ModelConfig(Base):
    __tablename__ = "model_configs"

    config_id = Column(BigInteger, primary_key=True, autoincrement=True)
    model_id = Column(BigInteger, ForeignKey("models.model_id", ondelete="CASCADE"), nullable=False)
    version = Column(Integer, nullable=False)
    content = Column(Text, nullable=False)
    file_path = Column(String(256), nullable=False)
    created_by = Column(BigInteger, ForeignKey("users.user_id", ondelete="SET NULL"))
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    is_current = Column(Boolean, default=False)

    # relationship
    model = relationship("Model", back_populates="configs")


class ModelRelease(Base):
    __tablename__ = "model_releases"

    release_id = Column(BigInteger, primary_key=True, autoincrement=True)
    actor_id = Column(BigInteger, ForeignKey("users.user_id", ondelete="SET NULL"))
    type = Column(Enum(ReleaseType, name="release_type"), nullable=False)
    action = Column(Enum(ReleaseAction, name="release_action"), nullable=False)
    target_id = Column(BigInteger, nullable=False)
    reason = Column(Text)
    created_at = Column(DateTime(timezone=True), server_default=func.now())
