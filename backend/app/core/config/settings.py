"""
Application Settings Configuration
Manages all environment variables and application configuration using Pydantic Settings
"""

from typing import List
from pydantic import Field
from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    """
    Application settings loaded from environment variables
    All settings have sensible defaults for development
    """

    model_config = SettingsConfigDict(
        env_file=".env",
        env_file_encoding="utf-8",
        case_sensitive=False,
        extra="ignore",
    )

    # =============================================================================
    # APPLICATION SETTINGS
    # =============================================================================

    APP_NAME: str = Field(default="KhedmaLink", description="Application name")
    APP_DESCRIPTION: str = Field(
        default="Trusted local-services marketplace for Blida, Algeria",
        description="Application description",
    )
    APP_VERSION: str = Field(default="0.1.0", description="Application version")

    ENVIRONMENT: str = Field(
        default="development",
        description="Environment (development, staging, production)",
    )
    DEBUG: bool = Field(default=True, description="Debug mode")

    # =============================================================================
    # SERVER SETTINGS
    # =============================================================================

    HOST: str = Field(default="0.0.0.0", description="Server host")
    PORT: int = Field(default=8000, description="Server port")

    # =============================================================================
    # API SETTINGS
    # =============================================================================

    API_V1_PREFIX: str = Field(default="/api/v1", description="API v1 prefix")

    # =============================================================================
    # DATABASE SETTINGS
    # =============================================================================

    DATABASE_URL: str = Field(
        default="postgresql+asyncpg://khedmalink_user:khedmalink_password@localhost:5432/khedmalink",
        description="Database connection URL",
    )

    # =============================================================================
    # CORS SETTINGS
    # =============================================================================

    CORS_ORIGINS: List[str] = Field(
        default=["http://localhost:3000", "http://localhost:8080"],
        description="Allowed CORS origins",
    )

    # =============================================================================
    # SECURITY SETTINGS
    # =============================================================================

    SECRET_KEY: str = Field(
        default="your-secret-key-change-in-production",
        description="Secret key for JWT tokens",
    )
    ALGORITHM: str = Field(default="HS256", description="JWT algorithm")
    ACCESS_TOKEN_EXPIRE_MINUTES: int = Field(
        default=30, description="Access token expiration"
    )

    # =============================================================================
    # LOGGING SETTINGS
    # =============================================================================

    LOG_LEVEL: str = Field(default="INFO", description="Logging level")
    LOG_FORMAT: str = Field(default="json", description="Log format (json or text)")

    # =============================================================================
    # POSTGRES SETTINGS
    # =============================================================================

    POSTGRES_USER: str = Field(default="khedmalink_user", description="PostgreSQL user")
    POSTGRES_PASSWORD: str = Field(
        default="khedmalink_password", description="PostgreSQL password"
    )
    POSTGRES_DB: str = Field(
        default="khedmalink", description="PostgreSQL database name"
    )
    POSTGRES_HOST: str = Field(default="localhost", description="PostgreSQL host")
    POSTGRES_PORT: int = Field(default=5432, description="PostgreSQL port")

    # =============================================================================
    # REDIS SETTINGS (Optional)
    # =============================================================================

    REDIS_HOST: str = Field(default="localhost", description="Redis host")
    REDIS_PORT: int = Field(default=6379, description="Redis port")
    REDIS_DB: int = Field(default=0, description="Redis database number")

    # =============================================================================
    # FILE STORAGE SETTINGS
    # =============================================================================

    MAX_UPLOAD_SIZE_MB: int = Field(default=10, description="Max upload size in MB")
    UPLOAD_DIR: str = Field(default="uploads", description="Upload directory")

    # =============================================================================
    # TIMEZONE SETTINGS
    # =============================================================================

    TIMEZONE: str = Field(default="Africa/Algiers", description="Application timezone")

    def get_database_url(self) -> str:
        """
        Construct database URL from individual components
        Falls back to DATABASE_URL if not set
        Uses asyncpg driver for async support
        """
        if self.DATABASE_URL:
            return self.DATABASE_URL

        return (
            f"postgresql+asyncpg://{self.POSTGRES_USER}:{self.POSTGRES_PASSWORD}"
            f"@{self.POSTGRES_HOST}:{self.POSTGRES_PORT}/{self.POSTGRES_DB}"
        )


# Create global settings instance
settings = Settings()
