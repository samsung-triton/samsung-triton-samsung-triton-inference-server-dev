import asyncio
import json


class SSEChannel:
    """
    여러 클라이언트에게 SSE 메시지를 broadcast하기 위한 Channel 클래스.
    구독자(Queue)를 관리하고, publish 이벤트를 push하는 역할을 한다.
    """

    def __init__(self):
        self.subscribers = set()

    def subscribe(self):
        """
        SSE 연결 시 호출됨.
        클라이언트마다 개별 asyncio.Queue 생성.
        """
        queue = asyncio.Queue()
        self.subscribers.add(queue)
        return queue

    def unsubscribe(self, queue):
        """
        연결 종료 시 Queue를 제거
        """
        try:
            self.subscribers.remove(queue)
        except KeyError:
            pass

    async def publish(self, message: dict):
        """
        모든 구독자 Queue에 동일한 메시지를 push
        """
        data = json.dumps(message, ensure_ascii=False)

        dead_queues = []

        for queue in list(self.subscribers):
            try:
                await queue.put(data)
            except asyncio.QueueFull:
                dead_queues.append(queue)
            except Exception:
                dead_queues.append(queue)

        # 사용 불가한 Queue 제거
        for dq in dead_queues:
            self.unsubscribe(dq)

    async def generator(self, queue: asyncio.Queue):
        """
        FastAPI StreamingResponse 에 연결되는 제너레이터
        """
        try:
            while True:
                data = await queue.get()
                yield f"data: {data}\n\n"
        except asyncio.CancelledError:
            # 클라이언트 연결 종료
            self.unsubscribe(queue)
