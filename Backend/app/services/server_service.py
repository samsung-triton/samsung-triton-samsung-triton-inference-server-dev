from sqlalchemy.orm import Session
from fastapi import status
from app.clients.gpu_router import get_triton_status, start_triton, stop_triton, restart_triton
from app.core.response_utils import create_response
from app.core.customException import CustomHTTPException
from app.models.server import Server, ServerStatus
from app.constants.codes import CustomCode
from app.constants.messages import Messages
from app.models.user import User


def get_user_or_404(db: Session, login_id: str) -> User:
    # 사용자 조회 (없으면 404 예외 발생)
    user = db.query(User).filter(User.login_id == login_id).first()
    if not user:
        raise CustomHTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            code=CustomCode.ERR_404.value,
            message=Messages.USER_NOT_FOUND.value,
        )
    return user


def _log_server_action(db: Session, user_id: int, status_enum: ServerStatus, description: str | None = None):
    server_log = Server(actor_id=user_id, status=status_enum, description=description)
    db.add(server_log)
    db.commit()


# Triton 서버 상태 조회
async def get_server_status_service(db: Session):
    # 현재 Triton 서버 상태 조회
    try:
        result = await get_triton_status()
        # BaseResponse 객체에서 속성으로 접근
        status_data = result.data if hasattr(result, "data") else {}
        is_ready = status_data.get("status") == "ready" if isinstance(status_data, dict) else False

        return create_response(
            CustomCode.DOCKER_004.value if is_ready else CustomCode.ERR_503.value,
            Messages.SERVER_READY.value if is_ready else Messages.SERVER_NOT_READY.value,
            status_data,
        )
    except Exception as e:
        raise CustomHTTPException(
            status_code=status.HTTP_503_SERVICE_UNAVAILABLE,
            code=CustomCode.ERR_503.value,
            message=f"서버 상태 조회 실패: {str(e)}",
            data={"status": "not_ready", "started_at": None},
        )


async def _execute_server_action(
    db: Session,
    actor_login_id: str,
    action_func,
    success_status: ServerStatus,
    dual_log: bool = False,
    description: str | None = None,  
):
    user = get_user_or_404(db, actor_login_id)

    try:
        result = await action_func()

        data = result.data if hasattr(result, "data") else {}
        code = result.code if hasattr(result, "code") else CustomCode.MASTER_001.value
        message = result.message if hasattr(result, "message") else ""

        if dual_log:
            db.add_all([
                Server(actor_id=user.user_id, status=ServerStatus.STOP, description=description),
                Server(actor_id=user.user_id, status=ServerStatus.START, description=description),
            ])
        else:
            _log_server_action(db, user.user_id, success_status, description)

        db.commit()

        return create_response(code, message, data)

    except CustomHTTPException:
        raise
    except Exception as e:
        raise CustomHTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            code=CustomCode.ERR_500.value,
            message=f"{success_status.value} 중 오류 발생: {str(e)}",
        )



# Triton 서버 시작
async def start_server_service(db: Session, actor_login_id: str):
    # Triton 서버 시작
    return await _execute_server_action(db, actor_login_id, start_triton, ServerStatus.START)


# Triton 서버 중지
async def stop_server_service(db: Session, actor_login_id: str, description: str | None = None):
    return await _execute_server_action(
        db,
        actor_login_id,
        stop_triton,
        ServerStatus.STOP,
        description=description,
    )

# Triton 서버 재시작
async def restart_server_service(db: Session, actor_login_id: str, description: str | None = None):
    return await _execute_server_action(
        db,
        actor_login_id,
        restart_triton,
        ServerStatus.START,
        dual_log=True,
        description=description,
    )