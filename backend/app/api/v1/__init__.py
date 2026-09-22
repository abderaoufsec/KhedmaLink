"""
API v1 package
Contains all version 1 API endpoints
"""

from fastapi import APIRouter
from .endpoints import health, auth, users

# Create API router for v1
api_router = APIRouter()

# Include endpoint routers
api_router.include_router(health.router, prefix="/health", tags=["Health"])
api_router.include_router(auth.router, prefix="/auth", tags=["Authentication"])
api_router.include_router(users.router, prefix="/users", tags=["Users"])

__all__ = ["api_router"]
