from app.core.DB.database import Base
from enum import Enum as PyEnum
from sqlalchemy import Column, BigInteger, String, TIMESTAMP, text
from sqlalchemy.dialects.postgresql import ENUM
from sqlalchemy.orm import relationship


class UserRole(PyEnum):
    OPER = "OPER"
    DEVEL = "DEVEL"


class User(Base):
    __tablename__ = "users"
    user_id = Column(BigInteger, primary_key=True, index=True)
    name = Column(String(64), nullable=False)
    login_id = Column(String(64), unique=True, nullable=False)
    password = Column(String(128), nullable=False)
    role = Column(ENUM(UserRole, name="user_role", create_type=False), nullable=False)
    created_at = Column(TIMESTAMP(timezone=True), server_default=text("now()"), nullable=False)
    last_login_at = Column(TIMESTAMP(timezone=True))

    configs = relationship("ModelConfig", back_populates="creator", cascade="all, delete")
    versions = relationship("ModelVersion", back_populates="creator", cascade="all, delete")
    releases = relationship("ModelRelease", back_populates="actor", cascade="all, delete")
