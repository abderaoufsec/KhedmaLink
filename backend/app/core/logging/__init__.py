"""
Logging package for KhedmaLink backend
Contains structured logging configuration and utilities
"""

from .config import setup_logging, get_logger

__all__ = ["setup_logging", "get_logger"]
