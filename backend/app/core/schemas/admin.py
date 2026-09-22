# Admin schemas for KhedmaLink backend
# Contains Pydantic schemas for admin operations and audit logs

from datetime import datetime
from uuid import UUID
from typing import Optional, List
from pydantic import BaseModel, Field
from enum import Enum


class AuditActionType(str, Enum):
    """Types of auditable actions"""

    VERIFICATION_APPROVED = "verification_approved"
    VERIFICATION_REJECTED = "verification_rejected"
    VERIFICATION_REVOKED = "verification_revoked"
    USER_SUSPENDED = "user_suspended"
    USER_UNSUSPENDED = "user_unsuspended"
    REVIEW_DELETED = "review_deleted"
    REQUEST_DELETED = "request_deleted"
    CATEGORY_CREATED = "category_created"
    CATEGORY_UPDATED = "category_updated"
    CATEGORY_DELETED = "category_deleted"
    PLATFORM_SETTING_CHANGED = "platform_setting_changed"
    FEATURE_FLAG_CHANGED = "feature_flag_changed"
    DISPUTE_RESOLVED = "dispute_resolved"


class AuditLogCreate(BaseModel):
    """Schema for creating an audit log entry"""

    action_type: AuditActionType = Field(..., description="Type of action performed")
    target_user_id: Optional[UUID] = Field(
        None, description="User affected by the action"
    )
    target_resource_type: Optional[str] = Field(
        None, description="Type of resource affected"
    )
    target_resource_id: Optional[UUID] = Field(
        None, description="ID of resource affected"
    )
    description: str = Field(
        ..., min_length=1, max_length=2000, description="Description of the action"
    )
    reason: Optional[str] = Field(
        None, max_length=2000, description="Reason for the action"
    )
    changes: Optional[str] = Field(None, description="JSON string of changes made")
    ip_address: Optional[str] = Field(
        None, max_length=45, description="IP address of the actor"
    )
    user_agent: Optional[str] = Field(
        None, max_length=500, description="User agent of the actor"
    )


class AuditLogResponse(BaseModel):
    """Schema for audit log response"""

    id: UUID
    action_type: AuditActionType
    actor_id: UUID
    target_user_id: Optional[UUID]
    target_resource_type: Optional[str]
    target_resource_id: Optional[UUID]
    description: str
    reason: Optional[str]
    changes: Optional[str]
    ip_address: Optional[str]
    user_agent: Optional[str]
    created_at: datetime

    class Config:
        from_attributes = True


class AuditLogListResponse(BaseModel):
    """Schema for paginated audit log list"""

    items: List[AuditLogResponse]
    total: int
    page: int
    page_size: int


class UserStatusUpdate(BaseModel):
    """Schema for updating user status (suspend/unsuspend)"""

    user_id: UUID = Field(..., description="ID of the user to update")
    status: str = Field(..., description="New status (active, suspended, deleted)")
    reason: Optional[str] = Field(
        None, max_length=2000, description="Reason for status change"
    )


class UserStatusResponse(BaseModel):
    """Schema for user status update response"""

    id: UUID
    email: str
    status: str
    updated_at: datetime

    class Config:
        from_attributes = True


class VerificationAction(BaseModel):
    """Schema for provider verification actions"""

    provider_id: UUID = Field(..., description="ID of the provider profile")
    action: str = Field(..., description="Action: approve, reject, revoke")
    reason: Optional[str] = Field(
        None, max_length=2000, description="Reason for the action"
    )


class VerificationActionResponse(BaseModel):
    """Schema for verification action response"""

    provider_id: UUID
    verification_status: str
    updated_at: datetime

    class Config:
        from_attributes = True


class ContentDeletion(BaseModel):
    """Schema for deleting content (reviews, requests, etc.)"""

    resource_type: str = Field(
        ..., description="Type of resource: review, request, etc."
    )
    resource_id: UUID = Field(..., description="ID of the resource to delete")
    reason: Optional[str] = Field(
        None, max_length=2000, description="Reason for deletion"
    )


class UserListFilters(BaseModel):
    """Schema for user list filters"""

    status: Optional[str] = Field(None, description="Filter by user status")
    role: Optional[str] = Field(None, description="Filter by role")
    email: Optional[str] = Field(None, description="Filter by email (partial match)")
    page: int = Field(1, ge=1, description="Page number")
    page_size: int = Field(20, ge=1, le=100, description="Page size")


class UserListItem(BaseModel):
    """Schema for user list item"""

    id: UUID
    email: str
    full_name: Optional[str]
    phone: Optional[str]
    status: str
    is_active: bool
    is_verified: bool
    created_at: datetime
    last_login: Optional[datetime]

    class Config:
        from_attributes = True


class UserListResponse(BaseModel):
    """Schema for paginated user list"""

    items: List[UserListItem]
    total: int
    page: int
    page_size: int


class ProviderVerificationQueueItem(BaseModel):
    """Schema for provider verification queue item"""

    provider_id: UUID
    user_id: UUID
    business_name: Optional[str]
    business_type: Optional[str]
    verification_status: str
    verification_level: str
    submitted_at: Optional[datetime]
    created_at: datetime

    class Config:
        from_attributes = True


class VerificationQueueResponse(BaseModel):
    """Schema for verification queue response"""

    items: List[ProviderVerificationQueueItem]
    total: int
    page: int
    page_size: int
