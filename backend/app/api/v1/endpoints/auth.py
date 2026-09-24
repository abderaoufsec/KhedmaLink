"""
Authentication endpoints
Handles user registration, login, token refresh, and logout
"""

from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.ext.asyncio import AsyncSession
import traceback

from app.core.database import get_db
from app.core.security import create_access_token
from app.core.schemas.auth import (
    UserRegister,
    UserLogin,
    TokenResponse,
    TokenRefresh,
    UserResponse,
    UserUpdate,
    PasswordChange,
)
from app.core.services.auth import AuthService
from app.core.logging import get_logger

logger = get_logger(__name__)

# Create router for auth endpoints
router = APIRouter()


@router.post(
    "/register", response_model=UserResponse, status_code=status.HTTP_201_CREATED
)
async def register(
    user_data: UserRegister,
    db: AsyncSession = Depends(get_db),
):
    """
    Register a new user

    Creates a new user account with email and password.
    Assigns the 'customer' role by default.

    Args:
        user_data: User registration data
        db: Database session

    Returns:
        UserResponse: The created user
    """
    logger.info(f"Registration request received for email: {user_data.email}")
    
    try:
        user = await AuthService.register_user(db, user_data)
        logger.info(f"User created successfully: {user.id}")

        # Load roles explicitly to avoid lazy loading issues
        from sqlalchemy import select
        from app.core.models.user import Role, user_roles
        result = await db.execute(
            select(Role).join(user_roles).where(user_roles.c.user_id == user.id)
        )
        roles = result.scalars().all()
        logger.info(f"Roles loaded: {[role.name for role in roles]}")

        response = UserResponse(
            id=str(user.id),
            email=user.email,
            full_name=user.full_name,
            phone=user.phone,
            is_active=user.is_active,
            is_verified=user.is_verified,
            status=user.status,
            roles=[role.name for role in roles],
            created_at=user.created_at.isoformat(),
        )
        logger.info(f"Response created successfully")
        return response
        
    except Exception as e:
        logger.error(f"Registration error: {str(e)}")
        logger.error(f"Traceback: {traceback.format_exc()}")
        raise


@router.post("/login", response_model=TokenResponse)
async def login(
    login_data: UserLogin,
    db: AsyncSession = Depends(get_db),
):
    """
    Login user with email and password

    Authenticates a user and returns JWT access and refresh tokens.

    Args:
        login_data: User login data
        db: Database session

    Returns:
        TokenResponse: Access and refresh tokens
    """
    user = await AuthService.authenticate_user(db, login_data)
    tokens = await AuthService.create_tokens(user, db)

    return TokenResponse(
        access_token=tokens["access_token"],
        refresh_token=tokens["refresh_token"],
        token_type="bearer",
        expires_in=30 * 60,  # 30 minutes in seconds
    )


@router.post("/refresh", response_model=TokenResponse)
async def refresh_token(
    token_data: TokenRefresh,
    db: AsyncSession = Depends(get_db),
):
    """
    Refresh access token using refresh token

    Issues a new access token using a valid refresh token.

    Args:
        token_data: Refresh token data
        db: Database session

    Returns:
        TokenResponse: New access and refresh tokens
    """
    tokens = await AuthService.refresh_token(db, token_data.refresh_token)

    return TokenResponse(
        access_token=tokens["access_token"],
        refresh_token=tokens["refresh_token"],
        token_type="bearer",
        expires_in=30 * 60,  # 30 minutes in seconds
    )


@router.post("/logout", status_code=status.HTTP_204_NO_CONTENT)
async def logout():
    """
    Logout user

    Since we use stateless JWT tokens, logout is handled client-side
    by removing the tokens. This endpoint exists for future implementation
    of token blacklisting if needed.

    Returns:
        204 No Content
    """
    # Token blacklisting can be implemented here in the future
    # For now, logout is handled client-side
    return None
