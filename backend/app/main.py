"""
KhedmaLink Backend Main Application
FastAPI application entry point with proper configuration and middleware
"""

from contextlib import asynccontextmanager
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import JSONResponse

from app.core.config import settings
from app.core.logging import setup_logging, get_logger
from app.core.middleware.request_id import RequestIDMiddleware
from app.api import api_router
from app.core.database import init_db, close_db

# Setup logging
setup_logging()
logger = get_logger(__name__)


@asynccontextmanager
async def lifespan(app: FastAPI):
    """
    Application lifespan manager
    Handles startup and shutdown events
    """
    # Startup
    logger.info(f"{settings.APP_NAME} v{settings.APP_VERSION} starting up")
    logger.info(f"Environment: {settings.ENVIRONMENT}")
    logger.info(f"API prefix: {settings.API_V1_PREFIX}")
    
    # Try to initialize database, but don't fail if it's not available
    try:
        await init_db()
        logger.info("Database initialized successfully")
    except Exception as e:
        logger.warning(f"Database initialization failed (continuing without DB): {e}")

    yield

    # Shutdown
    logger.info(f"{settings.APP_NAME} shutting down")
    try:
        await close_db()
        logger.info("Database connections closed")
    except Exception as e:
        logger.warning(f"Database shutdown failed: {e}")


# Create FastAPI application
app = FastAPI(
    title=settings.APP_NAME,
    description=settings.APP_DESCRIPTION,
    version=settings.APP_VERSION,
    docs_url="/docs",
    redoc_url="/redoc",
    openapi_url=f"{settings.API_V1_PREFIX}/openapi.json",
    lifespan=lifespan,
)

# =============================================================================
# MIDDLEWARE
# =============================================================================

# CORS middleware
app.add_middleware(
    CORSMiddleware,
    allow_origins=settings.CORS_ORIGINS,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Request ID middleware
app.add_middleware(RequestIDMiddleware)

# =============================================================================
# ROUTES
# =============================================================================


# Health check endpoint
@app.get("/health")
async def health_check():
    """
    Health check endpoint
    Returns the health status of the application
    """
    return JSONResponse(
        status_code=200,
        content={
            "status": "healthy",
            "app_name": settings.APP_NAME,
            "version": settings.APP_VERSION,
            "environment": settings.ENVIRONMENT,
        },
    )


# Include API routers
app.include_router(api_router, prefix=settings.API_V1_PREFIX)


# =============================================================================
# ERROR HANDLERS
# =============================================================================


@app.exception_handler(Exception)
async def global_exception_handler(request, exc):
    """
    Global exception handler
    Catches all unhandled exceptions and returns a proper error response
    """
    logger.error(
        f"Unhandled exception: {exc}",
        extra={
            "path": request.url.path,
            "method": request.method,
            "request_id": getattr(request.state, "request_id", None),
        },
    )

    return JSONResponse(
        status_code=500,
        content={
            "detail": "Internal server error",
            "request_id": getattr(request.state, "request_id", None),
        },
    )


if __name__ == "__main__":
    import uvicorn

    uvicorn.run(
        "app.main:app",
        host=settings.HOST,
        port=settings.PORT,
        reload=settings.DEBUG,
        log_level=settings.LOG_LEVEL.lower(),
    )
