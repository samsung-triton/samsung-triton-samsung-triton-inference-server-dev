# 🚀 Triton Inference Server 기반의 AI 모델 배포 및 운용 시스템 개발
> SSAFY 13기 자율 프로젝트 | 삼성전자 생산기술연구소 연계  

![Static Badge](https://img.shields.io/badge/Framework-Flutter-blue?logo=flutter)
![Static Badge](https://img.shields.io/badge/Backend-Python%20FastAPI-green?logo=python)
![Static Badge](https://img.shields.io/badge/Inference-Triton-orange?logo=nvidia)
![Static Badge](https://img.shields.io/badge/Database-PostgreSQL-blue?logo=postgresql)
![Static Badge](https://img.shields.io/badge/Cache-Redis-red?logo=redis)
![Static Badge](https://img.shields.io/badge/Deployment-Docker-lightgrey?logo=docker)

---

## 📘 프로젝트 개요
제조 설비별로 개별 운영되던 비전 AI 모델의 중복 GPU 사용 문제를 해결하기 위해  
**NVIDIA Triton Inference Server 기반의 AI 모델 배포 및 운용 시스템**을 개발합니다.  

본 시스템은 소규모 GPU 서버 환경에서 동작하며,  
모델 관리, 서버 모니터링, 로그 확인, 사용자 권한 제어 기능을 통합 제공합니다.

---

## 🎯 주요 기능

### 🖥️ Main Dashboard  
- 서버 가동 상태, 연결 상태, 활성화 모델 수, 추론 처리량 등 실시간 모니터링  
- 위젯 기반 UI 및 상태 시각화  

### 🧩 Model Repository Management  
- 모델 및 버전별 목록 조회, Load / Unload / 신규 등록 기능  
- 상태 표시 및 버전 관리  

### 📄 Log Viewer  
- Triton Inference Server 로그 실시간 스트리밍  
- 키워드 검색 및 필터 기능  

### 👥 User Authentication & Role Management  
- 로그인 / 회원가입 / 역할별 접근 제어  
- **Admin**: 모델 등록 및 설정 변경  
- **Operator**: 모니터링 전용 접근  

### ⚙️ Model Configuration Editor  
- 모델 설정 파일(`config.pbtxt`) 조회 및 수정  
- 수정 내용 즉시 반영 및 서버 재로딩  

---

## 🧱 시스템 아키텍처
```mermaid
graph LR
A[Web UI (Flutter)] --> B[Backend API (FastAPI)]
B --> C[(Triton Inference Server)]
B --> D[(Database: PostgreSQL)]
B --> E[(Cache: Redis)]
C --> F[Log Stream]
```

---

## 🛠️ 기술 스택

| 구분 | 사용 기술 |
|------|------------|
| Front-End | Flutter (Web) |
| Back-End | Python (FastAPI) |
| AI Inference | NVIDIA Triton Inference Server |
| Database | PostgreSQL |
| Cache | Redis |
| Deployment | Docker, Ubuntu 24.04 |
| Version Control | GitLab |

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

## 🧭 프로젝트 목표
- GPU 리소스 효율화를 위한 통합 추론 서버 구조 구축  
- 모델 관리 및 운영을 위한 직관적인 웹 UI 제공  
- 실시간 로그 및 서버 상태 모니터링 기능 구현  
- 유지보수와 확장이 용이한 시스템 아키텍처 설계  

---



> © 2025 SSAFY Team S302. All rights reserved.
