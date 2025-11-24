# common/sse_push_channel.py
import asyncio
import json
from app.common.sse_base import SSEBase


class PushSSEChannel(SSEBase):
    """
    Vector → FastAPI → Frontend
    공통 PUSH SSE 채널
    """

    def __init__(self):
        super().__init__()

    async def publish(self, message: dict):
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
        try:
            while True:
                data = await q.get()
                yield f"data: {data}\n\n"
        except asyncio.CancelledError:
            self.unsubscribe(q)
