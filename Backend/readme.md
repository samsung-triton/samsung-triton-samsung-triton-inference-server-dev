# 백엔드 (FastAPI + Triton gRPC)

### ⚠️ 개발 환경 안내
- 현재 개발 브랜치: backend
- 모든 명령어는 프로젝트 루트(Backend) 기준
- 권장 Python: 3.10+
- Triton 서버(gRPC 기본 포트 8001)가 별도 환경에서 실행 중이어야 함

### 📁 프로젝트 구조
```
Backend/
├── main.py
├── .env
├── requirements.txt
└── app/
    ├── api/
    │   └── v1/
    │       ├── endpoints/
    │       │   ├── server.py      
    │       │   └── models.py      
    │       └── routers.py         # /api/v1 라우터 묶음
    ├── clients/
    │   ├── triton_grpc.py         # Triton gRPC 얇은 래퍼(동기)
    │   └── triton_metrics.py      # Prometheus metrics 수집
    ├── services/
    │   └── health_meta_service.py # health/meta/model_ready 서비스
    └── schemas/
        └── server.py              # Pydantic DTO
```
팁: app/** 하위 폴더에 __init__.py(빈 파일) 추가 권장.

### 📦 환경 세팅
1) (권장) Conda 가상환경 생성 및 활성화
Backend 폴더에서
```
conda create -n s302 python=3.11 -y
conda activate s302
```

2) 필수 패키지 설치
```
pip install -r requirements.txt
```

3) Backend/.env 파일 생성

### ▶️ 서버 실행
    uvicorn main:app --reload

or

    uvicorn main:app --reload --log-level debug

- 앱: http://127.0.0.1:8000
- Swagger UI: http://127.0.0.1:8000/docs
- ReDoc: http://127.0.0.1:8000/redoc