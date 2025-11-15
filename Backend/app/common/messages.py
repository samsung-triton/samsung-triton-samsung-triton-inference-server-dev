from enum import Enum


class Messages(str, Enum):
    # ---- Master Key ----
    LOGIN_SUCCESS = "로그인이 성공적으로 완료되었습니다."
    INVALID_PARAM = "요청 파라미터가 올바르지 않습니다."
    INVALID_CREDENTIAL = "아이디 또는 비밀번호가 일치하지 않습니다."
    USER_NOT_FOUND = "해당 유저를 찾을 수 없습니다."

    # ---- Master Key ----
    MASTER_KEY_MATCH = "마스터 키가 일치합니다."
    MASTER_KEY_MISMATCH = "마스터 키가 일치하지 않습니다."

    # ---- Model List / Triton Ready ----
    MODEL_LIST_FETCH_SUCCESS = "모델 목록을 성공적으로 조회했습니다."
    TRITON_NOT_READY = "Triton Server가 준비되지 않았습니다."
    MODEL_LIST_FETCH_ERROR = "모델 목록 조회 중 오류가 발생했습니다."

    # ---- Model Register ----
    MODEL_REGISTER_SUCCESS = "모델이 성공적으로 등록되었습니다."
    MODEL_REGISTER_MISSING_REQUIRED = (
        "필수 입력값(modelName, modelType, description, config.pbtxt)을 모두 입력해야 합니다."
    )
    MODEL_REGISTER_INVALID_NAME = "모델 이름이 유효하지 않습니다."
    MODEL_REGISTER_DUPLICATE_NAME = "이미 동일한 이름의 모델이 존재합니다."
    MODEL_REGISTER_INVALID_FILE_NAME = "유효한 모델 파일 이름이 아닙니다."
    MODEL_REGISTER_UPLOAD_ERROR = "모델 파일 업로드 또는 등록 과정에서 오류가 발생했습니다."

    INVALID_ARCHIVE_FORMAT = "유효하지 않은 압축파일입니다. ZIP, TAR, TAR.GZ, TGZ 형식만 지원합니다."
    ARCHIVE_EXTRACTION_ERROR = "압축 파일 해제 중 오류가 발생했습니다."

    # ---- Ensemble Register ----
    ENSEMBLE_REGISTER_SUCCESS = "앙상블 모델이 성공적으로 등록되었습니다."
    ENSEMBLE_REGISTER_MISSING_REQUIRED = "필수 입력값 누락 (modelName, file, description)"
    ENSEMBLE_REGISTER_DUPLICATE_NAME = "동일 이름의 모델이 이미 존재함"
    ENSEMBLE_REGISTER_INVALID_FILE_TYPE = "파일 형식이 잘못됨 (config.pbtxt 아님)"
    ENSEMBLE_REGISTER_INTERNAL_ERROR = "모델 등록 중 내부 오류 발생"

    # ---- Model 공통 ----
    MODEL_NOT_FOUND = "해당 모델을 찾을 수 없습니다."
    MODEL_REGISTER_DB_ERROR = "DB 저장 중 오류가 발생했습니다. 이전의 모든 변경사항을 롤백했습니다."
    MODEL_DELETE_DB_ERROR = "DB 삭제 중 오류가 발생했습니다. 이전의 모든 변경사항을 롤백했습니다."

    # ---- Model Version ----
    MODEL_VERSION_ADD_SUCCESS = "모델 버전이 성공적으로 추가되었습니다."
    MODEL_VERSION_ADD_ERROR = "모델 버전 추가 중 오류가 발생했습니다."
    MODEL_VERSION_NOT_FOUND = "해당 모델 버전을 찾을 수 없습니다."
    MODEL_VERSION_DELETE_SUCCESS = "모델 버전이 성공적으로 삭제되었습니다."
    MODEL_VERSION_DELETE_SINGLE_FORBIDDEN = (
        "버전이 1개뿐인 모델은 삭제할 수 없습니다. 모델 전체를 삭제하거나 새 버전을 추가한 후 다시 시도하세요."
    )

    # ---- Model Delete ----
    MODEL_DELETE_SUCCESS = "모델이 성공적으로 삭제되었습니다."
    # MODEL_DELETE_LOADED_IN_TRITON = "현재 모델이 Triton Server에 로드되어 있어 삭제할 수 없습니다."
    MODEL_DELETE_SERVER_ERROR = "모델 삭제 처리 중 서버 오류가 발생했습니다."

    # ---- Triton 연결 및 응답 오류 ----
    TRITON_CONNECTION_ERROR = "Triton 서버와의 연결 또는 응답 오류로 인해 요청을 수행할 수 없습니다."
    TRITON_VERSION_READY_CHECK_ERROR = "Triton에서 모델 버전의 상태를 확인하는 중 오류가 발생했습니다."

    # ---- Model Load / Unload ----
    MODEL_LOAD_SUCCESS = "모델이 성공적으로 로드되었습니다."
    MODEL_LOAD_MISSING_NAME = "필수 입력값을 입력해야 합니다."
    MODEL_LOAD_ALREADY = "해당 모델은 이미 로드된 상태입니다."
    MODEL_LOAD_ERROR = "모델 로드 중 오류가 발생했습니다. Triton Server 로그를 확인하세요."

    MODEL_UNLOAD_SUCCESS = "모델이 성공적으로 언로드되었습니다."
    MODEL_UNLOAD_ALREADY = "해당 모델은 이미 언로드된 상태입니다."
    MODEL_UNLOAD_ERROR = "모델 언로드 중 오류가 발생했습니다. Triton Server 로그를 확인하세요."

    # ---- Server State / Config ----
    SERVER_READY = "서버가 준비 상태입니다."
    SERVER_NOT_READY = "서버가 준비되지 않았습니다."
    SERVER_START_SUCCESS = "서버가 성공적으로 시작되었습니다."
    SERVER_RESTART_SUCCESS = "서버가 성공적으로 재시작되었습니다."
    SERVER_START_ERROR = "서버 시작 중 오류가 발생했습니다."
    SERVER_STOP_SUCCESS = "서버가 성공적으로 중지되었습니다."
    SERVER_STOP_ERROR = "서버 중지 중 오류가 발생했습니다."
    SERVER_RESTART_ERROR = "서버 재시작 중 오류가 발생했습니다."

    CONFIG_CURRENT_FETCH_SUCCESS = "현재 사용 중인 Config가 조회되었습니다."
    CONFIG_HISTORY_FETCH_SUCCESS = "Config 이력 목록이 조회되었습니다."
    CONFIG_ONE_FETCH_SUCCESS = "선택한 Config 내용이 조회되었습니다."
    CONFIG_APPLY_SUCCESS = "새로운 Config가 저장되고 Triton 서버에 적용되었습니다."
    CONFIG_HISTORY_WITH_SELECTED_FETCH_SUCCESS = "Config 이력 및 선택된 Config가 조회되었습니다."
    CONFIG_DELETE_SUCCESS = "선택한 Config가 성공적으로 삭제되었습니다."

    # ---- Data / Inference ----
    INPUT_DATA_SAVE_SUCCESS = "입력 데이터 저장 완료"
    OUTPUT_DATA_SAVE_SUCCESS = "결과 데이터 저장 완료"
    INFERENCE_STATS_FETCH_SUCCESS = "추론 통계 조회 성공"
    INPUT_DATA_SAVE_FAIL = "입력 데이터 저장 중 오류 발생"
    OUTPUT_DATA_SAVE_FAIL = "결과 데이터 저장 중 오류 발생"
    UID_NOT_FOUND = "해당 UID를 찾을 수 없습니다"

    # ---- Metrics ----
    DASHBOARD_MODEL_LIST_SUCCESS = "대시보드용 모델 목록 조회 성공"
    SERVER_METRICS_FETCH_SUCCESS = "서버 실시간 메트릭 조회 성공"
    RESOURCE_TIMESERIES_FETCH_SUCCESS = "리소스 시계열 데이터 조회 성공"
    METRICS_INVALID_PERIOD = "지원하지 않는 period 값입니다. (허용: 1h, 6h, 24h)"
    PROMETHEUS_RANGE_QUERY_ERROR = "Prometheus Range Query 중 오류가 발생했습니다."
    SERVER_METRIC_FAIL = "서버 메트릭 조회 실패"
    PROMETHEUS_BAD_STATUS = "Prometheus 응답 상태가 올바르지 않습니다."
    PROMETHEUS_QUERY_FAIL = "Prometheus 메트릭 수집 중 오류 발생"
    MODEL_PER_STATUS_FETCH_SUCCESS = "모델 별 요청 통계 조회 성공"

    # ---- Logs (Model / Server) ----
    MODEL_LOG_FETCH_SUCCESS = "모델 로그 조회 성공"
    MODEL_LOG_REQUIRED_PARAMS = "model_name, start, end는 필수입니다."
    LOKI_MODEL_LOG_FETCH_ERROR = "Loki 모델 로그 조회 중 오류가 발생했습니다."

    SERVER_LOG_FETCH_SUCCESS = "서버 로그 조회 성공"
    SERVER_LOG_REQUIRED_PERIOD = "기간(start, end)은 필수입니다."
    LOKI_LOG_FETCH_ERROR = "Loki 로그 조회 중 오류가 발생했습니다."

    AGGREGATION_TIME_INIT_BY_CURRENT = "집계 기준 시각 파일이 없어 현재 시간을 기준으로 초기화했습니다."
    AGGREGATION_TIME_FETCH_SUCCESS = "집계 기준 시각 조회 성공"
    AGGREGATION_TIME_UPDATE_SUCCESS = "집계 기준 시각이 업데이트되었습니다."
