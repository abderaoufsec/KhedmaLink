"""
Logging Configuration
Sets up structured logging with request IDs and proper formatting
"""

import sys  # noqa: E402
from typing import Any  # noqa: E402
from loguru import logger  # noqa: E402

from app.core.config import settings  # noqa: E402


def setup_logging() -> None:
    """
    Set up structured logging for the application
    Configures loguru for structured JSON or text logging
    """
    # Remove default loguru handler
    logger.remove()

    # Add custom handler with request ID support
    if settings.LOG_FORMAT == "json":
        # JSON logging for production
        logger.add(
            sys.stdout,
            format="{time} | {level} | {name} | {message} | {extra}",
            level=settings.LOG_LEVEL,
            serialize=True,
            backtrace=True,
            diagnose=True,
        )
    else:
        # Text logging for development
        logger.add(
            sys.stdout,
            format="<green>{time:YYYY-MM-DD HH:mm:ss}</green> | <level>{level: <8}</level> | <cyan>{name}</cyan>:<cyan>{function}</cyan>:<cyan>{line}</cyan> | <level>{message}</level>",
            level=settings.LOG_LEVEL,
            colorize=True,
        )


def get_logger(name: str) -> Any:
    """
    Get a logger instance for a specific module
    Returns a loguru logger bound to the module name

    Args:
        name: The name of the module (usually __name__)

    Returns:
        A logger instance for the module
    """
    return logger.bind(name=name)
