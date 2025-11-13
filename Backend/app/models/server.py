from sqlalchemy import Column, BigInteger, TIMESTAMP, ForeignKey, Text, text
from sqlalchemy.dialects.postgresql import ENUM
from app.core.database import Base
from enum import Enum as PyEnum


class ServerStatus(PyEnum):
    START = "START"
    STOP = "STOP"


class Server(Base):
    __tablename__ = "server"

    server_id = Column(BigInteger, primary_key=True, index=True)
    actor_id = Column(BigInteger, ForeignKey("users.user_id", ondelete="SET NULL"))
    status = Column(ENUM(ServerStatus, name="server_status", create_type=False), nullable=False)
    description = Column(Text, nullable=True)
    created_at = Column(TIMESTAMP(timezone=True), server_default=text("now()"), nullable=False)
