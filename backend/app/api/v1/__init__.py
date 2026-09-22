"""
API v1 package
Contains all version 1 API endpoints
"""

from fastapi import APIRouter
from .endpoints import health

# Create API router for v1
api_router = APIRouter()

# Include endpoint routers
api_router.include_router(health.router, prefix="/health", tags=["Health"])

__all__ = ["api_router"]
