import subprocess
import json
from fastapi import status
from datetime import datetime

from app.core.customException import CustomHTTPException
from app.common.codes import CustomCode
from app.common.messages import Messages
from app.core.config import settings, TIMEZONE


def _run_compose(cmd: str):
    """docker compose 명령 실행 (raw), 실패시 CustomHTTPException 발생"""
    try:
        result = subprocess.run(cmd, shell=True, check=True, capture_output=True, text=True)
        return result.stdout.strip()
    except subprocess.CalledProcessError as e:
        raise CustomHTTPException(
            status_code=status.HTTP_503_SERVICE_UNAVAILABLE,
            code=CustomCode.DOCKER_ERROR.value,
            message=Messages.SERVER_DOCKER_COMMAND_ERROR.value,
            data={"error": e.stderr.strip()},
        )


def _compose_path() -> str:
    return f"-f {settings.TRITON_COMPOSE_PATH}"


async def get_triton_status():
    """Triton 컨테이너 상태 조회"""
    try:
        cmd = f"docker inspect {settings.TRITON_CONTAINER_NAME}"
        result = subprocess.run(cmd, shell=True, capture_output=True, text=True)

        if result.returncode != 0 or not result.stdout.strip():
            return {"status": "stopped", "started_at": None}

        info = json.loads(result.stdout)[0]
        state = info.get("State", {})
        is_running = state.get("Running", False)
        started_at_raw = state.get("StartedAt")

        # 변환
        started_at = None
        if started_at_raw and started_at_raw != "0001-01-01T00:00:00Z":
            started_at = datetime.fromisoformat(started_at_raw.replace("Z", "+00:00")).astimezone(TIMEZONE).isoformat()

        return {
            "status": "ready" if is_running else "stopped",
            "started_at": started_at,
        }

    except Exception as e:
        raise CustomHTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            code=CustomCode.ERR_500.value,
            message=Messages.SERVER_STATUS_FETCH_ERROR.value,
            data=str(e),
        )


async def start_triton():
    """Triton 컨테이너 시작"""
    cmd = f"docker compose {_compose_path()} up -d"
    _run_compose(cmd)
    return {"status": "ready", "started_at": datetime.now(TIMEZONE).isoformat()}


async def stop_triton():
    cmd = f"docker compose {_compose_path()} down"
    _run_compose(cmd)
    return {"status": "stopped"}


async def restart_triton():
    cmd = f"docker compose {_compose_path()} restart"
    _run_compose(cmd)
    return {"status": "ready", "started_at": datetime.now(TIMEZONE).isoformat()}
