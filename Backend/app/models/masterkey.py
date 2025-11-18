from app.core.DB.database import Base
from sqlalchemy import Column, BigInteger, Integer


class MasterKey(Base):
    __tablename__ = "master_key"
    master_key_id = Column(BigInteger, primary_key=True, index=True)
    key = Column(Integer, nullable=False)
