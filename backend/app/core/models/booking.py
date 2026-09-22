"""
Booking Database Models
Defines the database models for bookings and booking events
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
# BOOKING MODEL
# =============================================================================


class Booking(Base):
    """
    Booking model for service bookings
    Represents a confirmed service booking after quote acceptance
    """

    __tablename__ = "bookings"

    # Primary key using UUID
    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4, index=True)

    # Foreign keys
    request_id = Column(
        UUID(as_uuid=True),
        ForeignKey("service_requests.id", ondelete="CASCADE"),
        nullable=False,
        index=True,
    )
    quote_id = Column(
        UUID(as_uuid=True),
        ForeignKey("quotes.id", ondelete="RESTRICT"),
        nullable=False,
        index=True,
    )
    customer_id = Column(
        UUID(as_uuid=True),
        ForeignKey("users.id", ondelete="CASCADE"),
        nullable=False,
        index=True,
    )
    provider_id = Column(
        UUID(as_uuid=True),
        ForeignKey("users.id", ondelete="CASCADE"),
        nullable=False,
        index=True,
    )

    # Scheduling information
    scheduled_date = Column(DateTime(timezone=True), nullable=True)
    scheduled_time_start = Column(String(10), nullable=True)  # HH:MM format
    scheduled_time_end = Column(String(10), nullable=True)  # HH:MM format
    estimated_duration = Column(Integer, nullable=True)  # in minutes
    estimated_duration_unit = Column(String(20), nullable=True, default="minutes")

    # Pricing information
    agreed_price = Column(Float, nullable=False)
    currency = Column(String(3), nullable=False, default="DZD")

    # Location (copied from request for audit trail)
    address = Column(String(500), nullable=True)
    city = Column(String(100), nullable=True)
    wilaya = Column(String(100), nullable=True)
    latitude = Column(Float, nullable=True)
    longitude = Column(Float, nullable=True)

    # Booking status (state machine)
    # DRAFT → PENDING → QUOTED → ACCEPTED → SCHEDULED → IN_PROGRESS → COMPLETED
    # Terminal states: CANCELLED, EXPIRED, REJECTED, DISPUTED
    status = Column(
        Enum(
            "draft",
            "pending",
            "quoted",
            "accepted",
            "scheduled",
            "in_progress",
            "completed",
            "cancelled",
            "expired",
            "rejected",
            "disputed",
            name="booking_status",
        ),
        default="accepted",
        nullable=False,
        index=True,
    )

    # Cancellation information
    cancelled_at = Column(DateTime(timezone=True), nullable=True)
    cancelled_by = Column(UUID(as_uuid=True), nullable=True)  # User ID who cancelled
    cancellation_reason = Column(Text, nullable=True)

    # Completion information
    completed_at = Column(DateTime(timezone=True), nullable=True)
    completion_notes = Column(Text, nullable=True)

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
    request = relationship("ServiceRequest", backref="bookings")
    quote = relationship("Quote", backref="booking")
    events = relationship(
        "BookingEvent", backref="booking", cascade="all, delete-orphan"
    )
    payment = relationship("Payment", back_populates="booking", uselist=False)

    def __repr__(self):
        return f"<Booking(id={self.id}, status={self.status}, customer_id={self.customer_id}, provider_id={self.provider_id})>"


# =============================================================================
# BOOKING EVENT MODEL
# =============================================================================


class BookingEvent(Base):
    """
    Booking event model for tracking state transitions
    Each state change is recorded as an event for audit trail
    """

    __tablename__ = "booking_events"

    # Primary key using UUID
    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4, index=True)

    # Foreign key to Booking
    booking_id = Column(
        UUID(as_uuid=True),
        ForeignKey("bookings.id", ondelete="CASCADE"),
        nullable=False,
        index=True,
    )

    # Foreign key to User (who triggered the event)
    triggered_by = Column(
        UUID(as_uuid=True),
        ForeignKey("users.id", ondelete="SET NULL"),
        nullable=True,
        index=True,
    )

    # Event information
    event_type = Column(
        Enum(
            "created",
            "scheduled",
            "started",
            "completed",
            "cancelled",
            "disputed",
            "status_changed",
            name="booking_event_type",
        ),
        nullable=False,
    )

    # State transition
    old_status = Column(String(20), nullable=True)
    new_status = Column(String(20), nullable=True)

    # Event details
    notes = Column(Text, nullable=True)
    event_metadata = Column(Text, nullable=True)  # JSON string for additional data

    # Timestamp
    created_at = Column(
        DateTime(timezone=True),
        server_default=func.now(),
        nullable=False,
    )

    def __repr__(self):
        return f"<BookingEvent(id={self.id}, event_type={self.event_type}, booking_id={self.booking_id})>"
