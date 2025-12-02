# Triton Inference Server 기반 AI 모델 배포 및 운용 시스템

> SSAFY 13기 자율 프로젝트 | 삼성전자 생산기술연구소 연계

![Static Badge](https://img.shields.io/badge/Framework-Flutter-blue?logo=flutter)
![Static Badge](https://img.shields.io/badge/Backend-Python%20FastAPI-green?logo=python)
![Static Badge](https://img.shields.io/badge/Inference-Triton-orange?logo=nvidia)
![Static Badge](https://img.shields.io/badge/Database-PostgreSQL-blue?logo=postgresql)
![Static Badge](https://img.shields.io/badge/Monitoring-Prometheus-yellow?logo=prometheus)
![Static Badge](https://img.shields.io/badge/Logs-ClickHouse-lightgrey)
![Static Badge](https://img.shields.io/badge/Deployment-Docker-lightgrey?logo=docker)

---

## 📘 프로젝트 개요

NVIDIA Triton Inference Server 기반의 통합 모델 운영 환경을 제공하는 시스템입니다.  
제조 현장에서 개별 설비별로 분리·운영되던 비전 AI 모델의 중복 GPU 사용 문제를 해결하고,  
모델 관리, 서버 제어, 추론 이력, 로그 분석, 실시간 모니터링 기능을 하나의 플랫폼으로 제공합니다.

본 프로젝트는 **소규모 GPU 서버 환경(RTX 4090)**에서도 안정적인 운영이 가능하며  
폐쇄망(오프라인) 환경에서 설치·실행할 수 있도록 패키지화되어 있습니다.

---

## 🎯 주요 기능

### 🖥️ Main Dashboard
- Triton Server 상태(START/STOP/RESTART)
- GPU Utilization / VRAM / CPU / RAM 실시간 모니터링
- 로드된 모델 리스트 및 모델별 추론 통계 표시
- SSE(Server-Sent Events) 기반 실시간 데이터 스트리밍

### 🧩 Model Repository Management
- 모델 등록 / 삭제 / 버전 관리
- 버전별 모델 파일 업로드 및 대표 파일 관리
- 모델 설정(config.pbtxt → DB 저장) 버전 관리
- 설정 변경 이력 및 릴리즈 히스토리 관리

### 📄 Inference & Log Viewer
- 추론 요청·결과 이력 조회 (입력/출력 경로, 소요 시간, 상태)
- 추론 성공률, Request/Inference 통계 제공
- Vector → ClickHouse 연동으로 Triton 로그 실시간 저장
- 일반 로그 / 추론 로그 / 에러 로그 필터 조회

### 👥 User & Role Management
- 로그인 / 로그아웃
- 사용자 권한(OPER / DEVEL) 기반 화면 제어
- MasterKey 기반 서버 제어 보안

### ⚙️ System Monitoring
- Triton Metrics (HTTP 8002) 실시간 수집
- Prometheus 기반 GPU/CPU/RAM 메트릭 수집
- Backend SSE channel → Frontend UI 연동

---

## 🧱 시스템 아키텍처

![Architecture](/Backend/resource/아키텍처.png)

**주요 연동 흐름**
- Flutter 웹 UI가 FastAPI 백엔드와 REST API 및 SSE로 통신
- FastAPI가 Triton Server를 gRPC/HTTP로 제어
- Vector가 Docker 로그를 수집하여 ClickHouse에 저장
- Prometheus가 Triton 메트릭을 수집하여 모니터링 데이터 제공

---

## 🛠️ 기술 스택

### Front-End
- **Flutter Web**
  - REST API / SSE 기반 실시간 UI
  - Nginx Deployment

### Back-End
- **Python 3.12**
  - FastAPI, Pydantic, SQLAlchemy
  - Triton gRPC/HTTP Client
  - Docker Python SDK
  - ClickHouse Driver

### AI Inference
- **NVIDIA Triton Inference Server 24.10**
  - Explicit Model Loading
  - ONNX / TensorRT / PyTorch 모델 지원

### Database
- **PostgreSQL 16** (Application DB)
- **ClickHouse** (Log DB)

### Monitoring & Logging
- **Prometheus** (Metrics)
- **Vector** (Docker Log Collector)

### Deployment
- **Docker Engine 29.0.1**
- **Docker Compose 2.40.3**
- **Ubuntu 22.04.5 LTS**

---

## ⚙️ 시스템 요구 사양

| 구성 요소 | 요구 사양 |
|----------|----------|
| OS | Ubuntu 22.04.5 LTS |
| CPU | 최소 8 Core (GPU 서버는 NVIDIA GPU 필수) |
| RAM | 최소 32GB |
| GPU | NVIDIA RTX 4090 |
| Disk | 최소 200GB |
| Docker Engine | 29.0.1 |
| Docker Compose | 2.40.3 |
| CUDA | v12.7 |

---

## 👨‍💻 팀 구성

| 이름 | 역할 |
|------|------|
| 김동욱 | 팀장 · FE |
| 김성민 | FE장 |
| 김지은 | FE |
| 송민주 | BE |
| 안지윤 | BE |
| 조민재 | BE장 |

---



> © 2025 SSAFY Team S302. All rights reserved.
