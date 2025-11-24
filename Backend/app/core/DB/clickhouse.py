from sqlalchemy import create_engine
from clickhouse_sqlalchemy import make_session

from app.core.config import settings

CLICKHOUSE_URL = (
    f"clickhouse+http://{settings.CHK_USER}:{settings.CHK_PASSWORD}"
    f"@{settings.CHK_HOST}:{settings.CHK_PORT}/{settings.CHK_DB}"
)
# CLICKHOUSE_URL = (
#     f"clickhouse+native://{settings.CHK_USER}:{settings.CHK_PASSWORD}" f"@{settings.CHK_HOST}:9000/{settings.CHK_DB}"
# )

ch_engine = create_engine(CLICKHOUSE_URL)


def get_clickhouse_db():
    db = make_session(ch_engine)
    try:
        yield db
    finally:
        db.close()
