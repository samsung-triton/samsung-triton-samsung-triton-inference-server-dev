from sqlalchemy.orm import Session
from sqlalchemy import text
from fastapi import status

from app.schemas.base_schema import BaseResponse
from app.core.customException import CustomHTTPException
from app.core.response_utils import create_response
from app.common.codes import CustomCode
from app.common.messages import Messages


def get_inference_notification_service(db: Session, page: int, size: int) -> BaseResponse:
    """
    ClickHouse의 logs.triton_error_logs에서
    ts, level, error_message만 가져와서
    페이지네이션해서 반환
    """
    try:
        offset = (page - 1) * size

        # 1) 실제 데이터 조회
        rows = db.execute(
            text(
                """
                SELECT
                    toDateTime64(ts, 6) AS ts,
                    level,
                    error_message
                FROM logs.triton_error_logs
                ORDER BY ts DESC
                LIMIT :limit OFFSET :offset
            """
            ),
            {"limit": size, "offset": offset},
        ).fetchall()

        items = [
            {
                "ts": row.ts.isoformat() if hasattr(row.ts, "isoformat") else str(row.ts),
                "level": row.level,
                "errorMessage": row.error_message,
            }
            for row in rows
        ]

        total = db.execute(text("SELECT count() AS c FROM logs.triton_error_logs")).scalar()

    except Exception as e:
        # ClickHouse 장애 → 503 응답
        raise CustomHTTPException(
            status_code=status.HTTP_503_SERVICE_UNAVAILABLE,
            code=CustomCode.ERR_503.value,
            message=Messages.NOTIFICATION_FETCH_ERROR.value,
            data={"error": str(e)},
        )

    finally:
        db.close()

    total_pages = (total + size - 1) // size if total else 0

    return create_response(
        CustomCode.NOTI_001.value,
        Messages.NOTIFICATION_FETCH_SUCCESS.value,
        data={
            "items": items,
            "page": page,
            "size": size,
            "total": total,
            "totalPages": total_pages,
        },
    )
