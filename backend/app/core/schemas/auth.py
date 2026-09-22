"""
Pydantic schemas for authentication
Contains request and response models for auth endpoints
"""

from typing import Optional, List
from pydantic import BaseModel, EmailStr, Field, field_validator, ConfigDict


# =============================================================================
# AUTHENTICATION SCHEMAS
# =============================================================================


class UserRegister(BaseModel):
    """
    Schema for user registration request
    """

    email: EmailStr = Field(..., description="User email address")
    password: str = Field(
        ..., min_length=8, max_length=100, description="User password"
    )
    full_name: Optional[str] = Field(None, max_length=255, description="User full name")
    phone: Optional[str] = Field(None, max_length=20, description="User phone number")

    @field_validator("password")
    @classmethod
    def validate_password_strength(cls, v: str) -> str:
        """
        Validate password strength
        Requires at least 8 characters with at least one letter and one number
        """
        if len(v) < 8:
            raise ValueError("Password must be at least 8 characters long")

        has_letter = any(c.isalpha() for c in v)
        has_digit = any(c.isdigit() for c in v)

        if not has_letter or not has_digit:
            raise ValueError("Password must contain at least one letter and one number")

        return v


class UserLogin(BaseModel):
    """
    Schema for user login request
    """

    email: EmailStr = Field(..., description="User email address")
    password: str = Field(..., description="User password")


class TokenResponse(BaseModel):
    """
    Schema for token response
    """

    access_token: str = Field(..., description="JWT access token")
    refresh_token: str = Field(..., description="JWT refresh token")
    token_type: str = Field(default="bearer", description="Token type")
    expires_in: int = Field(..., description="Token expiration time in seconds")


class TokenRefresh(BaseModel):
    """
    Schema for token refresh request
    """

    refresh_token: str = Field(..., description="JWT refresh token")


class UserResponse(BaseModel):
    """
    Schema for user response
    """

    id: str = Field(..., description="User ID")
    email: str = Field(..., description="User email")
    full_name: Optional[str] = Field(None, description="User full name")
    phone: Optional[str] = Field(None, description="User phone number")
    is_active: bool = Field(..., description="User active status")
    is_verified: bool = Field(..., description="User verification status")
    status: str = Field(..., description="User account status")
    roles: List[str] = Field(default_factory=list, description="User roles")
    created_at: str = Field(..., description="User creation timestamp")

    model_config = ConfigDict(from_attributes=True)


class UserUpdate(BaseModel):
    """
    Schema for user profile update request
    """

    full_name: Optional[str] = Field(None, max_length=255, description="User full name")
    phone: Optional[str] = Field(None, max_length=20, description="User phone number")


class PasswordChange(BaseModel):
    """
    Schema for password change request
    """

    current_password: str = Field(..., description="Current password")
    new_password: str = Field(
        ..., min_length=8, max_length=100, description="New password"
    )

    @field_validator("new_password")
    @classmethod
    def validate_password_strength(cls, v: str) -> str:
        """
        Validate password strength
        """
        if len(v) < 8:
            raise ValueError("Password must be at least 8 characters long")

        has_letter = any(c.isalpha() for c in v)
        has_digit = any(c.isdigit() for c in v)

        if not has_letter or not has_digit:
            raise ValueError("Password must contain at least one letter and one number")

        return v


class RoleResponse(BaseModel):
    """
    Schema for role response
    """

    id: str = Field(..., description="Role ID")
    name: str = Field(..., description="Role name")
    description: Optional[str] = Field(None, description="Role description")

    model_config = ConfigDict(from_attributes=True)


class RoleAssignment(BaseModel):
    """
    Schema for role assignment request
    """

    role_id: str = Field(..., description="Role ID to assign")


class VerificationRequest(BaseModel):
    """
    Schema for verification request (phone/email verification)
    """

    code: str = Field(..., min_length=4, max_length=6, description="Verification code")
