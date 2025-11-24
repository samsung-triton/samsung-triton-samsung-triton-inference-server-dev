import asyncio
import json
from app.common.base_sse import SSEBase


class PushSSEChannel(SSEBase):
    """
    Vector → FastAPI → Frontend
    실시간 PUSH SSE 채널
    """

    def __init__(self):
        super().__init__()

    async def publish(self, message: dict):
        """
        Vector가 보내온 로그를 모든 구독자에게 푸시
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
infer_log_channel = PushSSEChannel()
