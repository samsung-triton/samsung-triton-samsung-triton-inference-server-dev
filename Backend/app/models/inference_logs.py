from sqlalchemy import Column, BigInteger, String, Text, Boolean, TIMESTAMP, func, Integer, Computed, Enum
from app.core.DB.database import Base
from enum import Enum as PyEnum


class RequestStatus(PyEnum):
    SUCCESS = "SUCCESS"
    FAIL = "FAIL"


class InferenceStatus(PyEnum):
    OK = "OK"
    NG = "NG"
    ERROR = "ERROR"


class InferenceLogs(Base):
    __tablename__ = "inference_logs"

    inference_log_id = Column(BigInteger, primary_key=True, index=True)
    uid = Column(String(128), nullable=False)
    client_id = Column(String(64), nullable=False)
    request_status = Column(Enum(RequestStatus), default=RequestStatus.FAIL, nullable=False)
    inference_status = Column(Enum(InferenceStatus), default=InferenceStatus.ERROR, nullable=False)
    input_path = Column(Text, nullable=False)
    output_path = Column(Text)
    result_text = Column(Text)
    is_ok = Column(Boolean, default=True)
    created_at = Column(TIMESTAMP(timezone=True), server_default=func.now())
    completed_at = Column(TIMESTAMP(timezone=True))
    duration_ms = Column(
        Integer, Computed("(EXTRACT(EPOCH FROM completed_at - created_at) * 1000)::INTEGER", persisted=True)
    )
    model_id = Column(BigInteger, nullable=False)
