# mynid_backend/config.py
import os
from urllib.parse import quote_plus

def _normalize_db_url(url: str) -> str:
    if not url:
        return url
    # SQLAlchemy requires postgresql:// not postgres://
    if url.startswith("postgres://"):
        url = "postgresql://" + url[len("postgres://"):]
    return url

PROJECT_ROOT = os.path.abspath(os.path.dirname(__file__))

class BaseConfig:
    # Backend base URL (used only if your app needs to generate absolute links)
    BASE_URL = os.getenv("BASE_URL", "http://localhost:5000")

    # Flask / JWT
    SECRET_KEY = os.getenv("SECRET_KEY", "dev-only-not-secret")
    JWT_SECRET_KEY = os.getenv("JWT_SECRET_KEY", SECRET_KEY)

    # Database
    DATABASE_URL = _normalize_db_url(os.getenv("DATABASE_URL", ""))
    if DATABASE_URL:
        SQLALCHEMY_DATABASE_URI = DATABASE_URL
    else:
        # Local dev fallback — URL-encode in case of special chars
        DB_HOST = os.getenv("DB_HOST", "localhost")
        DB_NAME = os.getenv("DB_NAME", "mynid")
        DB_USER = os.getenv("DB_USER", "postgres")
        DB_PASSWORD = quote_plus(os.getenv("DB_PASSWORD", "postgres"))
        DB_PORT = int(os.getenv("DB_PORT", "5432"))
        SQLALCHEMY_DATABASE_URI = f"postgresql://{DB_USER}:{DB_PASSWORD}@{DB_HOST}:{DB_PORT}/{DB_NAME}"

    SQLALCHEMY_TRACK_MODIFICATIONS = False
    SQLALCHEMY_ENGINE_OPTIONS = {
        "pool_pre_ping": True,
        "pool_recycle": 300,
    }

    # Uploads (absolute path). Default matches your app.py usage.
    UPLOAD_FOLDER = os.getenv(
        "UPLOAD_FOLDER",
        os.path.join(PROJECT_ROOT, "static", "uploads", "biometrics")
    )
    MAX_CONTENT_LENGTH = int(os.getenv("MAX_CONTENT_LENGTH", str(16 * 1024 * 1024)))  # 16MB

    # CORS (set your frontend origin in env; comma-separate if multiple)
    CORS_ORIGINS = [o.strip() for o in os.getenv("CORS_ORIGINS", "*").split(",")]

    # Proxy/HTTPS awareness (Render is behind a proxy)
    PREFERRED_URL_SCHEME = os.getenv("PREFERRED_URL_SCHEME", "https")
    SESSION_COOKIE_SECURE = os.getenv("SESSION_COOKIE_SECURE", "1") == "1"
    SESSION_COOKIE_SAMESITE = os.getenv("SESSION_COOKIE_SAMESITE", "Lax")

class ProductionConfig(BaseConfig):
    DEBUG = False
    TESTING = False

    # Fail fast if secrets aren’t set
    if os.getenv("FLASK_ENV") == "production":
        if os.getenv("SECRET_KEY", "") in ("", "dev-only-not-secret"):
            raise RuntimeError("SECRET_KEY must be set in production")
        if not BaseConfig.DATABASE_URL:
            raise RuntimeError("DATABASE_URL must be set in production")

class DevelopmentConfig(BaseConfig):
    DEBUG = True
    TESTING = False

class TestingConfig(BaseConfig):
    DEBUG = False
    TESTING = True
    SQLALCHEMY_DATABASE_URI = "sqlite:///:memory:"
