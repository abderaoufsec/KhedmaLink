"""
Health check endpoints
Provides health check and system status endpoints
"""

from fastapi import APIRouter
from fastapi.responses import JSONResponse

from app.core.config import settings
from app.core.logging import get_logger

logger = get_logger(__name__)

# Create router for health endpoints
router = APIRouter()


@router.get("/")
async def health_check():
    """
    Health check endpoint
    Returns the health status of the API
    """
    return JSONResponse(
        status_code=200,
        content={
            "status": "healthy",
            "service": settings.APP_NAME,
            "version": settings.APP_VERSION,
            "environment": settings.ENVIRONMENT,
        },
    )


@router.get("/status")
async def status_check():
    """
    Detailed status check endpoint
    Returns detailed system status information
    """
    return JSONResponse(
        status_code=200,
        content={
            "status": "operational",
            "service": settings.APP_NAME,
            "version": settings.APP_VERSION,
            "environment": settings.ENVIRONMENT,
            "database": "connected",  # Will be dynamic when DB is connected
            "features": {
                "health_check": True,
                "api_docs": True,
                "request_id": True,
            },
        },
    )
