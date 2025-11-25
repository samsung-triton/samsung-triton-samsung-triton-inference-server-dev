# Triton inference server-Frontend
### 담당자: 김동욱, 김지은, 김성민

# 📘 Triton 관제 시스템 — Frontend 포팅 매뉴얼

*(Flutter Web 기반)*

---

# 1. 개요

본 문서는 Triton 관제 시스템의 **프론트엔드(Flutter Web)** 프로젝트를 새로운 환경에서 실행하거나 배포하기 위한 설정 및 구성 방법을 정리한 매뉴얼이다.

프로젝트 구조, 빌드 방법, API 설정, 배포 방식 등을 포함한다.

---

# 2. 요구 환경

## 2-1. 기술 스택

- **Framework:** Flutter 3.x (Web)
- **Language:** Dart
- **State Management:** GetX
- **Routing:** go_router
- **UI:** Flutter Web 기반 반응형 SPA

## 2-2. 실행 환경

| 구분 | 요구사항 |
| --- | --- |
| OS | Windows / macOS / Linux |
| 필수 | Flutter SDK 설치 |
| 브라우저 | Google Chrome |
| 선택 | VSCode |

---

# 3. 프로젝트 구조

아래 구조는 내부 프로젝트 구조를 기반으로 함.

```
Frontend/
└─ triton/
    ├─ lib/
    │   ├─ main.dart              # 앱 진입점
    │   ├─ router.dart            # 라우팅 설정
    │   ├─ controller/            # GetX 컨트롤러
    │   ├─ screen/                # 주요 화면 UI
    │   ├─ widgets/               # 공통 위젯 컴포넌트
    │   ├─ theme/                 # 색상/타이포그래피
    │   ├─ utils/                 # 공통 유틸리티 모듈
    │   ├─ service/ (optional)    # API 서비스 모듈
    ├─ assets/                    # 이미지/아이콘/폰트
    ├─ pubspec.yaml               # 패키지 의존성
    ├─ build/                     # 웹 빌드 결과물

```

---

# 4. API 설정

프론트엔드는 `.env` 파일을 사용하지 않으며, **API Base URL은 코드에서 직접 설정**된다.

다음 파일에서 서버 IP를 수정해야 한다.

### 예시)

`lib/utils/api_client.dart`:

```dart
final String baseUrl = "http://<BACKEND_IP>:<BACKEND_PORT>";

```

> 백엔드 주소 변경 시 반드시 Flutter build web 을 다시 실행해야 적용된다.
> 

---

# 5. 의존성 설치

최초 프로젝트 실행 전 아래 명령어를 수행한다.

```bash
cd Frontend/triton
flutter pub get

```

### 주요 패키지 목록

| 패키지 | 용도 |
| --- | --- |
| get | 상태관리/DI |
| go_router | 페이지 라우팅 |
| dropdown_button2 | 드롭다운 UI |
| flutter_svg | SVG 렌더링 |
| intl | 날짜/시간 포맷 |

---

# 6. 로컬 개발 실행

크롬 브라우저에서 웹앱을 실행:

```bash
flutter run -d chrome --web-port 3000

```

접속 URL:

```
http://localhost:3000/#/login

```

---

# 7. 빌드(배포용)

릴리즈용 웹 빌드를 생성:

```bash
flutter build web --release

```

출력 폴더:

```
build/web/

```

생성되는 파일 예:

- index.html
- main.dart.js
- flutter.js
- CanvasKit
- assets/*

이 폴더를 그대로 서버에 배포하면 된다.

---

# 8. 배포 방법

프론트엔드는 정적 웹 파일로 구성되어 있어 어떤 환경에서도 배포할 수 있다.

## 8-1. Nginx 배포

```bash
sudo cp -r build/web/* /usr/share/nginx/html/

```

## 8-2. Docker 배포 예시

```docker
FROM nginx:latest
COPY build/web /usr/share/nginx/html

```

## 8-3. AWS S3 / CloudFront 배포

- S3에 빌드 파일 업로드
- CloudFront로 CDN 구성
- 별도 API Gateway 필요 없음

---

# 9. 라우팅 구성

`go_router` 기반 라우터:

| 경로 | 설명 |
| --- | --- |
| `/login` | 로그인 |
| `/dashboard` | 서버/모델 대시보드 |
| `/model-manage` | 모델 관리 |
| `/triton-log` | 모델 로그 |
| `/server-log` | 서버 로그 |

Flutter Web의 Hash Routing 기준 실제 URL은 다음과 같다:

```
/#/login
/#/dashboard
/#/model-manage
/#/triton_log
/#/server-log

```

---

# 10. 주요 화면 기능 요약

## 10-1. 로그인 화면

- OPER / DEVEL 계정 구분
- 로그인 실패 시 메시지 출력

## 10-2. 헤더

- 서버 시작 / 중지 / 재시작
- 실시간 uptime 표시
- 페이지 라우팅 메뉴 제공

## 10-3. 대시보드

- GPU / VRAM / CPU / RAM 실시간 사용량
- 모델별 추론 통계
- Latency 분석
- Noti 로그 표시

## 10-4. 모델 관리

- 모델 리스트 표시
- 모델 등록 / 삭제
- 버전 등록 / 삭제
- config.pbtxt 편집 및 저장
- 롤백 기능 지원

## 10-5. Triton Log / Server Log

- 로그 조회
- 조건별 필터링
- txt 다운로드 기능 지원

---

# 11. 포팅 시 체크리스트

| 항목 | 상태 |
| --- | --- |
| Flutter SDK 설치 | ☐ |
| `flutter pub get` 실행 | ☐ |
| API base URL 확인 | ☐ |
| 백엔드 서버 실행 여부 확인 | ☐ |
| `flutter run` 또는 `flutter build web` | ☐ |
| 배포 서버에 정적 파일 업로드 | ☐ |

---

# 12. 주의사항

- API 주소 변경 시 반드시 **재빌드 필요**
- Chrome 사용 권장 (Safari/Firefox 일부 기능 미지원 사례 존재)
- Hash Routing 기반이므로 서버에서 URL Redirect 설정을 하지 않아야 함