from sqlalchemy import Column, BigInteger, String, TIMESTAMP, text
from sqlalchemy.dialects.postgresql import ENUM
from app.core.database import Base
from enum import Enum as PyEnum


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
