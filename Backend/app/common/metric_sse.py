import asyncio
import json
from typing import Optional
from fastapi.encoders import jsonable_encoder

from app.common.base_sse import SSEBase
from app.core.customException import CustomHTTPException


class SSEChannel(SSEBase):
    """
    - fetch_fn: async () -> dict (jsonable_encoder로 인코딩 가능한 객체)
    - interval_sec: polling 주기
    - subscribers: 각 클라이언트 별 asyncio.Queue[str] (JSON string)
    - poll_task: 백그라운드에서 fetch_fn을 주기적으로 호출하는 태스크
    """

    def __init__(self, fetch_fn, interval_sec: int):
        super().__init__()
        self.fetch_fn = fetch_fn
        self.interval_sec = interval_sec

        self._latest_payload: Optional[str] = None # JSON string
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
                # Poll 자체에서 예상치 못한 에러 발생 시 에러 이벤트 전파
                err_str = json.dumps(
                    {"error": f"polling failed: {e}"},
                    ensure_ascii=False,
                )
                await self._broadcast(err_str)

            await asyncio.sleep(self.interval_sec)
        
        # 구독자가 하나도 없으면 루프 종료 → 다음 ensure_polling에서 다시 시작 가능

    async def _broadcast(self, data_str: str):
        # queue에 put 실패하는 경우는 거의 없지만, 안전하게 제거
        for q in list(self.subscribers):
            try:
                await q.put(data_str)
            except Exception:
                # queue에 put 실패하는 경우는 거의 없지만, 안전하게 제거
                self.unsubscribe(q)
