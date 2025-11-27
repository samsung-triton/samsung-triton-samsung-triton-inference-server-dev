import docker
import asyncio
from app.core.response_utils import create_response
from app.common.codes import CustomCode
from app.common.messages import Messages
from datetime import datetime, timezone

subscribers = set()


def publish_event(message):
    """SSE 구독자들에게 push"""
    # BaseResponse → dict 로 변환
    if hasattr(message, "model_dump"):
        message = message.model_dump()

    for queue in list(subscribers):
        try:
            queue.put_nowait(message)
        except:
            pass


def convert_status(action: str):
    """
    GPU 서버 이벤트(Action) → 통일된 서버 상태로 변환
    """

    if action == "start":
        return "start"

    if action == "stop":
        return "stop"

    if action == "restart":
        return "restart"

    return None


def build_response(status: str):
    now_utc = datetime.now(timezone.utc).isoformat()

    if status == "start":
        return create_response(
            code=CustomCode.SSE_DOCKER_002.value,
            message=Messages.SSE_TRITON_START.value,
            data={"status": "start", "started_at": now_utc},
        )

    if status == "stop":
        return create_response(
            code=CustomCode.SSE_DOCKER_003.value, message=Messages.SSE_TRITON_STOP.value, data={"status": "stop"}
        )

    if status == "restart":
        return create_response(
            code=CustomCode.SSE_DOCKER_004.value,
            message=Messages.SSE_TRITON_RESTART.value,
            data={"status": "restart", "started_at": now_utc},
        )

    return None


async def docker_event_watcher(container_name: str):
    client = docker.from_env()
    loop = asyncio.get_event_loop()

    def _listen():
        for event in client.events(decode=True):
            if event.get("Type") != "container":
                continue

            actor = event.get("Actor", {})
            attrs = actor.get("Attributes", {})

            # 이름 매칭
            if attrs.get("name") != container_name:
                continue

            action = event.get("Action")  # GPU 서버는 status 대신 Action 사용

            unified_status = convert_status(action)

            if unified_status is None:
                continue

            resp = build_response(unified_status)
            publish_event(resp)

    loop.run_in_executor(None, _listen)
