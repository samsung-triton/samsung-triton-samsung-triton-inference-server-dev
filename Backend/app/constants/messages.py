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

    # ---- Ensemble Register ----
    ENSEMBLE_REGISTER_SUCCESS = "앙상블 모델이 성공적으로 등록되었습니다."
    ENSEMBLE_REGISTER_MISSING_REQUIRED = "필수 입력값 누락 (modelName, file, description)"
    ENSEMBLE_REGISTER_DUPLICATE_NAME = "동일 이름의 모델이 이미 존재함"
    ENSEMBLE_REGISTER_INVALID_FILE_TYPE = "파일 형식이 잘못됨 (config.pbtxt 아님)"
    ENSEMBLE_REGISTER_INTERNAL_ERROR = "모델 등록 중 내부 오류 발생"

    # ---- Model 공통 ----
    MODEL_NOT_FOUND_FOUND = "해당 모델을 찾을 수 없습니다."

    # ---- Model Version ----
    MODEL_VERSION_ADD_SUCCESS = "모델 버전이 성공적으로 추가되었습니다."
    MODEL_VERSION_ADD_ERROR = "모델 버전 추가 중 오류가 발생했습니다."

    # ---- Model Delete ----
    MODEL_DELETE_SUCCESS = "모델이 성공적으로 삭제되었습니다."
    MODEL_DELETE_LOADED_IN_TRITON = "현재 모델이 Triton Server에 로드되어 있어 삭제할 수 없습니다."
    MODEL_DELETE_SERVER_ERROR = "모델 삭제 처리 중 서버 오류가 발생했습니다."

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

    # ---- Data / Inference ----
    INPUT_DATA_SAVE_SUCCESS = "입력 데이터 저장 완료"
    OUTPUT_DATA_SAVE_SUCCESS = "결과 데이터 저장 완료"
    INFERENCE_STATS_FETCH_SUCCESS = "추론 통계 조회 성공"
    INPUT_DATA_SAVE_FAIL = "입력 데이터 저장 중 오류 발생"
    OUTPUT_DATA_SAVE_FAIL = "결과 데이터 저장 중 오류 발생"
    UID_NOT_FOUND = "해당 UID를 찾을 수 없습니다"

    # ---- Metrics ----
    SERVER_METRICS_FETCH_SUCCESS = "서버 실시간 메트릭 조회 성공"
    RESOURCE_TIMESERIES_FETCH_SUCCESS = "리소스 시계열 데이터 조회 성공"
    METRICS_INVALID_PERIOD = "지원하지 않는 period 값입니다. (허용: 1h, 6h, 24h)"
    PROMETHEUS_RANGE_QUERY_ERROR = "Prometheus Range Query 중 오류가 발생했습니다."

    # ---- Logs (Model / Server) ----
    MODEL_LOG_FETCH_SUCCESS = "모델 로그 조회 성공"
    MODEL_LOG_REQUIRED_PARAMS = "model_name, start, end는 필수입니다."
    LOKI_MODEL_LOG_FETCH_ERROR = "Loki 모델 로그 조회 중 오류가 발생했습니다."

    SERVER_LOG_FETCH_SUCCESS = "서버 로그 조회 성공"
    SERVER_LOG_REQUIRED_PERIOD = "기간(start, end)은 필수입니다."
    LOKI_LOG_FETCH_ERROR = "Loki 로그 조회 중 오류가 발생했습니다."
