"""
Logging package for KhedmaLink backend
Contains structured logging configuration and utilities
"""

from .config import setup_logging, get_logger  # noqa: E402

__all__ = ["setup_logging", "get_logger"]
