"""
Authentication service layer
Handles business logic for user registration, login, and authentication
"""

from datetime import datetime, timezone
from typing import Optional
from uuid import UUID
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select, insert
from fastapi import HTTPException, status

from app.core.models.user import User, Role, user_roles
from app.core.security import (
    get_password_hash,
    verify_password,
    create_access_token,
    create_refresh_token,
)
from app.core.schemas.auth import UserRegister, UserLogin, UserUpdate, PasswordChange
from app.core.logging import get_logger

logger = get_logger(__name__)


class AuthService:
    """
    Service class for authentication operations
    """

    @staticmethod
    async def register_user(db: AsyncSession, user_data: UserRegister) -> User:
        """
        Register a new user

        Args:
            db: Database session
            user_data: User registration data

        Returns:
            User: The created user

        Raises:
            HTTPException: If email or phone already exists
        """
        logger.info(f"Starting registration for email: {user_data.email}")
        
        # Check if email already exists
        result = await db.execute(select(User).where(User.email == user_data.email))
        existing_user = result.scalar_one_or_none()

        if existing_user:
            logger.warning(
                f"Registration attempt with existing email: {user_data.email}"
            )
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Email already registered",
            )

        # Check if phone already exists (if provided)
        if user_data.phone:
            result = await db.execute(select(User).where(User.phone == user_data.phone))
            existing_phone = result.scalar_one_or_none()

            if existing_phone:
                logger.warning(
                    f"Registration attempt with existing phone: {user_data.phone}"
                )
                raise HTTPException(
                    status_code=status.HTTP_400_BAD_REQUEST,
                    detail="Phone number already registered",
                )

        # Create new user
        hashed_password = get_password_hash(user_data.password)

        new_user = User(
            email=user_data.email,
            full_name=user_data.full_name,
            phone=user_data.phone,
            hashed_password=hashed_password,
            is_active=True,
            is_verified=False,
            status="active",
        )

        db.add(new_user)
        await db.commit()
        await db.refresh(new_user)
        
        logger.info(f"User created with ID: {new_user.id}")

        # Assign default customer role
        logger.info(f"Assigning customer role to user {new_user.id}")
        await AuthService._assign_role(db, new_user.id, "customer")

        logger.info(f"User registration complete: {new_user.id} ({new_user.email})")

        return new_user

    @staticmethod
    async def _assign_role(db: AsyncSession, user_id: UUID, role_name: str) -> None:
        """
        Assign a role to a user

        Args:
            db: Database session
            user_id: User ID (UUID)
            role_name: Role name to assign
        """
        result = await db.execute(select(Role).where(Role.name == role_name))
        role = result.scalar_one_or_none()

        if role:
            # Use direct insert for many-to-many relationship to avoid lazy loading issues
            stmt = insert(user_roles).values(user_id=user_id, role_id=role.id)
            await db.execute(stmt)
            await db.commit()
            logger.info(f"Role '{role_name}' assigned to user {user_id}")
        else:
            logger.error(f"Role '{role_name}' not found in database")

    @staticmethod
    async def authenticate_user(
        db: AsyncSession, login_data: UserLogin
    ) -> Optional[User]:
        """
        Authenticate a user with email and password

        Args:
            db: Database session
            login_data: User login data

        Returns:
            Optional[User]: The authenticated user if credentials are valid

        Raises:
            HTTPException: If credentials are invalid
        """
        result = await db.execute(select(User).where(User.email == login_data.email))
        user = result.scalar_one_or_none()

        if not user:
            logger.warning(f"Login attempt with non-existent email: {login_data.email}")
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="Invalid email or password",
            )

        if not verify_password(login_data.password, user.hashed_password):
            logger.warning(f"Invalid password for user: {user.email}")
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="Invalid email or password",
            )

        if not user.is_active:
            logger.warning(f"Login attempt for inactive user: {user.email}")
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN, detail="User account is inactive"
            )

        if user.status != "active":
            logger.warning(f"Login attempt for suspended user: {user.email}")
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail="User account is suspended",
            )

        # Update last login
        user.last_login = datetime.now(timezone.utc)
        await db.commit()

        logger.info(f"User authenticated: {user.id} ({user.email})")

        return user

    @staticmethod
    async def create_tokens(user: User, db: AsyncSession = None) -> dict:
        """
        Create access and refresh tokens for a user

        Args:
            user: The user to create tokens for
            db: Optional database session for loading roles

        Returns:
            dict: Dictionary containing access_token and refresh_token
        """
        # Get user roles explicitly to avoid lazy loading issues
        if db:
            from app.core.models.user import Role, user_roles
            result = await db.execute(
                select(Role).join(user_roles).where(user_roles.c.user_id == user.id)
            )
            roles = result.scalars().all()
            role_names = [role.name for role in roles]
        else:
            # Fallback to lazy loading if no db session provided
            role_names = [role.name for role in user.roles]

        # Create access token
        access_token = create_access_token(
            data={
                "sub": str(user.id),
                "email": user.email,
                "roles": role_names,
            }
        )

        # Create refresh token
        refresh_token = create_refresh_token(
            data={
                "sub": str(user.id),
            }
        )

        return {
            "access_token": access_token,
            "refresh_token": refresh_token,
        }

    @staticmethod
    async def refresh_token(db: AsyncSession, refresh_token: str) -> dict:
        """
        Refresh an access token using a refresh token

        Args:
            db: Database session
            refresh_token: The refresh token

        Returns:
            dict: Dictionary containing new access_token and refresh_token

        Raises:
            HTTPException: If refresh token is invalid
        """
        from app.core.security import verify_refresh_token

        user_id = verify_refresh_token(refresh_token)

        if user_id is None:
            logger.warning("Invalid refresh token provided")
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED, detail="Invalid refresh token"
            )

        # Get user from database
        result = await db.execute(select(User).where(User.id == user_id))
        user = result.scalar_one_or_none()

        if not user:
            logger.warning(f"User not found for refresh token: {user_id}")
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED, detail="Invalid refresh token"
            )

        if not user.is_active or user.status != "active":
            logger.warning(f"Inactive user attempted token refresh: {user_id}")
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN, detail="User account is inactive"
            )

        # Create new tokens
        tokens = await AuthService.create_tokens(user, db)

        logger.info(f"Token refreshed for user: {user.id}")

        return tokens

    @staticmethod
    async def update_user_profile(
        db: AsyncSession, user: User, update_data: UserUpdate
    ) -> User:
        """
        Update user profile

        Args:
            db: Database session
            user: The user to update
            update_data: Update data

        Returns:
            User: The updated user
        """
        if update_data.full_name is not None:
            user.full_name = update_data.full_name

        if update_data.phone is not None:
            # Check if phone is already taken by another user
            result = await db.execute(
                select(User).where(User.phone == update_data.phone, User.id != user.id)
            )
            existing_phone = result.scalar_one_or_none()

            if existing_phone:
                raise HTTPException(
                    status_code=status.HTTP_400_BAD_REQUEST,
                    detail="Phone number already registered",
                )

            user.phone = update_data.phone

        await db.commit()
        await db.refresh(user)

        logger.info(f"User profile updated: {user.id}")

        return user

    @staticmethod
    async def change_password(
        db: AsyncSession, user: User, password_data: PasswordChange
    ) -> None:
        """
        Change user password

        Args:
            db: Database session
            user: The user to change password for
            password_data: Password change data

        Raises:
            HTTPException: If current password is invalid
        """
        if not verify_password(password_data.current_password, user.hashed_password):
            logger.warning(f"Invalid current password for user: {user.id}")
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Current password is incorrect",
            )

        user.hashed_password = get_password_hash(password_data.new_password)
        await db.commit()

        logger.info(f"Password changed for user: {user.id}")
