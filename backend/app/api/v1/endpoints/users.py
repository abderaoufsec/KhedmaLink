"""
User profile endpoints
Handles user profile management and current user information
"""

from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.database import get_db
from app.core.security import get_current_user
from app.core.schemas.auth import UserResponse, UserUpdate, PasswordChange
from app.core.services.auth import AuthService
from app.core.models.user import User
from app.core.logging import get_logger

logger = get_logger(__name__)

# Create router for user profile endpoints
router = APIRouter()


@router.get("/me", response_model=UserResponse)
async def get_current_user_profile(
    current_user: User = Depends(get_current_user),
):
    """
    Get current user profile

    Returns the profile information of the currently authenticated user.

    Args:
        current_user: The authenticated user

    Returns:
        UserResponse: Current user profile
    """
    return UserResponse(
        id=str(current_user.id),
        email=current_user.email,
        full_name=current_user.full_name,
        phone=current_user.phone,
        is_active=current_user.is_active,
        is_verified=current_user.is_verified,
        status=current_user.status,
        roles=[role.name for role in current_user.roles],
        created_at=current_user.created_at.isoformat(),
    )


@router.patch("/me", response_model=UserResponse)
async def update_current_user_profile(
    update_data: UserUpdate,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    """
    Update current user profile

    Updates the profile information of the currently authenticated user.

    Args:
        update_data: User update data
        current_user: The authenticated user
        db: Database session

    Returns:
        UserResponse: Updated user profile
    """
    updated_user = await AuthService.update_user_profile(db, current_user, update_data)

    return UserResponse(
        id=str(updated_user.id),
        email=updated_user.email,
        full_name=updated_user.full_name,
        phone=updated_user.phone,
        is_active=updated_user.is_active,
        is_verified=updated_user.is_verified,
        status=updated_user.status,
        roles=[role.name for role in updated_user.roles],
        created_at=updated_user.created_at.isoformat(),
    )


@router.post("/me/change-password", status_code=status.HTTP_204_NO_CONTENT)
async def change_password(
    password_data: PasswordChange,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    """
    Change current user password

    Changes the password of the currently authenticated user.

    Args:
        password_data: Password change data
        current_user: The authenticated user
        db: Database session

    Returns:
        204 No Content
    """
    await AuthService.change_password(db, current_user, password_data)

    return None
