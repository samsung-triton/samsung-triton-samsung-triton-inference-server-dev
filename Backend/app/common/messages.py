from enum import Enum


class Messages(str, Enum):
    # ---- Common Messages ----
    INVALID_PARAM = "The request contains invalid or missing parameters."

    # ---- User Key ----
    # LOGIN_SUCCESS = "로그인이 성공적으로 완료되었습니다."
    # INVALID_CREDENTIAL = "아이디 또는 비밀번호가 일치하지 않습니다."
    # USER_NOT_FOUND = "해당 유저를 찾을 수 없습니다."
    LOGIN_SUCCESS = "Login completed successfully."
    INVALID_CREDENTIAL = "The login ID or password is incorrect."
    USER_NOT_FOUND = "The specified user could not be found."

    # ---- Master Key ----
    # MASTER_KEY_MATCH = "마스터 키가 일치합니다."
    # MASTER_KEY_MISMATCH = "마스터 키가 일치하지 않습니다."
    MASTER_KEY_MATCH = "The master key matches."
    MASTER_KEY_MISMATCH = "The master key does not match."

    # ---- Triton Server ----
    # SERVER_DOCKER_COMMAND_ERROR = "Docker 명령 실행 중 오류가 발생했습니다."
    # SERVER_READY = "서버가 준비 상태입니다."
    # SERVER_NOT_READY = "서버가 준비되지 않았습니다."
    # SERVER_STATUS_FETCH_ERROR = "Triton 상태 조회 중 오류가 발생했습니다."
    # SERVER_START_SUCCESS = "서버가 성공적으로 시작되었습니다."
    # SERVER_START_ERROR = "서버 시작 중 오류가 발생했습니다."
    # SERVER_STOP_SUCCESS = "서버가 성공적으로 중지되었습니다."
    # SERVER_STOP_ERROR = "서버 중지 중 오류가 발생했습니다."
    # SERVER_RESTART_SUCCESS = "서버가 성공적으로 재시작되었습니다."
    # SERVER_RESTART_ERROR = "서버 재시작 중 오류가 발생했습니다."
    SERVER_DOCKER_COMMAND_ERROR = "An error occurred while executing the Docker command."
    SERVER_READY = "The server is in a ready state."
    SERVER_NOT_READY = "The server is not ready."
    SERVER_STATUS_FETCH_ERROR = "An error occurred while retrieving the Triton server status."
    SERVER_START_SUCCESS = "The server has been successfully started."
    SERVER_START_ERROR = "An error occurred while starting the server."
    SERVER_STOP_SUCCESS = "The server has been successfully stopped."
    SERVER_STOP_ERROR = "An error occurred while stopping the server."
    SERVER_RESTART_SUCCESS = "The server has been successfully restarted."
    SERVER_RESTART_ERROR = "An error occurred while restarting the server."

    # ---- DashBoard ----
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

    # ---- STANDARD TIME ----
    # STANDARD_TIME_FETCH_SUCCESS = "집계 기준 시각 조회 성공"
    # STANDARD_TIME_UPDATE_SUCCESS = "집계 기준 시각이 업데이트되었습니다."
    STANDARD_TIME_FETCH_SUCCESS = "Successfully retrieved the aggregation reference time."
    STANDARD_TIME_UPDATE_SUCCESS = "The aggregation reference time has been updated."
    INVALID_STANDARD_TIME_FORMAT = "Invalid time format. Please use 'HH:MM' (e.g., '15:00')."

    # ---- Notification -----
    # NOTIFICATION_FETCH_SUCCESS = "알람 조회 성공"
    NOTIFICATION_FETCH_SUCCESS = "Successfully fetched notifications."
    NOTIFICATION_FETCH_ERROR = "An error occurred while fetching notifications."

    # ---- Model Manager ----
    # ---- 공통 ----
    # INVALID_ARCHIVE_FORMAT = "유효하지 않은 압축파일입니다. ZIP, TAR, TAR.GZ, TGZ 형식만 지원합니다."
    # ARCHIVE_EXTRACTION_ERROR = "압축 파일 해제 중 오류가 발생했습니다."
    # MODEL_LOAD_ERROR = "모델 로드 중 오류가 발생했습니다. Triton Server 로그를 확인하세요."
    # TRITON_CONNECTION_ERROR = "Triton 서버와의 연결 또는 응답 오류로 인해 요청을 수행할 수 없습니다."
    INVALID_ARCHIVE_FORMAT = "Invalid archive format. Supported formats are ZIP, TAR, TAR.GZ, and TGZ."
    ARCHIVE_EXTRACTION_ERROR = "An error occurred while extracting the archive file."
    MODEL_LOAD_ERROR = "An error occurred while loading the model. Check the Triton server logs."
    TRITON_CONNECTION_ERROR = (
        "The request could not be completed due to a connection or response error from the Triton server."
    )

    # ---- Model Get ----
    # MODEL_NOT_FOUND = "해당 모델을 찾을 수 없습니다."
    # MODEL_VERSION_NOT_FOUND = "해당 모델 버전을 찾을 수 없습니다."
    # MODEL_LIST_FETCH_SUCCESS = "모델 목록을 성공적으로 조회했습니다."
    # MODEL_LIST_FETCH_ERROR = "모델 목록 조회 중 오류가 발생했습니다."
    MODEL_NOT_FOUND = "The specified model could not be found."
    MODEL_VERSION_NOT_FOUND = "The specified model version could not be found."
    MODEL_LIST_FETCH_SUCCESS = "Model list retrieved successfully."
    MODEL_LIST_FETCH_ERROR = "An error occurred while retrieving the model list."
    MODEL_DETAIL_FETCH_SUCCESS = "Model detail retrieved successfully."

    # ---- Model Register ----
    # MODEL_INVALID_NAME = "모델 이름이 유효하지 않습니다."
    # MODEL_REGISTER_SUCCESS = "모델이 성공적으로 등록되었습니다."
    # ENSEMBLE_REGISTER_SUCCESS = "앙상블 모델이 성공적으로 등록되었습니다."
    # MODEL_ASSET_REQUIRED = "모델 파일 또는 설정 파일 중 하나는 반드시 포함되어야 합니다."
    # MODEL_REGISTER_DB_ERROR = "DB 저장 중 오류가 발생했습니다. 이전의 모든 변경사항을 롤백했습니다."
    MODEL_DUPLICATE_NAME = "A model with the same name already exists."
    MODEL_INVALID_NAME = "The model name is invalid."
    MODEL_REGISTER_SUCCESS = "The model has been successfully registered."
    ENSEMBLE_REGISTER_SUCCESS = "The ensemble model has been successfully registered."
    MODEL_ASSET_REQUIRED = "At least one of the model file or configuration file must be provided."
    MODEL_ASSET_ADD_SUCCESS = "Model assets have been successfully added."
    MODEL_REGISTER_DB_ERROR = (
        "An error occurred while saving model information to the database. All previous changes have been rolled back."
    )

    # ---- Model Delete ----
    # MODEL_VERSION_DELETE_SUCCESS = "모델 버전이 성공적으로 삭제되었습니다."
    # MODEL_VERSION_DELETE_SINGLE_FORBIDDEN = "버전이 1개뿐인 모델은 삭제할 수 없습니다. 모델 전체를 삭제하거나 새 버전을 추가한 후 다시 시도하세요."
    # MODEL_DELETE_SUCCESS = "모델이 성공적으로 삭제되었습니다."
    # MODEL_DELETE_DB_ERROR = "DB 삭제 중 오류가 발생했습니다. 이전의 모든 변경사항을 롤백했습니다."
    MODEL_VERSION_DELETE_SUCCESS = "The model version has been successfully deleted."
    MODEL_VERSION_DELETE_SINGLE_FORBIDDEN = (
        "Models with only one version cannot be deleted. Delete the entire model or add a new version before retrying."
    )
    MODEL_DELETE_SUCCESS = "The model has been successfully deleted."
    MODEL_DELETE_DB_ERROR = (
        "An error occurred while deleting model information from the database. "
        "All previous changes have been rolled back."
    )

    # ---- Config ----
    # CONFIG_APPLY_SUCCESS = "새로운 Config가 저장되고 Triton 서버에 적용되었습니다."
    # CONFIG_HISTORY_WITH_FETCH_SUCCESS = "Config 이력 및 Config 상세 내용이 조회되었습니다."
    # CONFIG_DELETE_SUCCESS = "선택한 Config가 성공적으로 삭제되었습니다."
    CONFIG_NOT_FOUND = "The specified configuration could not be found."
    CONFIG_CURRENT_NOT_FOUND = "The current configuration record could not be found in the database."
    CONFIG_HISTORY_WITH_FETCH_SUCCESS = "Configuration history and details have been successfully retrieved."
    CONFIG_UPDATE_SUCCESS = "The configuration has been successfully updated and applied to the Triton server."
    CONFIG_DB_UPDATE_ERROR = "An error occurred while updating configuration data in the database."
    CONFIG_CURRENT_CANNOT_DELETE = "The current configuration cannot be deleted."
    CONFIG_DELETE_SUCCESS = "The selected configuration has been successfully deleted."
    CONFIG_DB_DELETE_ERROR = "An error occurred while deleting the configuration from the database."

    # ---- Logs ----
    # ERR_END_DATE_BEFORE_START_DATE = "end_date는 start_date보다 이전일 수 없습니다."
    # ERR_END_DATE_TOGETHER_START_DATE = "start와 end는 함께 존재해야 합니다."
    # INFER_LOG_MODEL_NAME_LIST_FETCH_SUCCESS = "모델 로그의 model_name 리스트 조회 성공"
    # INFER_LOG_FETCH_SUCCESS = "모델 추론 로그 조회 성공"
    # INFER_LOG_FETCH_ERROR = "모델 추론 로그 조회 중 오류가 발생했습니다."
    # WEB_LOG_FETCH_SUCCESS = "대시보드 웹 로그 조회 성공"
    # SERVER_LOG_FETCH_SUCCESS = "서버 로그 조회 성공"
    # SERVER_LOG_FETCH_ERROR = "서버 로그 조회 중 오류가 발생했습니다."
    ERR_END_DATE_BEFORE_START_DATE = "end_date cannot be earlier than start_date."
    ERR_END_DATE_TOGETHER_START_DATE = "Both start and end must be provided together."
    WEB_LOG_FETCH_SUCCESS = "Successfully retrieved dashboard web logs."
    INFER_LOG_MODEL_NAME_LIST_FETCH_SUCCESS = "Successfully retrieved the list of model names for inference logs."
    INFER_LOG_FETCH_SUCCESS = "Successfully retrieved model inference logs."
    INFER_LOG_FETCH_ERROR = "An error occurred while fetching model inference logs."
    SERVER_LOG_FETCH_SUCCESS = "Successfully retrieved server logs."
    SERVER_LOG_FETCH_ERROR = "An error occurred while fetching server logs."

    # ---- Data / Inference ----
    # INPUT_DATA_SAVE_SUCCESS = "입력 데이터 저장 완료"
    # OUTPUT_DATA_SAVE_SUCCESS = "결과 데이터 저장 완료"
    # INPUT_DATA_SAVE_FAIL = "입력 데이터 저장 중 오류 발생"
    # OUTPUT_DATA_SAVE_FAIL = "결과 데이터 저장 중 오류 발생"
    # UID_NOT_FOUND = "해당 UID를 찾을 수 없습니다"
    INPUT_DATA_SAVE_SUCCESS = "Input data saved successfully."
    OUTPUT_DATA_SAVE_SUCCESS = "Output data saved successfully."
    INPUT_DATA_SAVE_FAIL = "An error occurred while saving input data."
    OUTPUT_DATA_SAVE_FAIL = "An error occurred while saving output data."
    UID_NOT_FOUND = "The specified UID could not be found."

    # ---- Heartbeat ----
    # HEARTBEAT_SUCCESS = "heartbeat 응답 완료"
    HEARTBEAT_SUCCESS = "Heartbeat response completed."
