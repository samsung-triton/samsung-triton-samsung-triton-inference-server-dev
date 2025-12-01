from enum import Enum


class CustomCode(str, Enum):
    # 에러 처리
    ERR_400 = "ERR-400"  # 잘못된 요청
    ERR_401 = "ERR-401"  # 저장된 정보와 불일치
    ERR_404 = "ERR-404"  # 정보를 찾을 수 없음
    ERR_409 = "ERR-409"  # 중복
    ERR_500 = "ERR-500"  # 내부오류
    ERR_503 = "ERR-503"  #

    # 로그인
    AUTH_001 = "AUTH-001"  # 로그인 성공

    # 마스터키
    MASTER_001 = "MASTER-001"  # 마스터키 일치 여부 확인 성공

    # 도커 실행( 서버 )
    DOCKER_ERROR = "DOCKER-ERROR"  # 도커 제어 관련 에러 발생
    DOCKER_001 = "DOCKER-001"  # 트리톤 도커 실행 상태 조회 성공
    DOCKER_002 = "DOCKER-002"  # 트리톤 도커 시작 성공
    DOCKER_003 = "DOCKER-003"  # 트리톤 도커 중지 성공
    DOCKER_004 = "DOCKER-004"  # 트리톤 도커 재시작 성공

    # 대시보드 관리
    DASH_001 = "DASH-001"  # 서버 gpu, cpu util 조회 성공
    DASH_002 = "DASH-002"  # 서버 ram, vram 조회 성공
    DASH_003 = "DASH-003"  # 대시보드 모델 목록 조회 성공
    DASH_004 = "DASH-004"  # 모델별 추론 결과 조회 성공
    DASH_005 = "DASH-005"  # 모델별 추론 레이턴시 조회 성공

    # 기준 시간 관리
    STANDARD_TIME_001 = "STANDARD-TIME-001"  # 기준 시간 조회 성공
    STANDARD_TIME_002 = "STANDARD-TIME-002"  # 기준 시간 설정 성공

    # Noticiation
    NOTI_001 = "NOTI-001"  # notification 응답 완료

    # triton 모델 관리
    MODEL_001 = "MODEL-001"  # 모델 목록 조회 성공
    MODEL_002 = "MODEL-002"  # 모델의 버전 목록 및 현재 config 조회
    MODEL_003 = "MODEL-003"  # 일반 모델 최초 등록 성공 # 앙상블 모델 등록 성공
    MODEL_004 = "MODEL-004"  # 앙상블 모델 등록 성공
    MODEL_005 = "MODEL-005"  # 기존 모델에 버전 추가 성공
    MODEL_006 = "MODEL-006"  # 모델의 버전 삭제 성공
    MODEL_007 = "MODEL-007"  # 모델 전제 삭제 성공

    # config 파일 관리
    CONFIG_001 = "CONFIG-001"  # 모델 별 현재 포함 모든 Config들의 전체 내용 반환
    CONFIG_002 = "CONFIG-002"  # 모델의 config 수정 성공
    CONFIG_003 = "CONFIG-003"  # 모델의 config 삭제 성공

    # 로그 관리
    LOG_001 = "LOG-001"  # api 로그 응답 완료
    LOG_002 = "LOG-002"  # 모델 로그의 model_name 리스트 조회 성공
    LOG_003 = "LOG-003"  # 모델 로그 조회 성공
    LOG_004 = "LOG-004"  # 서버 로그 조회 성공

    # 모델 추론
    INFERENCE_001 = "INFERENCE-001"  # 추론 전 입력 데이터 저장 성공
    INFERENCE_002 = "INFERENCE-002"  # 추론 후 결과 데이터 저장 성공
    INFERENCE_003 = "INFERENCE-003"  # 추론 후 결과 바이너리 데이터 저장 성공

    #SSE
    SSE_DOCKER_002 = "SSE-TRITON-START"
    SSE_DOCKER_003 = "SSE-TRITON-STOP"
    SSE_DOCKER_004 = "SSE-TRITON-RESTART"

    # Heartbeat
    HEARTBEAT_001 = "HEARTBEAT-001"  # heartbeat 응답 완료
