"""
User and Role Database Models
Defines the database models for users, roles, and user-role relationships
"""

import uuid
from datetime import datetime
from sqlalchemy import (
    Boolean,
    Column,
    DateTime,
    Enum,
    String,
    Table,
    ForeignKey,
    func,
)
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.orm import relationship

from app.core.database import Base


# =============================================================================
# ASSOCIATION TABLE FOR USER-ROLE MANY-TO-MANY RELATIONSHIP
# =============================================================================

user_roles = Table(
    "user_roles",
    Base.metadata,
    Column(
        "user_id",
        UUID(as_uuid=True),
        ForeignKey("users.id", ondelete="CASCADE"),
        primary_key=True,
    ),
    Column(
        "role_id",
        UUID(as_uuid=True),
        ForeignKey("roles.id", ondelete="CASCADE"),
        primary_key=True,
    ),
)


# =============================================================================
# USER MODEL
# =============================================================================


class User(Base):
    """
    User model representing application users
    Supports both customers and providers with role-based access control
    """

    __tablename__ = "users"

    # Primary key using UUID for security and distributed systems
    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4, index=True)

    # Basic user information
    email = Column(String(255), unique=True, index=True, nullable=False)
    full_name = Column(String(255), nullable=True)
    phone = Column(String(20), nullable=True, unique=True, index=True)

    # Authentication fields
    hashed_password = Column(String(255), nullable=False)
    is_active = Column(Boolean, default=True, nullable=False)
    is_verified = Column(Boolean, default=False, nullable=False)

    # Account status
    status = Column(
        Enum("active", "suspended", "deleted", name="user_status"),
        default="active",
        nullable=False,
    )

    # Timestamps
    created_at = Column(
        DateTime(timezone=True), server_default=func.now(), nullable=False
    )
    updated_at = Column(DateTime(timezone=True), onupdate=func.now(), nullable=False)
    last_login = Column(DateTime(timezone=True), nullable=True)

    # Relationships
    roles = relationship("Role", secondary=user_roles, back_populates="users")

    def __repr__(self) -> str:
        """String representation of the user"""
        return f"<User(id={self.id}, email={self.email}, status={self.status})>"


# =============================================================================
# ROLE MODEL
# =============================================================================


class Role(Base):
    """
    Role model for RBAC (Role-Based Access Control)
    Defines the different roles available in the system
    """

    __tablename__ = "roles"

    # Primary key using UUID
    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4, index=True)

    # Role information
    name = Column(String(50), unique=True, nullable=False, index=True)
    description = Column(String(255), nullable=True)

    # Timestamps
    created_at = Column(
        DateTime(timezone=True), server_default=func.now(), nullable=False
    )
    updated_at = Column(DateTime(timezone=True), onupdate=func.now(), nullable=False)

    # Relationships
    users = relationship("User", secondary=user_roles, back_populates="roles")

    def __repr__(self) -> str:
        """String representation of the role"""
        return f"<Role(id={self.id}, name={self.name})>"


# =============================================================================
# USER ROLE MODEL (OPTIONAL - FOR AUDIT PURPOSES)
# =============================================================================


class UserRole(Base):
    """
    UserRole model for audit trail of role assignments
    Tracks when users are assigned or removed from roles
    """

    __tablename__ = "user_role_history"

    # Primary key using UUID
    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4, index=True)

    # Foreign keys
    user_id = Column(
        UUID(as_uuid=True), ForeignKey("users.id", ondelete="CASCADE"), nullable=False
    )
    role_id = Column(
        UUID(as_uuid=True), ForeignKey("roles.id", ondelete="CASCADE"), nullable=False
    )

    # Action information
    action = Column(Enum("assigned", "removed", name="role_action"), nullable=False)
    performed_by = Column(UUID(as_uuid=True), ForeignKey("users.id"), nullable=True)

    # Timestamps
    created_at = Column(
        DateTime(timezone=True), server_default=func.now(), nullable=False
    )

    def __repr__(self) -> str:
        """String representation of the user role assignment"""
        return f"<UserRole(id={self.id}, user_id={self.user_id}, role_id={self.role_id}, action={self.action})>"
