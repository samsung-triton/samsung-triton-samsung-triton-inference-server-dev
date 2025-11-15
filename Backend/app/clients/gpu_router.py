import subprocess
import json
from datetime import datetime
from app.core.response_utils import create_response
from fastapi import status
from datetime import datetime

from app.core.response_utils import create_response
from app.core.customException import CustomHTTPException
from app.common.codes import CustomCode
from app.common.messages import Messages
from app.core.config import settings
from app.core.config import TIMEZONE


def _run_compose(cmd: str, error_code, error_msg):
    # Docker Compose 명령 실행 공통 함수
    try:
        result = subprocess.run(cmd, shell=True, check=True, capture_output=True, text=True)
        return result.stdout.strip()
    except subprocess.CalledProcessError as e:
        raise CustomHTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            code=error_code,
            message=f"{error_msg}: {e.stderr.strip()}",
        )


def _compose_path() -> str:
    # docker-compose.yml 경로를 환경변수에서 불러옴
    return f"-f {settings.TRITON_COMPOSE_PATH}"


async def get_triton_status():
    """Triton 컨테이너의 실제 상태 및 시작 시각을 조회"""
    try:
        # 컨테이너 이름 기준으로 Docker inspect 실행
        inspect_cmd = f"docker inspect {settings.TRITON_CONTAINER_NAME}"
        result = subprocess.run(inspect_cmd, shell=True, capture_output=True, text=True)

        if result.returncode != 0 or not result.stdout.strip():
            # 컨테이너가 존재하지 않거나 중지된 상태
            return create_response(
                CustomCode.ERR_503.value,
                Messages.SERVER_NOT_READY.value,
                {"status": "stopped", "started_at": None},
            )

        container_info = json.loads(result.stdout)[0]
        state = container_info.get("State", {})
        is_running = state.get("Running", False)
        started_at_raw = state.get("StartedAt")

        # UTC → 한국시간 변환
        started_at = None
        if started_at_raw and started_at_raw != "0001-01-01T00:00:00Z":
            started_at = (
                datetime.fromisoformat(started_at_raw.replace("Z", "+00:00"))
                .astimezone(TIMEZONE)
                .isoformat()
            )

        data = {
            "status": "ready" if is_running else "stopped",
            "started_at": started_at,
        }

        return create_response(
            CustomCode.MASTER_001.value,
            Messages.SERVER_READY.value if is_running else Messages.SERVER_NOT_READY.value,
            data,
        )

    except Exception as e:
        raise CustomHTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            code=CustomCode.ERR_500.value,
            message=f"Triton 상태 조회 중 오류 발생: {str(e)}",
        )

# Triton 서버 시작
async def start_triton():
    # Triton 컨테이너 실행 (중복 방지 포함)
    status_result = await get_triton_status()

    status_data = status_result.data if hasattr(status_result, "data") else {}
    current_status = status_data.get("status") if isinstance(status_data, dict) else None

    if current_status == "ready":
        return create_response(
            CustomCode.DOCKER_001.value,
            "이미 Triton이 실행 중입니다.",
            {"status": "running"},
        )

    cmd = f"docker compose {_compose_path()} up -d"
    _run_compose(  # 질문
        cmd,
        CustomCode.DOCKER_ERROR.value,
        Messages.SERVER_START_ERROR.value,
    )
    return create_response(
        CustomCode.DOCKER_001.value,
        Messages.SERVER_START_SUCCESS.value,
        {
            "status": "running",
            "started_at": datetime.now(TIMEZONE).isoformat(),
        },
    )


# Triton 서버 중지
async def stop_triton():
    """Triton 서버 컨테이너 중지"""
    cmd = f"docker compose {_compose_path()} down"
    _run_compose(
        cmd,
        CustomCode.DOCKER_ERROR.value,
        Messages.SERVER_STOP_ERROR.value,
    )
    return create_response(
        CustomCode.DOCKER_002.value,
        Messages.SERVER_STOP_SUCCESS.value,
        {"status": "stopped"},
    )


# Triton 서버 재시작
async def restart_triton():
    """Triton 서버 컨테이너 재시작"""
    cmd = f"docker compose {_compose_path()} restart"
    _run_compose(
        cmd,
        CustomCode.DOCKER_ERROR.value,
        Messages.SERVER_RESTART_ERROR.value,
    )

    return create_response(
        CustomCode.DOCKER_003.value,
        Messages.SERVER_RESTART_SUCCESS.value,
        {
            "status": "restart",
            "started_at": datetime.now(TIMEZONE).isoformat(),
        },
    )
