"""
API package for KhedmaLink backend
Contains all API routers and endpoint configurations
"""

from fastapi import APIRouter

from app.api.v1 import api_router as v1_router

# Create main API router
api_router = APIRouter()

# Include v1 router directly (no prefix since it's the v1 router)
api_router.include_router(v1_router)

__all__ = ["api_router"]
