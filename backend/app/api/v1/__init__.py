"""
API v1 package
Contains all version 1 API endpoints
"""

from fastapi import APIRouter
from .endpoints import (
    health,
    auth,
    users,
    categories,
    providers,
    requests,
    quotes,
    bookings,
    messages,
    reviews,
    admin,
    disputes,
    payments,
)

# Create API router for v1
api_router = APIRouter()

# Include endpoint routers
api_router.include_router(health.router, prefix="/health", tags=["Health"])
api_router.include_router(auth.router, prefix="/auth", tags=["Authentication"])
api_router.include_router(users.router, prefix="/users", tags=["Users"])
api_router.include_router(categories.router, prefix="/categories", tags=["Categories"])
api_router.include_router(providers.router, prefix="/providers", tags=["Providers"])
api_router.include_router(requests.router, prefix="/requests", tags=["Requests"])
api_router.include_router(quotes.router, prefix="/quotes", tags=["Quotes"])
api_router.include_router(bookings.router, prefix="/bookings", tags=["Bookings"])
api_router.include_router(messages.router, prefix="/messages", tags=["Messages"])
api_router.include_router(reviews.router, prefix="/reviews", tags=["Reviews"])
api_router.include_router(admin.router, prefix="/admin", tags=["Admin"])
api_router.include_router(disputes.router, prefix="/disputes", tags=["Disputes"])
api_router.include_router(payments.router, prefix="/payments", tags=["Payments"])

__all__ = ["api_router"]
