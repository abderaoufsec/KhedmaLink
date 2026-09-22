"""
Pydantic schemas for messaging and notifications operations
Contains request and response models for messages, attachments, and notifications
"""

from typing import Optional, List
from pydantic import BaseModel, Field, field_validator, ConfigDict
from datetime import datetime


# =============================================================================
# MESSAGE SCHEMAS
# =============================================================================


class MessageBase(BaseModel):
    """
    Base schema for message operations
    Contains common fields for message requests and responses
    """

    booking_id: str = Field(..., description="Booking ID")
    content: str = Field(
        ..., min_length=1, max_length=5000, description="Message content"
    )
    message_type: str = Field(
        default="text", description="Message type (text, image, system)"
    )


class MessageCreate(MessageBase):
    """
    Schema for creating a new message
    Used when a user sends a message in a booking
    """

    pass


class MessageResponse(MessageBase):
    """
    Schema for message response
    Includes all message fields with timestamps
    """

    model_config = ConfigDict(from_attributes=True)

    id: str = Field(..., description="Message ID")
    sender_id: str = Field(..., description="Sender user ID")
    is_read: bool = Field(..., description="Read status")
    read_at: Optional[datetime] = Field(None, description="Read timestamp")
    created_at: datetime = Field(..., description="Creation timestamp")
    updated_at: datetime = Field(..., description="Last update timestamp")


class MessageUpdate(BaseModel):
    """
    Schema for updating a message
    Allows marking messages as read
    """

    is_read: bool = Field(..., description="Read status")


# =============================================================================
# MESSAGE ATTACHMENT SCHEMAS
# =============================================================================


class MessageAttachmentBase(BaseModel):
    """
    Base schema for message attachment operations
    Contains common fields for message attachments
    """

    message_id: str = Field(..., description="Message ID")
    file_name: str = Field(..., max_length=255, description="File name")
    file_url: str = Field(..., description="File URL (S3 or storage)")
    file_size: int = Field(..., gt=0, description="File size in bytes")
    file_type: str = Field(..., max_length=100, description="MIME type")


class MessageAttachmentCreate(MessageAttachmentBase):
    """
    Schema for creating a new message attachment
    Used when uploading images with messages
    """

    pass


class MessageAttachmentResponse(MessageAttachmentBase):
    """
    Schema for message attachment response
    Includes all attachment fields with timestamp
    """

    model_config = ConfigDict(from_attributes=True)

    id: str = Field(..., description="Attachment ID")
    upload_status: str = Field(..., description="Upload status")
    created_at: datetime = Field(..., description="Creation timestamp")


# =============================================================================
# NOTIFICATION SCHEMAS
# =============================================================================


class NotificationBase(BaseModel):
    """
    Base schema for notification operations
    Contains common fields for notifications
    """

    notification_type: str = Field(..., description="Notification type")
    title_ar: str = Field(..., max_length=255, description="Title in Arabic")
    title_fr: str = Field(..., max_length=255, description="Title in French")
    body_ar: Optional[str] = Field(None, description="Body in Arabic")
    body_fr: Optional[str] = Field(None, description="Body in French")
    entity_type: Optional[str] = Field(
        None, max_length=50, description="Related entity type"
    )
    entity_id: Optional[str] = Field(None, description="Related entity ID")


class NotificationCreate(NotificationBase):
    """
    Schema for creating a notification
    Used by the system to generate notifications
    """

    user_id: str = Field(..., description="Recipient user ID")


class NotificationResponse(NotificationBase):
    """
    Schema for notification response
    Includes all notification fields with timestamps
    """

    model_config = ConfigDict(from_attributes=True)

    id: str = Field(..., description="Notification ID")
    user_id: str = Field(..., description="Recipient user ID")
    is_read: bool = Field(..., description="Read status")
    read_at: Optional[datetime] = Field(None, description="Read timestamp")
    created_at: datetime = Field(..., description="Creation timestamp")


class NotificationUpdate(BaseModel):
    """
    Schema for updating a notification
    Allows marking notifications as read
    """

    is_read: bool = Field(..., description="Read status")


# =============================================================================
# MESSAGE LIST SCHEMAS
# =============================================================================


class MessageListResponse(BaseModel):
    """
    Schema for message list response
    Includes pagination metadata
    """

    messages: List[MessageResponse] = Field(..., description="List of messages")
    total: int = Field(..., description="Total number of messages")
    skip: int = Field(..., description="Number of messages skipped")
    limit: int = Field(..., description="Maximum number of messages returned")


class NotificationListResponse(BaseModel):
    """
    Schema for notification list response
    Includes pagination metadata
    """

    notifications: List[NotificationResponse] = Field(
        ..., description="List of notifications"
    )
    total: int = Field(..., description="Total number of notifications")
    skip: int = Field(..., description="Number of notifications skipped")
    limit: int = Field(..., description="Maximum number of notifications returned")
