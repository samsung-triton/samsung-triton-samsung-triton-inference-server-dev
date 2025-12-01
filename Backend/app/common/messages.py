from enum import Enum


class Messages(str, Enum):
    # ---- Common Messages ----
    INVALID_PARAM = "The request contains invalid or missing parameters."

    # ---- User Key ----
    LOGIN_SUCCESS = "Login completed successfully."
    INVALID_CREDENTIAL = "The login ID or password is incorrect."
    USER_NOT_FOUND = "The specified user could not be found."

    # ---- Master Key ----
    MASTER_KEY_MATCH = "The master key matches."
    MASTER_KEY_MISMATCH = "The master key does not match."

    # ---- Triton Server ----
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
    SERVER_METRIC_FAIL = "Failed to fetch server metrics."
    PROMETHEUS_BAD_STATUS = "Prometheus returned an invalid response status."
    PROMETHEUS_QUERY_FAIL = "An error occurred while querying Prometheus metrics."
    SERVER_METRICS_FETCH_SUCCESS = "Server realtime CPU/GPU metrics fetched successfully."
    RESOURCE_TIMESERIES_FETCH_SUCCESS = "Server RAM/VRAM timeseries metrics fetched successfully."
    DASHBOARD_MODEL_LIST_SUCCESS = "Dashboard model list fetched successfully."
    MODEL_STATS_FETCH_SUCCESS = "Model inference statistics fetched successfully."
    MODEL_LATENCY_FETCH_SUCCESS = "Model inference latency timeseries fetched successfully."
    MODEL_LATENCY_FETCH_ERROR = "Failed to fetch model latency metrics."

    # ---- STANDARD TIME ----
    STANDARD_TIME_FETCH_SUCCESS = "Successfully retrieved the aggregation reference time."
    STANDARD_TIME_UPDATE_SUCCESS = "The aggregation reference time has been updated."
    INVALID_STANDARD_TIME_FORMAT = "Invalid time format. Please use 'HH:MM' (e.g., '15:00')."

    # ---- Notification -----
    NOTIFICATION_FETCH_SUCCESS = "Successfully fetched notifications."
    NOTIFICATION_FETCH_ERROR = "An error occurred while fetching notifications."

    # ---- Model Manager ----
    # ---- 공통 ----
    INVALID_ARCHIVE_FORMAT = "Invalid archive format. Supported formats are ZIP, TAR, TAR.GZ, and TGZ."
    ARCHIVE_EXTRACTION_ERROR = "An error occurred while extracting the archive file."
    MODEL_LOAD_ERROR = "An error occurred while loading the model. Check the Triton server logs."
    TRITON_CONNECTION_ERROR = (
        "The request could not be completed due to a connection or response error from the Triton server."
    )

    # ---- Model Get ----
    MODEL_NOT_FOUND = "The specified model could not be found."
    MODEL_VERSION_NOT_FOUND = "The specified model version could not be found."
    MODEL_LIST_FETCH_SUCCESS = "Model list retrieved successfully."
    MODEL_LIST_FETCH_ERROR = "An error occurred while retrieving the model list."
    MODEL_DETAIL_FETCH_SUCCESS = "Model detail retrieved successfully."

    # ---- Model Register ----
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
    CONFIG_NOT_FOUND = "The specified configuration could not be found."
    CONFIG_CURRENT_NOT_FOUND = "The current configuration record could not be found in the database."
    CONFIG_HISTORY_WITH_FETCH_SUCCESS = "Configuration history and details have been successfully retrieved."
    CONFIG_UPDATE_SUCCESS = "The configuration has been successfully updated and applied to the Triton server."
    CONFIG_DB_UPDATE_ERROR = "An error occurred while updating configuration data in the database."
    CONFIG_CURRENT_CANNOT_DELETE = "The current configuration cannot be deleted."
    CONFIG_DELETE_SUCCESS = "The selected configuration has been successfully deleted."
    CONFIG_DELETE_NOT_FOUND = "The requested configuration does not exist or has already been deleted."
    CONFIG_DB_DELETE_ERROR = "An error occurred while deleting the configuration from the database."

    # ---- Logs ----
    ERR_END_DATE_BEFORE_START_DATE = "end_date cannot be earlier than start_date."
    ERR_END_DATE_TOGETHER_START_DATE = "Both start and end must be provided together."
    WEB_LOG_FETCH_SUCCESS = "Successfully retrieved dashboard web logs."
    INFER_LOG_MODEL_NAME_LIST_FETCH_SUCCESS = "Successfully retrieved the list of model names for inference logs."
    INFER_LOG_FETCH_SUCCESS = "Successfully retrieved model inference logs."
    INFER_LOG_FETCH_ERROR = "An error occurred while fetching model inference logs."
    SERVER_LOG_FETCH_SUCCESS = "Successfully retrieved server logs."
    SERVER_LOG_FETCH_ERROR = "An error occurred while fetching server logs."

    # ---- Data / Inference ----
    INPUT_DATA_SAVE_SUCCESS = "Input data saved successfully."
    OUTPUT_DATA_SAVE_SUCCESS = "Output data saved successfully."
    INPUT_DATA_SAVE_FAIL = "An error occurred while saving input data."
    OUTPUT_DATA_SAVE_FAIL = "An error occurred while saving output data."
    UID_NOT_FOUND = "The specified UID could not be found."

    # ---- SSE Messages ----
    # ---- Docker ----
    SSE_TRITON_START = "[SSE] Triton server has been STARTED."
    SSE_TRITON_STOP = "[SSE] Triton server has been STOPPED."
    SSE_TRITON_RESTART = "[SSE] Triton server has been RESTARTED."

    # ---- Heartbeat ----
    HEARTBEAT_SUCCESS = "Heartbeat response completed."
