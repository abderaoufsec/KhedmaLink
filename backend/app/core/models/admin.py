# Admin models for KhedmaLink backend
# Contains audit log model for tracking admin and privileged actions

from datetime import datetime, timezone
from uuid import UUID, uuid4
from sqlalchemy import Column, String, DateTime, ForeignKey, Text, Enum as SQLEnum, func
from sqlalchemy.dialects.postgresql import UUID as PG_UUID
from sqlalchemy.orm import relationship
import enum

from app.core.database import Base


class AuditActionType(str, enum.Enum):
    """Types of auditable actions"""

    # Verification actions
    VERIFICATION_APPROVED = "verification_approved"
    VERIFICATION_REJECTED = "verification_rejected"
    VERIFICATION_REVOKED = "verification_revoked"

    # Suspension actions
    USER_SUSPENDED = "user_suspended"
    USER_UNSUSPENDED = "user_unsuspended"

    # Content moderation
    REVIEW_DELETED = "review_deleted"
    REQUEST_DELETED = "request_deleted"

    # Category management
    CATEGORY_CREATED = "category_created"
    CATEGORY_UPDATED = "category_updated"
    CATEGORY_DELETED = "category_deleted"

    # Platform configuration
    PLATFORM_SETTING_CHANGED = "platform_setting_changed"
    FEATURE_FLAG_CHANGED = "feature_flag_changed"

    # Dispute resolution (pre-M11, tracking admin resolution)
    DISPUTE_RESOLVED = "dispute_resolved"


class AuditLog(Base):
    """
    Audit log for tracking privileged and admin actions
    Ensures all sensitive operations are auditable for compliance and accountability
    """

    __tablename__ = "audit_logs"

    id = Column(PG_UUID(as_uuid=True), primary_key=True, default=uuid4)

    # Action details
    action_type = Column(SQLEnum(AuditActionType), nullable=False, index=True)
    actor_id = Column(
        PG_UUID(as_uuid=True), ForeignKey("users.id"), nullable=False, index=True
    )
    target_user_id = Column(
        PG_UUID(as_uuid=True), ForeignKey("users.id"), nullable=True, index=True
    )
    target_resource_type = Column(
        String(100), nullable=True
    )  # e.g., "provider_profile", "review", "category"
    target_resource_id = Column(PG_UUID(as_uuid=True), nullable=True)

    # Action details
    description = Column(Text, nullable=False)
    reason = Column(Text, nullable=True)  # Optional reason for the action
    changes = Column(Text, nullable=True)  # JSON string of changes made

    # Metadata
    ip_address = Column(String(45), nullable=True)  # IPv4 or IPv6
    user_agent = Column(String(500), nullable=True)

    # Timestamps
    created_at = Column(
        DateTime(timezone=True), default=lambda: datetime.now(timezone.utc), nullable=False, index=True
    )

    # Relationships
    actor = relationship(
        "User", foreign_keys=[actor_id], backref="audit_actions_performed"
    )
    target_user = relationship(
        "User", foreign_keys=[target_user_id], backref="audit_actions_received"
    )

    def __repr__(self):
        return f"<AuditLog(id={self.id}, action_type={self.action_type}, actor_id={self.actor_id})>"
