import httpx
import docker
from fastapi import status
from app.core.customException import CustomHTTPException
from app.constants.codes import CustomCode
from app.constants.messages import Messages

# Triton이 Docker로 올라갈 이름
TRITON_CONTAINER_NAME = "triton"
TRITON_IMAGE = "nvcr.io/nvidia/tritonserver:24.10-py3"

# GPU Agent URL (서버 모드에서는 외부 IP)
GPU_AGENT_URL = "http://84.2.204.41:9000"

# 로컬 실행 환경 플래그
USE_LOCAL = True  # 로컬에서 직접 제어

# 로컬 Docker 클라이언트
docker_client = docker.from_env()


# Triton 서버 제어하는 코드
async def call_gpu_agent(endpoint: str, method: str = "GET"):
    """
    Triton 서버의 상태를 제어하거나 확인하는 공용 함수.

    로컬 환경에서는 직접 Docker SDK로 컨테이너를 제어하고,
    서버 환경에서는 별도의 GPU Agent 서버에 HTTP 요청을 보냄.
    """
    if USE_LOCAL:
        try:
            # Triton 서버 상태 확인
            if endpoint == "/health":
                containers = docker_client.containers.list(filters={"name": TRITON_CONTAINER_NAME})
                if containers:
                    return {"status": "ok", "message": "Triton is running"}
                else:
                    return {"status": "stopped", "message": "Triton is not running"}

            # Triton 서버 시작
            elif endpoint == "/server/start":
                # 이미 실행 중인 컨테이너가 있으면 중복 실행 방지하는 코드
                containers = docker_client.containers.list(filters={"name": TRITON_CONTAINER_NAME})
                if containers:
                    return {"message": "Triton is already running."}
                
                # runtime='nvidia' : GPU 리소스 사용 가능하게 설정
                # network='monitoring-net' : 모니터링 스택(Grafana, Loki 등)과 통신 가능하게 함
                # volume 매핑 : 모델 디렉터리를 컨테이너 내부로 연결
                docker_client.containers.run(
                    TRITON_IMAGE,
                    name=TRITON_CONTAINER_NAME,
                    command="tritonserver --model-repository=/models --model-control-mode=explicit",
                    runtime="nvidia",
                    detach=True,
                    network="monitoring-net",
                    ports={"8000/tcp": 8000, "8001/tcp": 8001, "8002/tcp": 8002},
                    volumes={
                        "/home/test1234/S13P31S302/triton/models": {"bind": "/models", "mode": "rw"},
                    },
                )
                return {"message": "Triton started successfully."}

            # Triton 서버 중지
            elif endpoint == "/server/stop":
                containers = docker_client.containers.list(filters={"name": TRITON_CONTAINER_NAME})
                if not containers:
                    return {"message": "Triton is not running."}

                # 실행 중인 Triton 컨테이너를 모두 정지 및 제거
                for container in containers:
                    container.stop()
                    container.remove()
                return {"message": "Triton stopped successfully."}

            # Triton 서버 재시작
            elif endpoint == "/server/restart":
                 # 기존 컨테이너 정지 및 삭제 후 다시 실행
                containers = docker_client.containers.list(filters={"name": TRITON_CONTAINER_NAME})
                if containers:
                    for container in containers:
                        container.stop()
                        container.remove()

                docker_client.containers.run(
                    TRITON_IMAGE,
                    name=TRITON_CONTAINER_NAME,
                    command="tritonserver --model-repository=/models --model-control-mode=explicit",
                    runtime="nvidia",
                    detach=True,
                    network="monitoring-net",
                    ports={"8000/tcp": 8000, "8001/tcp": 8001, "8002/tcp": 8002},
                    volumes={
                        "/home/test1234/S13P31S302/triton/models": {"bind": "/models", "mode": "rw"},
                    },
                )
                return {"message": "Triton restarted successfully."}

            # 잘못된 엔드포인트
            else:
                raise CustomHTTPException(
                    status_code=status.HTTP_404_NOT_FOUND,
                    code=CustomCode.ERR_404.value,
                    message="Invalid endpoint",
                )
            
        # Docker 클라이언트 관련 예외 처리
        except docker.errors.DockerException as e:
            raise CustomHTTPException(
                status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
                code=CustomCode.ERR_500.value,
                message=f"Docker error: {str(e)}",
            )

    else:
        # 원격 GPU Agent 제어
        # GPU Agent 서버로 HTTP 요청 전송
        # (로컬 대신 GPU 서버에서 Triton 컨테이너를 제어)
        url = f"{GPU_AGENT_URL}{endpoint}"
        try:
            async with httpx.AsyncClient(timeout=30) as client:
                res = await client.request(method, url)
                if res.status_code == 200:
                    return res.json()

                raise CustomHTTPException(
                    status_code=res.status_code,
                    code=CustomCode.ERR_500.value,
                    message=f"GPU Agent 요청 실패: {res.text}",
                )
            
        # 네트워크/연결 예외 처리
        except httpx.RequestError as e:
            raise CustomHTTPException(
                status_code=status.HTTP_503_SERVICE_UNAVAILABLE,
                code=CustomCode.ERR_503.value,
                message=f"GPU Agent 연결 실패: {str(e)}",
            )
