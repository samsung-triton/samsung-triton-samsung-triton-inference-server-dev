from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker
from clickhouse_sqlalchemy import declarative_base

from app.core.config import settings

CLICKHOUSE_URL = (
    f"clickhouse+native://{settings.CHK_USER}:{settings.CHK_PASSWORD}"
    f"@{settings.CHK_HOST}:{settings.CHK_PORT}/{settings.CHK_DB}"
)

# ClickHouse 엔진
ch_engine = create_engine(CLICKHOUSE_URL)

# ClickHouse용 Session
ClickHouseSessionLocal = sessionmaker(bind=ch_engine)

# ClickHouse용 Base (Postgre Base랑 분리)
CHBase = declarative_base()


def get_clickhouse_db():
    db = ClickHouseSessionLocal()
    try:
        yield db
    finally:
        db.close()
