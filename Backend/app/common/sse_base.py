import asyncio


class SSEBase:
    """모든 SSE 채널이 공통으로 사용하는 subscribe / unsubscribe 로직"""

    def __init__(self):
        self.subscribers: set[asyncio.Queue] = set()

    def subscribe(self) -> asyncio.Queue:
        """클라이언트가 /stream 으로 들어오면 Queue 생성"""
        q = asyncio.Queue()
        self.subscribers.add(q)
        return q

    def unsubscribe(self, q: asyncio.Queue):
        """클라이언트가 끊긴 경우 subscriber 제거"""
        self.subscribers.discard(q)
