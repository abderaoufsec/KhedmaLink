"""
Service Request Database Models
Defines the database models for customer service requests and attachments
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
# SERVICE REQUEST MODEL
# =============================================================================


class ServiceRequest(Base):
    """
    Service request model for customer service requests
    Represents a customer's request for a service
    """

    __tablename__ = "service_requests"

    # Primary key using UUID
    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4, index=True)

    # Foreign key to User (customer)
    customer_id = Column(
        UUID(as_uuid=True),
        ForeignKey("users.id", ondelete="CASCADE"),
        nullable=False,
        index=True,
    )

    # Foreign key to Category
    category_id = Column(
        UUID(as_uuid=True),
        ForeignKey("categories.id", ondelete="RESTRICT"),
        nullable=False,
        index=True,
    )

    # Request information
    title_ar = Column(String(255), nullable=False, index=True)  # Arabic title
    title_fr = Column(String(255), nullable=False, index=True)  # French title
    description_ar = Column(Text, nullable=False)  # Arabic description
    description_fr = Column(Text, nullable=False)  # French description

    # Location information
    city = Column(String(100), nullable=False, index=True)
    wilaya = Column(String(100), nullable=False, index=True)
    commune = Column(String(100), nullable=True, index=True)
    address = Column(String(500), nullable=True)
    latitude = Column(Float, nullable=True)
    longitude = Column(Float, nullable=True)

    # Scheduling information
    preferred_date = Column(DateTime(timezone=True), nullable=True)
    preferred_time_start = Column(String(10), nullable=True)  # HH:MM format
    preferred_time_end = Column(String(10), nullable=True)  # HH:MM format
    is_flexible = Column(Boolean, default=False, nullable=False)  # Flexible schedule

    # Budget information
    budget_min = Column(Float, nullable=True)
    budget_max = Column(Float, nullable=True)
    currency = Column(String(3), nullable=False, default="DZD")  # Algerian Dinar

    # Request status
    status = Column(
        Enum(
            "draft",
            "open",
            "closed",
            "cancelled",
            name="request_status",
        ),
        default="open",
        nullable=False,
        index=True,
    )

    # Urgency
    urgency = Column(
        Enum(
            "low",
            "medium",
            "high",
            "urgent",
            name="urgency_level",
        ),
        default="medium",
        nullable=False,
    )

    # Visibility
    is_public = Column(Boolean, default=True, nullable=False)  # Visible to providers

    # Timestamps
    created_at = Column(
        DateTime(timezone=True), server_default=func.now(), nullable=False
    )
    updated_at = Column(DateTime(timezone=True), onupdate=func.now(), nullable=False)
    closed_at = Column(DateTime(timezone=True), nullable=True)

    # Relationships
    customer = relationship("User", backref="service_requests")
    category = relationship("Category", backref="service_requests")
    attachments = relationship(
        "RequestAttachment", back_populates="request", cascade="all, delete-orphan"
    )

    def __repr__(self) -> str:
        """String representation of the service request"""
        return f"<ServiceRequest(id={self.id}, customer_id={self.customer_id}, status={self.status})>"


# =============================================================================
# REQUEST ATTACHMENT MODEL
# =============================================================================


class RequestAttachment(Base):
    """
    Request attachment model for photos and documents attached to service requests
    """

    __tablename__ = "request_attachments"

    # Primary key using UUID
    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4, index=True)

    # Foreign key to ServiceRequest
    request_id = Column(
        UUID(as_uuid=True),
        ForeignKey("service_requests.id", ondelete="CASCADE"),
        nullable=False,
        index=True,
    )

    # Attachment information
    file_url = Column(String(500), nullable=False)  # S3 or storage URL
    file_name = Column(String(255), nullable=False)  # Original filename
    file_type = Column(String(100), nullable=False)  # MIME type (image/jpeg, etc.)
    file_size = Column(Integer, nullable=False)  # Size in bytes
    thumbnail_url = Column(String(500), nullable=True)  # Thumbnail URL for images

    # Attachment type
    attachment_type = Column(
        Enum(
            "photo",
            "document",
            "other",
            name="attachment_type",
        ),
        default="photo",
        nullable=False,
    )

    # Upload information
    uploaded_by = Column(
        UUID(as_uuid=True),
        ForeignKey("users.id", ondelete="SET NULL"),
        nullable=True,
    )
    upload_status = Column(
        Enum(
            "pending",
            "uploaded",
            "failed",
            name="upload_status",
        ),
        default="uploaded",
        nullable=False,
    )

    # Timestamps
    created_at = Column(
        DateTime(timezone=True), server_default=func.now(), nullable=False
    )

    # Relationships
    request = relationship("ServiceRequest", back_populates="attachments")

    def __repr__(self) -> str:
        """String representation of the request attachment"""
        return f"<RequestAttachment(id={self.id}, request_id={self.request_id}, file_name={self.file_name})>"
