# --- Python Base ---
FROM python:3.12-slim

# 작업 디렉토리 설정
WORKDIR /app

# 의존성 설치
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# 앱 전체 복사
COPY . .

# FastAPI 실행 (main.py는 Backend 루트에 있으므로 main:app)
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8080"]
