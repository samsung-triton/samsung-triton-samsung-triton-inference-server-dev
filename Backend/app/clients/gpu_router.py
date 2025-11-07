import subprocess
from datetime import datetime, timezone
from fastapi import status
from app.core.customException import CustomHTTPException
from app.constants.codes import CustomCode
from app.constants.messages import Messages
from app.core.config import settings


def _run_compose(cmd: str, success_code, success_msg, error_code, error_msg):
    # Docker Compose 명령 실행 공통 함수
    try:
        result = subprocess.run(cmd, shell=True, check=True, capture_output=True, text=True)
        return {
            "code": success_code,
            "message": success_msg,
            "data": {"stdout": result.stdout.strip()},
        }
    except subprocess.CalledProcessError as e:
        raise CustomHTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            code=error_code,
            message=f"{error_msg}: {e.stderr.strip()}",
        )


def _compose_path() -> str:
    # docker-compose.yml 경로를 환경변수에서 불러옴
    return f"-f {settings.TRITON_COMPOSE_PATH}"


# Triton 서버 상태 확인
async def get_triton_status():
    # 현재 Triton 컨테이너가 실행 중인지 확인
    cmd = f"docker ps --filter 'name={settings.TRITON_CONTAINER_NAME}' --format '{{{{.Names}}}}'"
    result = subprocess.run(cmd, shell=True, capture_output=True, text=True)
    is_running = settings.TRITON_CONTAINER_NAME in result.stdout.strip()

    return {
        "code": CustomCode.MASTER_001.value,
        "message": Messages.SERVER_READY.value if is_running else Messages.SERVER_NOT_READY.value,
        "data": {
            "status": "ready" if is_running else "stopped",
            "started_at": datetime.now(timezone.utc).isoformat() if is_running else None,
        },
    }


# Triton 서버 시작
async def start_triton():
    # Triton 컨테이너 실행 (중복 방지 포함)
    status_result = await get_triton_status()
    if status_result["data"]["status"] == "ready":
        return {
            "code": CustomCode.DOCKER_001.value,
            "message": "이미 Triton이 실행 중입니다.",
            "data": {"status": "running"},
        }

    cmd = f"docker compose {_compose_path()} up -d"
    result = _run_compose(
        cmd,
        CustomCode.MASTER_001.value,
        Messages.SERVER_START_SUCCESS.value,
        CustomCode.DOCKER_002.value,
        Messages.SERVER_START_ERROR.value,
    )
    result["data"].update({
        "status": "running",
        "started_at": datetime.now(timezone.utc).isoformat(),
    })
    return result


# Triton 서버 중지
async def stop_triton():
    # Triton 컨테이너 중지
    cmd = f"docker compose {_compose_path()} down"
    result = _run_compose(
        cmd,
        CustomCode.MASTER_001.value,
        Messages.SERVER_STOP_SUCCESS.value,
        CustomCode.DOCKER_001.value,
        Messages.SERVER_STOP_ERROR.value,
    )
    result["data"]["status"] = "stopped"
    return result


# Triton 서버 재시작
async def restart_triton():
    # Triton 컨테이너 재시작
    cmd = f"docker compose {_compose_path()} restart"
    result = _run_compose(
        cmd,
        CustomCode.MASTER_001.value,
        Messages.SERVER_RESTART_SUCCESS.value,
        CustomCode.DOCKER_004.value,
        Messages.SERVER_RESTART_ERROR.value,
    )
    result["data"].update({
        "status": "restart",
        "started_at": datetime.now(timezone.utc).isoformat(),
    })
    return result
