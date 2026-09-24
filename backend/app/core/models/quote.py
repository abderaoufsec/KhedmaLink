"""
Quote Database Models
Defines the database models for quotes and quote matching
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
# QUOTE MODEL
# =============================================================================


class Quote(Base):
    """
    Quote model for provider quotes on service requests
    Represents a provider's offer for a service request
    """

    __tablename__ = "quotes"

    # Primary key using UUID
    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4, index=True)

    # Foreign keys
    request_id = Column(
        UUID(as_uuid=True),
        ForeignKey("service_requests.id", ondelete="CASCADE"),
        nullable=False,
        index=True,
    )
    provider_id = Column(
        UUID(as_uuid=True),
        ForeignKey("users.id", ondelete="CASCADE"),
        nullable=False,
        index=True,
    )

    # Quote information
    description = Column(Text, nullable=True)  # Quote description/details
    estimated_price = Column(Float, nullable=False)  # Estimated price
    currency = Column(String(3), nullable=False, default="DZD")  # Currency code
    estimated_duration = Column(Integer, nullable=True)  # Duration in minutes
    estimated_duration_unit = Column(String(20), nullable=True)  # minutes, hours, days

    # Availability information
    available_date = Column(DateTime(timezone=True), nullable=True)
    available_time_start = Column(String(10), nullable=True)  # HH:MM format
    available_time_end = Column(String(10), nullable=True)  # HH:MM format

    # Quote status
    status = Column(
        Enum(
            "draft",
            "submitted",
            "withdrawn",
            "accepted",
            "rejected",
            "expired",
            name="quote_status",
        ),
        default="draft",
        nullable=False,
        index=True,
    )

    # Rejection information
    rejection_reason = Column(Text, nullable=True)
    rejected_at = Column(DateTime(timezone=True), nullable=True)

    # Timestamps
    created_at = Column(
        DateTime(timezone=True), server_default=func.now(), nullable=False
    )
    updated_at = Column(DateTime(timezone=True), server_default=func.now(), onupdate=func.now(), nullable=True)
    submitted_at = Column(DateTime(timezone=True), nullable=True)
    accepted_at = Column(DateTime(timezone=True), nullable=True)

    # Relationships
    request = relationship("ServiceRequest", backref="quotes")
    provider = relationship("User", backref="quotes")

    def __repr__(self) -> str:
        """String representation of the quote"""
        return f"<Quote(id={self.id}, request_id={self.request_id}, provider_id={self.provider_id}, status={self.status})>"


# =============================================================================
# REQUEST MATCH MODEL
# =============================================================================


class RequestMatch(Base):
    """
    Request match model for tracking provider-request matching
    Records which providers are eligible for which requests
    """

    __tablename__ = "request_matches"

    # Primary key using UUID
    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4, index=True)

    # Foreign keys
    request_id = Column(
        UUID(as_uuid=True),
        ForeignKey("service_requests.id", ondelete="CASCADE"),
        nullable=False,
        index=True,
    )
    provider_id = Column(
        UUID(as_uuid=True),
        ForeignKey("users.id", ondelete="CASCADE"),
        nullable=False,
        index=True,
    )

    # Match information
    match_score = Column(Float, nullable=True)  # Match score (0-100)
    eligibility_reason = Column(Text, nullable=True)  # Why this provider is eligible

    # Status
    status = Column(
        Enum(
            "eligible",
            "declined",
            "quoted",
            name="match_status",
        ),
        default="eligible",
        nullable=False,
    )

    # Timestamps
    created_at = Column(
        DateTime(timezone=True), server_default=func.now(), nullable=False
    )
    updated_at = Column(DateTime(timezone=True), server_default=func.now(), onupdate=func.now(), nullable=True)

    # Relationships
    request = relationship("ServiceRequest", backref="matches")
    provider = relationship("User", backref="request_matches")

    def __repr__(self) -> str:
        """String representation of the request match"""
        return f"<RequestMatch(id={self.id}, request_id={self.request_id}, provider_id={self.provider_id}, status={self.status})>"
