# --- Python Base ---
FROM python:3.12-slim

# 작업 디렉토리 설정
WORKDIR /app

# docker CLI 설치 추가
RUN apt-get update && apt-get install -y curl gnupg lsb-release && mkdir -p /etc/apt/keyrings && curl -fsSL https://download.docker.com/linux/debian/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg && echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/debian $(lsb_release -cs) stable" > /etc/apt/sources.list.d/docker.list && apt-get update && apt-get install -y docker-ce-cli docker-compose-plugin && rm -rf /var/lib/apt/lists/*

# 의존성 설치
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# 앱 전체 복사
COPY . .

# FastAPI 실행 (main.py는 Backend 루트에 있으므로 main:app)
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8080"]
