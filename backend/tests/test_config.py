"""
Backend configuration tests
Tests application settings and configuration loading
"""

import pytest
from app.core.config import settings


def test_app_name():
    """Test that application name is set correctly"""
    assert settings.APP_NAME == "KhedmaLink"


def test_app_version():
    """Test that application version is set correctly"""
    assert settings.APP_VERSION == "0.1.0"


def test_environment():
    """Test that environment is set to development by default"""
    assert settings.ENVIRONMENT == "development"


def test_debug_mode():
    """Test that debug mode is enabled in development"""
    assert settings.DEBUG is True


def test_database_url():
    """Test that database URL is configured"""
    assert settings.DATABASE_URL is not None
    assert "postgresql" in settings.DATABASE_URL


def test_postgres_settings():
    """Test that PostgreSQL settings are configured"""
    assert settings.POSTGRES_USER == "khedmalink_user"
    assert settings.POSTGRES_DB == "khedmalink"
    assert settings.POSTGRES_HOST == "localhost"
    assert settings.POSTGRES_PORT == 5432


def test_cors_origins():
    """Test that CORS origins are configured"""
    assert settings.CORS_ORIGINS is not None
    assert len(settings.CORS_ORIGINS) > 0
    assert "http://localhost:3000" in settings.CORS_ORIGINS


def test_secret_key():
    """Test that secret key is configured"""
    assert settings.SECRET_KEY is not None
    assert len(settings.SECRET_KEY) > 0


def test_jwt_settings():
    """Test that JWT settings are configured"""
    assert settings.ALGORITHM == "HS256"
    assert settings.ACCESS_TOKEN_EXPIRE_MINUTES == 30


def test_logging_settings():
    """Test that logging settings are configured"""
    assert settings.LOG_LEVEL == "INFO"
    assert settings.LOG_FORMAT in ["json", "text"]


def test_get_database_url():
    """Test that database URL construction works"""
    db_url = settings.get_database_url()
    assert db_url is not None
    assert "postgresql" in db_url
    assert "khedmalink" in db_url


def test_upload_settings():
    """Test that upload settings are configured"""
    assert settings.MAX_UPLOAD_SIZE_MB == 10
    assert settings.UPLOAD_DIR == "uploads"


def test_timezone():
    """Test that timezone is configured"""
    assert settings.TIMEZONE == "Africa/Algiers"
