import docker
import asyncio

subscribers = set()

def publish_event(message: str):
    """SSE 구독자들에게 상태 변화 push"""
    for queue in list(subscribers):
        try:
            queue.put_nowait(message)
        except:
            pass


async def docker_event_watcher(container_name: str):
    """Docker 이벤트 실시간 감시"""
    client = docker.from_env()
    loop = asyncio.get_event_loop()

    def _listen():
        for event in client.events(decode=True):
            if (
                event.get("Type") == "container" and
                event["Actor"]["Attributes"].get("name") == container_name
            ):
                status = event.get("status")
                publish_event(status)

    # blocking → thread에서 실행
    loop.run_in_executor(None, _listen)
