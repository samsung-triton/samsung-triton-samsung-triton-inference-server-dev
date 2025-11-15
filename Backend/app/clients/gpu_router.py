import subprocess
import json
from fastapi import status
from datetime import datetime

from app.core.response_utils import create_response
from app.core.customException import CustomHTTPException
from app.common.codes import CustomCode
from app.common.messages import Messages
from app.core.config import settings, TIMEZONE


def _run_compose(cmd: str, error_code, error_msg):
    try:
        result = subprocess.run(cmd, shell=True, check=True,
                                capture_output=True, text=True)
        return result.stdout.strip()
    except subprocess.CalledProcessError as e:
        raise CustomHTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            code=error_code,
            message=f"{error_msg}: {e.stderr.strip()}",
        )


def _compose_path() -> str:
    return f"-f {settings.TRITON_COMPOSE_PATH}"


async def get_triton_status():
    """Triton 컨테이너 상태 조회"""
    try:
        cmd = f"docker inspect {settings.TRITON_CONTAINER_NAME}"
        result = subprocess.run(cmd, shell=True,
                                capture_output=True, text=True)

        if result.returncode != 0 or not result.stdout.strip():
            return create_response(
                CustomCode.DOCKER_005.value,
                Messages.SERVER_NOT_READY.value,
                {"status": "stopped", "started_at": None},
            )

        info = json.loads(result.stdout)[0]
        state = info.get("State", {})
        is_running = state.get("Running", False)
        started_at_raw = state.get("StartedAt")

        # 변환
        started_at = None
        if started_at_raw and started_at_raw != "0001-01-01T00:00:00Z":
            started_at = (
                datetime.fromisoformat(started_at_raw.replace("Z", "+00:00"))
                .astimezone(TIMEZONE)
                .isoformat()
            )

        # running == ready 로 통일
        status_str = "ready" if is_running else "stopped"

        return create_response(
            CustomCode.DOCKER_004.value if is_running else CustomCode.DOCKER_005.value,
            Messages.SERVER_READY.value if is_running else Messages.SERVER_NOT_READY.value,
            {
                "status": status_str,
                "started_at": started_at,
            },
        )

    except Exception as e:
        raise CustomHTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            code=CustomCode.ERR_500.value,
            message=f"Triton 상태 조회 중 오류 발생: {str(e)}",
        )


async def start_triton():
    """Triton 컨테이너 시작"""
    status_result = await get_triton_status()
    current = status_result.data["status"]

    if current == "ready":
        return create_response(
            CustomCode.DOCKER_006.value,
            "이미 Triton이 실행 중입니다.",
            {"status": "ready"},
        )

    cmd = f"docker compose {_compose_path()} up -d"
    _run_compose(cmd, CustomCode.DOCKER_ERROR.value,
                 Messages.SERVER_START_ERROR.value)

    return create_response(
        CustomCode.DOCKER_006.value,
        Messages.SERVER_START_SUCCESS.value,
        {
            "status": "ready",
            "started_at": datetime.now(TIMEZONE).isoformat(),
        },
    )


async def stop_triton():
    cmd = f"docker compose {_compose_path()} down"
    _run_compose(cmd, CustomCode.DOCKER_ERROR.value,
                 Messages.SERVER_STOP_ERROR.value)

    return create_response(
        CustomCode.DOCKER_002.value,
        Messages.SERVER_STOP_SUCCESS.value,
        {"status": "stopped"},
    )


async def restart_triton():
    cmd = f"docker compose {_compose_path()} restart"
    _run_compose(cmd, CustomCode.DOCKER_ERROR.value,
                 Messages.SERVER_RESTART_ERROR.value)

    return create_response(
        CustomCode.DOCKER_003.value,
        Messages.SERVER_RESTART_SUCCESS.value,
        {
            "status": "ready",
            "started_at": datetime.now(TIMEZONE).isoformat(),
        },
    )
