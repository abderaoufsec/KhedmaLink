"""
Messaging Database Models
Defines the database models for messages, message attachments, and notifications
"""

import uuid
from datetime import datetime
from sqlalchemy import (
    Boolean,
    Column,
    DateTime,
    Enum,
    String,
    Text,
    Integer,
    Float,
    ForeignKey,
    func,
)
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.orm import relationship

from app.core.database import Base


# =============================================================================
# MESSAGE MODEL
# =============================================================================


class Message(Base):
    """
    Message model for booking-scoped messaging
    Messages are tied to a specific booking between customer and provider
    """

    __tablename__ = "messages"

    # Primary key using UUID
    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4, index=True)

    # Foreign key to Booking
    booking_id = Column(
        UUID(as_uuid=True),
        ForeignKey("bookings.id", ondelete="CASCADE"),
        nullable=False,
        index=True,
    )

    # Foreign key to User (sender)
    sender_id = Column(
        UUID(as_uuid=True),
        ForeignKey("users.id", ondelete="CASCADE"),
        nullable=False,
        index=True,
    )

    # Message content
    content = Column(Text, nullable=False)

    # Message type
    message_type = Column(
        Enum(
            "text",
            "image",
            "system",
            name="message_type",
        ),
        default="text",
        nullable=False,
    )

    # Read status
    is_read = Column(Boolean, default=False, nullable=False, index=True)
    read_at = Column(DateTime(timezone=True), nullable=True)

    # Timestamps
    created_at = Column(
        DateTime(timezone=True),
        server_default=func.now(),
        nullable=False,
    )
    updated_at = Column(
        DateTime(timezone=True),
        server_default=func.now(),
        onupdate=func.now(),
        nullable=False,
    )

    # Relationships
    booking = relationship("Booking", backref="messages")
    sender = relationship("User", backref="sent_messages")
    attachments = relationship(
        "MessageAttachment", back_populates="message", cascade="all, delete-orphan"
    )

    def __repr__(self):
        return f"<Message(id={self.id}, booking_id={self.booking_id}, sender_id={self.sender_id})>"


# =============================================================================
# MESSAGE ATTACHMENT MODEL
# =============================================================================


class MessageAttachment(Base):
    """
    Message attachment model for images and files
    Attachments are tied to specific messages
    """

    __tablename__ = "message_attachments"

    # Primary key using UUID
    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4, index=True)

    # Foreign key to Message
    message_id = Column(
        UUID(as_uuid=True),
        ForeignKey("messages.id", ondelete="CASCADE"),
        nullable=False,
        index=True,
    )

    # File information
    file_name = Column(String(255), nullable=False)
    file_url = Column(Text, nullable=False)  # S3 or storage URL
    file_size = Column(Integer, nullable=False)  # Size in bytes
    file_type = Column(String(100), nullable=False)  # MIME type

    # Upload status
    upload_status = Column(
        Enum(
            "pending",
            "uploaded",
            "failed",
            name="upload_status",
        ),
        default="pending",
        nullable=False,
    )

    # Timestamps
    created_at = Column(
        DateTime(timezone=True),
        server_default=func.now(),
        nullable=False,
    )

    # Relationships
    message = relationship("Message", back_populates="attachments")

    def __repr__(self):
        return f"<MessageAttachment(id={self.id}, message_id={self.message_id}, file_name={self.file_name})>"


# =============================================================================
# NOTIFICATION MODEL
# =============================================================================


class Notification(Base):
    """
    Notification model for system notifications
    Notifications are user-specific for important events
    """

    __tablename__ = "notifications"

    # Primary key using UUID
    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4, index=True)

    # Foreign key to User (recipient)
    user_id = Column(
        UUID(as_uuid=True),
        ForeignKey("users.id", ondelete="CASCADE"),
        nullable=False,
        index=True,
    )

    # Notification type
    notification_type = Column(
        Enum(
            "quote_received",
            "quote_accepted",
            "booking_created",
            "booking_scheduled",
            "booking_started",
            "booking_completed",
            "booking_cancelled",
            "message_received",
            name="notification_type",
        ),
        nullable=False,
    )

    # Notification title (bilingual)
    title_ar = Column(String(255), nullable=False)
    title_fr = Column(String(255), nullable=False)

    # Notification body (bilingual)
    body_ar = Column(Text, nullable=True)
    body_fr = Column(Text, nullable=True)

    # Reference to related entity
    entity_type = Column(
        String(50), nullable=True
    )  # e.g., "booking", "quote", "message"
    entity_id = Column(UUID(as_uuid=True), nullable=True)  # ID of the related entity

    # Read status
    is_read = Column(Boolean, default=False, nullable=False, index=True)
    read_at = Column(DateTime(timezone=True), nullable=True)

    # Timestamps
    created_at = Column(
        DateTime(timezone=True),
        server_default=func.now(),
        nullable=False,
    )

    # Relationships
    user = relationship("User", backref="notifications")

    def __repr__(self):
        return f"<Notification(id={self.id}, user_id={self.user_id}, type={self.notification_type})>"
