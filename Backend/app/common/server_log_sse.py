import asyncio
import json
from app.common.base_sse import SSEBase


class ServerLogSSEChannel(SSEBase):
    """
    Vector → FastAPI → Frontend
    서버 로그 PUSH SSE 채널
    """

    def __init__(self):
        super().__init__()

    async def publish(self, message: dict):
        """
        Vector에서 넘어온 서버 로그를 모든 구독자에게 Push
        """
        data_str = json.dumps(message, ensure_ascii=False)

        dead = []
        for q in list(self.subscribers):
            try:
                await q.put(data_str)
            except Exception:
                dead.append(q)

        for dq in dead:
            self.unsubscribe(dq)

    async def generator(self, q: asyncio.Queue):
        """
        StreamingResponse generator
        """
        try:
            while True:
                data = await q.get()
                yield f"data: {data}\n\n"
        except asyncio.CancelledError:
            self.unsubscribe(q)


# 실제 사용 인스턴스
server_log_channel = ServerLogSSEChannel()
