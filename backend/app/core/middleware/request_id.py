"""
Request ID Middleware
Adds unique request IDs to all requests for better tracing and debugging
"""

import uuid  # noqa: E402
from fastapi import Request  # noqa: E402
from starlette.middleware.base import BaseHTTPMiddleware  # noqa: E402

from app.core.logging import get_logger  # noqa: E402

logger = get_logger(__name__)


class RequestIDMiddleware(BaseHTTPMiddleware):
    """
    Middleware to add unique request IDs to all incoming requests
    This helps with tracing requests through the system and debugging
    """

    async def dispatch(self, request: Request, call_next):
        """
        Process request and add request ID

        Args:
            request: Incoming HTTP request
            call_next: Next middleware or route handler

        Returns:
            Response: HTTP response with request ID header
        """
        # Generate or extract request ID
        request_id = request.headers.get("X-Request-ID", str(uuid.uuid4()))

        # Add request ID to request state for access in endpoints
        request.state.request_id = request_id

        # Log the incoming request with request ID
        logger.bind(request_id=request_id).info(
            f"Incoming request: {request.method} {request.url.path}"
        )

        # Process the request
        response = await call_next(request)

        # Add request ID to response headers
        response.headers["X-Request-ID"] = request_id

        return response
