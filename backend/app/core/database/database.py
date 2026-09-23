"""
Database Configuration and Session Management
Handles database connections, sessions, and lifecycle management
"""

from typing import AsyncGenerator
from sqlalchemy.ext.asyncio import (
    AsyncSession,
    create_async_engine,
    async_sessionmaker,
)
from sqlalchemy.orm import declarative_base
from sqlalchemy import text

from app.core.config import settings
from app.core.logging import get_logger

logger = get_logger(__name__)

# =============================================================================
# DATABASE ENGINE AND SESSION
# =============================================================================

# Check if using SQLite (which doesn't support connection pooling)
is_sqlite = "sqlite" in settings.get_database_url().lower()

# Create async engine with appropriate configuration
if is_sqlite:
    # SQLite doesn't support connection pooling
    engine = create_async_engine(
        settings.get_database_url(),
        echo=settings.DEBUG,  # Log SQL queries in debug mode
        future=True,
    )
else:
    # PostgreSQL with connection pooling
    engine = create_async_engine(
        settings.get_database_url(),
        echo=settings.DEBUG,  # Log SQL queries in debug mode
        future=True,
        pool_size=20,
        max_overflow=10,
        pool_pre_ping=True,  # Verify connections before using
    )

# Create async session factory
AsyncSessionLocal = async_sessionmaker(
    engine,
    class_=AsyncSession,
    expire_on_commit=False,
    autocommit=False,
    autoflush=False,
)

# Base class for database models
Base = declarative_base()


# =============================================================================
# DATABASE LIFECYCLE FUNCTIONS
# =============================================================================


async def init_db() -> None:
    """
    Initialize database connection
    Creates database engine and validates connection
    """
    try:
        # Test database connection
        async with engine.begin() as conn:
            if is_sqlite:
                # SQLite connection test
                await conn.execute(text("SELECT 1"))
            else:
                # PostgreSQL connection test
                await conn.execute(text("SELECT 1"))

        logger.info("Database connection established successfully")
        if not is_sqlite:
            logger.info(f"Database: {settings.POSTGRES_DB}")
            logger.info(f"Host: {settings.POSTGRES_HOST}:{settings.POSTGRES_PORT}")
        else:
            logger.info("Using SQLite database for development")

    except Exception as e:
        logger.error(f"Failed to initialize database: {e}")
        raise


async def close_db() -> None:
    """
    Close database connections
    Properly closes all database connections and disposes of the engine
    """
    try:
        await engine.dispose()
        logger.info("Database connections closed successfully")
    except Exception as e:
        logger.error(f"Error closing database connections: {e}")


# =============================================================================
# DEPENDENCY FUNCTIONS
# =============================================================================


async def get_db() -> AsyncGenerator[AsyncSession, None]:
    """
    Dependency function to get database session
    Yields a database session and ensures proper cleanup

    Yields:
        AsyncSession: Database session for the request
    """
    async with AsyncSessionLocal() as session:
        try:
            yield session
            await session.commit()
        except Exception:
            await session.rollback()
            raise
        finally:
            await session.close()
