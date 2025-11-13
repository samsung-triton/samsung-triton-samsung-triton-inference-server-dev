from app.core.database import Base
from sqlalchemy import Column, BigInteger, Integer, Text, Boolean, TIMESTAMP, ForeignKey, text
from sqlalchemy.orm import relationship


class ModelConfig(Base):
    __tablename__ = "model_configs"

    config_id = Column(BigInteger, primary_key=True, index=True)
    model_id = Column(BigInteger, ForeignKey("models.model_id", ondelete="CASCADE"), nullable=False)
    version = Column(Integer, nullable=False)
    content = Column(Text, nullable=False)
    file_path = Column(Text, nullable=False)
    created_by = Column(BigInteger, ForeignKey("users.user_id", ondelete="SET NULL"))
    created_at = Column(TIMESTAMP(timezone=True), server_default=text("now()"), nullable=False)
    is_current = Column(Boolean, default=False)

    model = relationship("Model", back_populates="configs")
    creator = relationship("User", back_populates="configs")
