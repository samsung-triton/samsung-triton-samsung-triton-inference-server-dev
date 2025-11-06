from sqlalchemy import Column, Integer, String, ForeignKey, DateTime, Text, BigInteger, Enum
from sqlalchemy.sql import func
from sqlalchemy.orm import relationship
from app.core.database import Base


class Model(Base):
    __tablename__ = "model"
    id = Column(Integer, primary_key=True)
    name = Column(String(255), unique=True, index=True, nullable=False)
    type = Column(String(32), nullable=False)  # SINGLE/ENSEMBLE
    description = Column(Text, nullable=False)
    status = Column(String(32), default="REGISTERED")
    created_by = Column(Integer, nullable=False)
    created_at = Column(DateTime(timezone=True), server_default=func.now())

    versions = relationship("ModelVersion", back_populates="model")


class ModelVersion(Base):
    __tablename__ = "model_version"
    id = Column(Integer, primary_key=True)
    model_id = Column(Integer, ForeignKey("model.id"), nullable=False)
    version = Column(Integer, nullable=False)  # 1, 2, ...
    status = Column(String(32), default="STORED")
    repo_path = Column(Text, nullable=False)  # ex) /models/yolov8n_onnx_nms/1
    created_at = Column(DateTime(timezone=True), server_default=func.now())

    model = relationship("Model", back_populates="versions")
    files = relationship("ModelFile", back_populates="version")


class ModelFile(Base):
    __tablename__ = "model_file"
    id = Column(Integer, primary_key=True)
    model_version_id = Column(Integer, ForeignKey("model_version.id"), nullable=False)
    filename = Column(String(512), nullable=False)
    rel_path = Column(Text, nullable=False)  # repo_path 기준 상대경로 (ex: "1/model.onnx", "config.pbtxt")
    file_type = Column(String(32), nullable=False)  # MODEL / CONFIG / OTHER
    size_bytes = Column(BigInteger, nullable=False, default=0)
    created_at = Column(DateTime(timezone=True), server_default=func.now())

    version = relationship("ModelVersion", back_populates="files")
