from sqlalchemy.orm import Session
from fastapi import status
from datetime import datetime

from app.clients.gpu_router import (
    get_triton_status,
    start_triton,
    stop_triton,
    restart_triton,
)
from app.core.response_utils import create_response
from app.core.customException import CustomHTTPException
from app.models.server import Server, ServerStatus
from app.common.codes import CustomCode
from app.common.messages import Messages
from app.core.config import TIMEZONE
from app.common.utils import get_user_or_404


def _log_server_action(db: Session, user_id: int, status_enum: ServerStatus, description: str = None):
    server_log = Server(actor_id=user_id, status=status_enum, description=description)
    db.add(server_log)
    db.commit()


async def get_server_status_service(db: Session):
    try:
        result = await get_triton_status()
        status_data = result.data

        is_ready = status_data.get("status") == "ready"

        return create_response(
            CustomCode.DOCKER_004.value if is_ready else CustomCode.DOCKER_005.value,
            Messages.SERVER_READY.value if is_ready else Messages.SERVER_NOT_READY.value,
            status_data,
        )

    except Exception as e:
        raise CustomHTTPException(
            status_code=status.HTTP_503_SERVICE_UNAVAILABLE,
            code=CustomCode.ERR_503.value,
            message=f"서버 상태 조회 실패: {str(e)}",
            data={"status": "stopped", "started_at": None},
        )


async def _execute_server_action(
    db: Session,
    actor_login_id: str,
    action_func,
    success_status: ServerStatus,
    description: str = None,
):
    user = get_user_or_404(db, actor_login_id)

    try:
        result = await action_func()
        data = result.data
        message = result.message

        # 상태 → 코드 매핑
        code_map = {
            ServerStatus.START: CustomCode.DOCKER_006.value,
            ServerStatus.STOP: CustomCode.DOCKER_002.value,
            ServerStatus.RESTART: CustomCode.DOCKER_003.value,
        }
        code = code_map[success_status]

        # 로그 저장
        _log_server_action(db, user.user_id, success_status, description)

        # restart → started_at 갱신
        if success_status == ServerStatus.RESTART:
            data["started_at"] = datetime.now(TIMEZONE).isoformat()

        return create_response(code, message, data)

    except CustomHTTPException:
        raise
    except Exception as e:
        raise CustomHTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            code=CustomCode.DOCKER_ERROR.value,
            message=f"{success_status.value} 중 오류 발생: {str(e)}",
        )


async def start_server_service(db: Session, actor_login_id: str):
    return await _execute_server_action(db, actor_login_id, start_triton, ServerStatus.START)


async def stop_server_service(db: Session, actor_login_id: str, description: str = None):
    return await _execute_server_action(db, actor_login_id, stop_triton, ServerStatus.STOP, description)


async def restart_server_service(db: Session, actor_login_id: str, description: str = None):
    return await _execute_server_action(db, actor_login_id, restart_triton, ServerStatus.RESTART, description)
