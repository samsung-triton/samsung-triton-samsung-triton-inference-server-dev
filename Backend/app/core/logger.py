import logging

LOG_FORMAT = "[%(asctime)s] [%(levelname)s] %(message)s"
DATE_FORMAT = "%Y-%m-%d %H:%M:%S"

# 로거 생성
logger = logging.getLogger("backend")
logger.setLevel(logging.WARNING)  # WARNING 이상만 출력

# 콘솔 출력 핸들러
console_handler = logging.StreamHandler()
console_handler.setFormatter(logging.Formatter(LOG_FORMAT, DATE_FORMAT))

# 기존 핸들러 제거 (중복 방지)
if logger.hasHandlers():
    logger.handlers.clear()

logger.addHandler(console_handler)


def extract_error(exc):
    # CustomHTTPException(data={"error": ...})
    try:
        if hasattr(exc, "data") and isinstance(exc.data, dict):
            if "error" in exc.data and exc.data["error"]:
                return str(exc.data["error"])
    except:
        pass

    # subprocess.CalledProcessError 지원
    if hasattr(exc, "stderr") and exc.stderr:
        try:
            return exc.stderr.decode("utf-8", errors="ignore").strip()
        except:
            return str(exc.stderr)

    if hasattr(exc, "stdout") and exc.stdout:
        try:
            return exc.stdout.decode("utf-8", errors="ignore").strip()
        except:
            return str(exc.stdout)

    # HTTPException.detail
    if hasattr(exc, "detail") and exc.detail:
        return str(exc.detail)

    return str(exc)
