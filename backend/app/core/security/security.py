"""
Security utilities for KhedmaLink backend
Contains password hashing, JWT token generation, and authentication helpers
"""

from datetime import datetime, timedelta, timezone
from typing import Optional, Union
from jose import JWTError, jwt
from passlib.context import CryptContext

from app.core.config import settings

# =============================================================================
# PASSWORD HASHING
# =============================================================================

# Password hashing context using bcrypt
pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")


def verify_password(plain_password: str, hashed_password: str) -> bool:
    """
    Verify a plain password against a hashed password

    Args:
        plain_password: The plain text password to verify
        hashed_password: The hashed password to compare against

    Returns:
        bool: True if passwords match, False otherwise
    """
    return pwd_context.verify(plain_password, hashed_password)


def get_password_hash(password: str) -> str:
    """
    Hash a password using bcrypt

    Args:
        password: The plain text password to hash

    Returns:
        str: The hashed password
    """
    return pwd_context.hash(password)


# =============================================================================
# JWT TOKEN MANAGEMENT
# =============================================================================


def create_access_token(data: dict, expires_delta: Optional[timedelta] = None) -> str:
    """
    Create a JWT access token

    Args:
        data: The data to encode in the token (typically user_id and roles)
        expires_delta: Optional custom expiration time

    Returns:
        str: The encoded JWT token
    """
    to_encode = data.copy()

    if expires_delta:
        expire = datetime.now(timezone.utc) + expires_delta
    else:
        expire = datetime.now(timezone.utc) + timedelta(
            minutes=settings.ACCESS_TOKEN_EXPIRE_MINUTES
        )

    to_encode.update({"exp": expire, "iat": datetime.now(timezone.utc)})

    encoded_jwt = jwt.encode(
        to_encode, settings.SECRET_KEY, algorithm=settings.ALGORITHM
    )

    return encoded_jwt


def decode_access_token(token: str) -> Optional[dict]:
    """
    Decode and verify a JWT access token

    Args:
        token: The JWT token to decode

    Returns:
        Optional[dict]: The decoded token data if valid, None otherwise
    """
    try:
        payload = jwt.decode(
            token, settings.SECRET_KEY, algorithms=[settings.ALGORITHM]
        )
        return payload
    except JWTError:
        return None


def verify_token(token: str) -> Optional[str]:
    """
    Verify a JWT token and return the user ID

    Args:
        token: The JWT token to verify

    Returns:
        Optional[str]: The user ID if token is valid, None otherwise
    """
    payload = decode_access_token(token)
    if payload is None:
        return None

    user_id: str = payload.get("sub")
    if user_id is None:
        return None

    return user_id


# =============================================================================
# TOKEN REFRESH
# =============================================================================


def create_refresh_token(data: dict) -> str:
    """
    Create a JWT refresh token with longer expiration

    Args:
        data: The data to encode in the token (typically user_id)

    Returns:
        str: The encoded refresh token
    """
    to_encode = data.copy()
    expire = datetime.now(timezone.utc) + timedelta(days=7)  # 7 days for refresh token
    to_encode.update(
        {"exp": expire, "iat": datetime.now(timezone.utc), "type": "refresh"}
    )

    encoded_jwt = jwt.encode(
        to_encode, settings.SECRET_KEY, algorithm=settings.ALGORITHM
    )

    return encoded_jwt


def verify_refresh_token(token: str) -> Optional[str]:
    """
    Verify a refresh token and return the user ID

    Args:
        token: The refresh token to verify

    Returns:
        Optional[str]: The user ID if token is valid, None otherwise
    """
    payload = decode_access_token(token)
    if payload is None:
        return None

    # Verify it's a refresh token
    token_type = payload.get("type")
    if token_type != "refresh":
        return None

    user_id: str = payload.get("sub")
    if user_id is None:
        return None

    return user_id
