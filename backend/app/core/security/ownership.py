"""
Object ownership check utilities
Provides functions to verify resource ownership for authorization
"""

from typing import Optional, Type
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select
from fastapi import HTTPException, status

from app.core.models.user import User
from app.core.logging import get_logger

logger = get_logger(__name__)


async def check_ownership(
    db: AsyncSession,
    model: Type,
    resource_id: str,
    user_id: str,
    user_id_field: str = "user_id",
) -> bool:
    """
    Check if a user owns a specific resource

    Args:
        db: Database session
        model: The SQLAlchemy model class
        resource_id: The ID of the resource to check
        user_id: The ID of the user to check ownership for
        user_id_field: The field name that stores the user ID (default: "user_id")

    Returns:
        bool: True if user owns the resource, False otherwise
    """
    result = await db.execute(
        select(model).where(
            getattr(model, "id") == resource_id,
            getattr(model, user_id_field) == user_id,
        )
    )
    resource = result.scalar_one_or_none()

    return resource is not None


async def require_ownership(
    db: AsyncSession,
    model: Type,
    resource_id: str,
    user: User,
    user_id_field: str = "user_id",
) -> None:
    """
    Require that a user owns a specific resource

    Raises an HTTPException if the user does not own the resource.

    Args:
        db: Database session
        model: The SQLAlchemy model class
        resource_id: The ID of the resource to check
        user: The user to check ownership for
        user_id_field: The field name that stores the user ID (default: "user_id")

    Raises:
        HTTPException: If user does not own the resource
    """
    is_owner = await check_ownership(
        db, model, resource_id, str(user.id), user_id_field
    )

    if not is_owner:
        logger.warning(
            f"User {user.id} attempted to access resource {resource_id} "
            f"without ownership"
        )
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="You do not have permission to access this resource",
        )


async def check_ownership_or_admin(
    db: AsyncSession,
    model: Type,
    resource_id: str,
    user: User,
    user_id_field: str = "user_id",
) -> None:
    """
    Check if user owns the resource or has admin privileges

    Allows access if the user owns the resource or has admin/super_admin role.

    Args:
        db: Database session
        model: The SQLAlchemy model class
        resource_id: The ID of the resource to check
        user: The user to check ownership for
        user_id_field: The field name that stores the user ID (default: "user_id")

    Raises:
        HTTPException: If user does not own the resource and is not an admin
    """
    # Check if user has admin role
    role_names = [role.name for role in user.roles]
    is_admin = "admin" in role_names or "super_admin" in role_names

    if is_admin:
        # Admins can access any resource
        return

    # Check ownership
    await require_ownership(db, model, resource_id, user, user_id_field)
