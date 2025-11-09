from sqlalchemy import Column, BigInteger, Integer, Text, Boolean, TIMESTAMP, ForeignKey
from sqlalchemy.orm import relationship
from app.core.database import Base

class ModelConfig(Base):
    __tablename__ = "model_configs"

    config_id = Column(BigInteger, primary_key=True, index=True)
    model_id = Column(BigInteger, ForeignKey("models.model_id", ondelete="CASCADE"), nullable=False)
    version = Column(Integer, nullable=False)
    content = Column(Text, nullable=False)
    file_path = Column(Text, nullable=False)
    created_by = Column(BigInteger, ForeignKey("users.user_id", ondelete="SET NULL"))
    created_at = Column(TIMESTAMP(timezone=True))
    is_current = Column(Boolean, default=False)

    creator = relationship("User", backref="configs")
    model = relationship("Model", backref="configs")
