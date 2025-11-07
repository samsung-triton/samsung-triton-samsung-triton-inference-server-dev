from sqlalchemy.orm import Session
from datetime import datetime, timezone
from app.api.v1.gpu_router import call_gpu_agent
from app.core.response_utils import create_response
from app.core.customException import CustomHTTPException
from app.models.server import Server, ServerStatus
from app.constants.codes import CustomCode
from app.constants.messages import Messages
from app.models.user import User
from fastapi import status


# 상태 조회
async def get_server_status_service(db: Session):
    try:
        # Triton 서버 상태를 GPU Agent(Docker)로부터 조회
        result = await call_gpu_agent("/health", "GET")
        # 응답 내용에 "ok" 문자열이 포함되면 서버가 실행 중이라고 판단함
        is_ready = result and "ok" in str(result).lower()

        return create_response(
            CustomCode.DOCKER_004.value if is_ready else CustomCode.ERR_503.value,
            Messages.SERVER_READY.value if is_ready else Messages.SERVER_NOT_READY.value,
            {
                "status": "ready" if is_ready else "not_ready",
                "started_at": datetime.now(timezone.utc).isoformat() if is_ready else None,
            },
        )
    except Exception:
        # GPU Agent 연결 실패나 Docker 오류 시 503(Service Unavailable)
        raise CustomHTTPException(
            status_code=status.HTTP_503_SERVICE_UNAVAILABLE,
            code=CustomCode.ERR_503.value,
            message=Messages.SERVER_NOT_READY.value,
            data={"status": "not_ready", "started_at": None},
        )


# 서버 시작
async def start_server_service(db: Session, actor_login_id: str):
    # 서버 제어를 요청한 사용자가 존재하는지 확인
    user = db.query(User).filter(User.login_id == actor_login_id).first()
    if not user:
        raise CustomHTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            code=CustomCode.ERR_404.value,
            message=Messages.USER_NOT_FOUND.value,
        )

    try:
        # Triton 서버 시작 요청
        await call_gpu_agent("/server/start", "POST")

        # 시작 이력을 DB(server 테이블)에 저장, user_id를 actor_id로 기록
        record = Server(actor_id=user.user_id, status=ServerStatus.START)
        db.add(record)
        db.commit()
        db.refresh(record)

        return create_response(
            CustomCode.DOCKER_001.value,
            Messages.SERVER_START_SUCCESS.value,
            {"status": "running", "started_at": datetime.now(timezone.utc).isoformat()},
        )

    except Exception as e:
        # Docker 실행 오류, 통신 실패 등 예외 처리
        raise CustomHTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            code=CustomCode.ERR_500.value,
            message=f"서버 시작 실패: {str(e)}",
        )


# 서버 중지
async def stop_server_service(db: Session, actor_login_id: str):
    user = db.query(User).filter(User.login_id == actor_login_id).first()
    if not user:
        raise CustomHTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            code=CustomCode.ERR_404.value,
            message=Messages.USER_NOT_FOUND.value,
        )

    try:
        await call_gpu_agent("/server/stop", "POST")
        # 중지 이력을 DB(server 테이블)에 저장, user_id를 actor_id로 기록
        record = Server(actor_id=user.user_id, status=ServerStatus.STOP)
        db.add(record)
        db.commit()
        db.refresh(record)

        return create_response(
            CustomCode.DOCKER_002.value,
            Messages.SERVER_STOP_SUCCESS.value,
            {"status": "stopped"},
        )

    except Exception as e:
        raise CustomHTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            code=CustomCode.ERR_500.value,
            message=f"서버 중지 실패: {str(e)}",
        )


# 서버 재시작
async def restart_server_service(db: Session, actor_login_id: str):
    user = db.query(User).filter(User.login_id == actor_login_id).first()
    if not user:
        raise CustomHTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            code=CustomCode.ERR_404.value,
            message=Messages.USER_NOT_FOUND.value,
        )

    try:
        await call_gpu_agent("/server/restart", "POST")
        # 재시작 이력을 DB(server 테이블)에 저장, STOP과 START 두 개의 기록을 남김
        db.add_all([
            Server(actor_id=user.user_id, status=ServerStatus.STOP),
            Server(actor_id=user.user_id, status=ServerStatus.START),
        ])
        db.commit()

        return create_response(
            CustomCode.DOCKER_003.value,
            Messages.SERVER_RESTART_SUCCESS.value,
            {"status": "restart", "stopped_at": datetime.now(timezone.utc).isoformat()},
        )

    except Exception as e:
        raise CustomHTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            code=CustomCode.ERR_500.value,
            message=f"서버 재시작 실패: {str(e)}",
        )
