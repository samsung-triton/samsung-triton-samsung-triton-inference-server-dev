import asyncio
import json
from typing import Optional
from fastapi.encoders import jsonable_encoder

from app.common.base_sse import SSEBase
from app.core.customException import CustomHTTPException


class SSEChannel(SSEBase):
    """
    polling 기반 SSE 채널 (metrics 등에 사용)
    """

    def __init__(self, fetch_fn, interval_sec: int):
        super().__init__()
        self.fetch_fn = fetch_fn
        self.interval_sec = interval_sec

        self._latest_payload: Optional[str] = None
        self._poll_task: Optional[asyncio.Task] = None
        self._lock = asyncio.Lock()

    async def ensure_polling(self):
        async with self._lock:
            if self._poll_task is None or self._poll_task.done():
                self._poll_task = asyncio.create_task(self._poll_loop())

    async def _poll_loop(self):
        while self.subscribers:
            try:
                try:
                    resp = await self.fetch_fn()
                    payload = jsonable_encoder(resp)
                except CustomHTTPException as e:
                    payload = {"error": e.message, "code": e.code}
                except Exception as e:
                    payload = {"error": str(e)}

                data_str = json.dumps(payload, ensure_ascii=False)

                if data_str != self._latest_payload:
                    self._latest_payload = data_str
                    await self._broadcast(data_str)

            except Exception as e:
                err_str = json.dumps(
                    {"error": f"polling failed: {e}"},
                    ensure_ascii=False,
                )
                await self._broadcast(err_str)

            await asyncio.sleep(self.interval_sec)

    async def _broadcast(self, data_str: str):
        for q in list(self.subscribers):
            try:
                await q.put(data_str)
            except Exception:
                self.unsubscribe(q)
