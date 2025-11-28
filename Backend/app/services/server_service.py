from sqlalchemy.orm import Session
from fastapi import status

from app.clients.gpu_router import (
    get_triton_status,
    start_triton,
    stop_triton,
    restart_triton,
)
from app.core.response_utils import create_response
from app.core.customException import CustomHTTPException
from app.core.logger import extract_error
from app.models.server import Server, ServerStatus
from app.common.codes import CustomCode
from app.common.messages import Messages
from app.common.utils import get_user_or_404


async def get_server_status_service():
    try:
        result = await get_triton_status()
        is_ready = result.get("status") == "ready"
        return create_response(
            CustomCode.DOCKER_001.value,
            Messages.SERVER_READY.value if is_ready else Messages.SERVER_NOT_READY.value,
            result,
        )

    except CustomHTTPException:
        raise
    except Exception as e:
        raise CustomHTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            code=CustomCode.ERR_500.value,
            message=Messages.SERVER_STATUS_FETCH_ERROR.value,
            data={"error": extract_error(e)},
        )


def _log_server_action(db: Session, user_id: int, status_enum: ServerStatus, description: str = None):
    server_log = Server(actor_id=user_id, status=status_enum, description=description)
    db.add(server_log)
    db.commit()


async def _execute_server_action(
    db: Session,
    actor_login_id: str,
    action_func,
    success_status: ServerStatus,
    description: str = None,
):
    user = get_user_or_404(db, actor_login_id)

    # 상태 → 코드 매핑
    code_map = {
        ServerStatus.START: CustomCode.DOCKER_002.value,  # start 성공
        ServerStatus.STOP: CustomCode.DOCKER_003.value,  # stop 성공
        ServerStatus.RESTART: CustomCode.DOCKER_004.value,  # restart 성공
    }

    message_map = {
        ServerStatus.START: Messages.SERVER_START_SUCCESS.value,
        ServerStatus.STOP: Messages.SERVER_STOP_SUCCESS.value,
        ServerStatus.RESTART: Messages.SERVER_RESTART_SUCCESS.value,
    }

    try:
        result = await action_func()

        code = code_map[success_status]
        success_message = message_map[success_status]

        # 로그 저장
        _log_server_action(db, user.user_id, success_status, description)

        return create_response(code, success_message, result)

    except CustomHTTPException:
        raise
    except Exception as e:
        error_message_map = {
            ServerStatus.START: Messages.SERVER_START_ERROR.value,
            ServerStatus.STOP: Messages.SERVER_STOP_ERROR.value,
            ServerStatus.RESTART: Messages.SERVER_RESTART_ERROR.value,
        }

        raise CustomHTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            code=CustomCode.ERR_500.value,
            message=error_message_map[success_status],
            data={"error": extract_error(e)},
        )


async def start_server_service(db: Session, actor_login_id: str):
    current = await get_triton_status()
    curr_status = current.get("status")

    if curr_status == "ready":
        raise CustomHTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            code=CustomCode.ERR_400.value,  # 이미 실행 중
            message=Messages.SERVER_READY.value,
        )

    return await _execute_server_action(db, actor_login_id, start_triton, ServerStatus.START)


async def stop_server_service(db: Session, actor_login_id: str, description: str = None):
    current = await get_triton_status()
    curr_status = current.get("status")

    if curr_status == "stopped":
        raise CustomHTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            code=CustomCode.ERR_400,  # 이미 stopped
            message=Messages.SERVER_NOT_READY.value,
        )

    return await _execute_server_action(db, actor_login_id, stop_triton, ServerStatus.STOP, description)


async def restart_server_service(db: Session, actor_login_id: str, description: str = None):
    current = await get_triton_status()
    curr_status = current.get("status")

    if curr_status == "stopped":
        raise CustomHTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            code=CustomCode.ERR_400,  # 이미 stopped
            message=Messages.SERVER_NOT_READY.value,
        )

    return await _execute_server_action(db, actor_login_id, restart_triton, ServerStatus.RESTART, description)
