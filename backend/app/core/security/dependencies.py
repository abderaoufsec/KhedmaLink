"""
Authentication dependencies for FastAPI routes
Provides dependency functions for protecting routes with JWT authentication
"""

from typing import Optional
from fastapi import Depends, HTTPException, status
from fastapi.security import HTTPBearer, HTTPAuthorizationCredentials
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select

from app.core.database import get_db
from app.core.security import verify_token
from app.core.models.user import User, Role, user_roles
from app.core.logging import get_logger

logger = get_logger(__name__)

# HTTP Bearer token scheme
security = HTTPBearer()


async def get_current_user(
    credentials: HTTPAuthorizationCredentials = Depends(security),
    db: AsyncSession = Depends(get_db),
) -> User:
    """
    Dependency to get the current authenticated user from JWT token

    Args:
        credentials: HTTP Bearer credentials containing the JWT token
        db: Database session

    Returns:
        User: The authenticated user

    Raises:
        HTTPException: If token is invalid or user not found
    """
    credentials_exception = HTTPException(
        status_code=status.HTTP_401_UNAUTHORIZED,
        detail="Could not validate credentials",
        headers={"WWW-Authenticate": "Bearer"},
    )

    token = credentials.credentials
    user_id = verify_token(token)

    if user_id is None:
        logger.warning("Invalid token provided")
        raise credentials_exception

    # Query user from database
    result = await db.execute(select(User).where(User.id == user_id))
    user = result.scalar_one_or_none()

    if user is None:
        logger.warning(f"User not found: {user_id}")
        raise credentials_exception

    if not user.is_active:
        logger.warning(f"Inactive user attempted access: {user_id}")
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN, detail="User account is inactive"
        )

    if user.status != "active":
        logger.warning(f"Suspended user attempted access: {user_id}")
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN, detail="User account is suspended"
        )

    return user


async def get_current_active_user(
    current_user: User = Depends(get_current_user),
) -> User:
    """
    Dependency to get the current active user
    Ensures the user is active and not suspended

    Args:
        current_user: The current authenticated user

    Returns:
        User: The active user

    Raises:
        HTTPException: If user is not active
    """
    if not current_user.is_active:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN, detail="User account is inactive"
        )

    if current_user.status != "active":
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN, detail="User account is suspended"
        )

    return current_user


async def get_current_verified_user(
    current_user: User = Depends(get_current_user),
) -> User:
    """
    Dependency to get the current verified user
    Ensures the user is verified (e.g., email or phone verified)

    Args:
        current_user: The current authenticated user

    Returns:
        User: The verified user

    Raises:
        HTTPException: If user is not verified
    """
    if not current_user.is_verified:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN, detail="User account is not verified"
        )

    return current_user


def require_role(required_role: str):
    """
    Dependency factory to require a specific role

    Args:
        required_role: The role name required to access the route

    Returns:
        Dependency function that checks for the required role
    """

    async def role_checker(
        current_user: User = Depends(get_current_user),
        db: AsyncSession = Depends(get_db),
    ) -> User:
        """
        Check if the current user has the required role

        Args:
            current_user: The current authenticated user
            db: Database session

        Returns:
            User: The user if they have the required role

        Raises:
            HTTPException: If user doesn't have the required role
        """
        # Query user's roles explicitly to avoid lazy loading
        result = await db.execute(
            select(Role).join(user_roles).where(user_roles.c.user_id == current_user.id)
        )
        roles = result.scalars().all()

        role_names = [role.name for role in roles]

        if required_role not in role_names:
            logger.warning(
                f"User {current_user.id} attempted to access {required_role} resource "
                f"without required role. Has roles: {role_names}"
            )
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail=f"Role '{required_role}' required to access this resource",
            )

        return current_user

    return role_checker


def require_any_role(*required_roles: str):
    """
    Dependency factory to require any of the specified roles

    Args:
        *required_roles: The role names required to access the route (any one is sufficient)

    Returns:
        Dependency function that checks for any of the required roles
    """

    async def role_checker(
        current_user: User = Depends(get_current_user),
        db: AsyncSession = Depends(get_db),
    ) -> User:
        """
        Check if the current user has any of the required roles

        Args:
            current_user: The current authenticated user
            db: Database session

        Returns:
            User: The user if they have any of the required roles

        Raises:
            HTTPException: If user doesn't have any of the required roles
        """
        # Query user's roles explicitly to avoid lazy loading
        result = await db.execute(
            select(Role).join(user_roles).where(user_roles.c.user_id == current_user.id)
        )
        roles = result.scalars().all()

        role_names = [role.name for role in roles]

        # Check if user has any of the required roles
        has_required_role = any(role in role_names for role in required_roles)

        if not has_required_role:
            logger.warning(
                f"User {current_user.id} attempted to access resource "
                f"without required roles. Has roles: {role_names}, Required: {required_roles}"
            )
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail=f"One of roles {required_roles} required to access this resource",
            )

        return current_user

    return role_checker


# Convenience role dependencies
require_customer = require_role("customer")
require_provider = require_role("provider")
require_admin = require_role("admin")
require_super_admin = require_role("super_admin")
require_provider_or_admin = require_any_role("provider", "admin", "super_admin")
require_admin_or_super_admin = require_any_role("admin", "super_admin")
