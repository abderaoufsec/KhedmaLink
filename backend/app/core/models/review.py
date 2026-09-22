"""
Review Database Models
Defines the database models for reviews and provider reputation
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
# REVIEW MODEL
# =============================================================================


class Review(Base):
    """
    Review model for customer reviews of completed bookings
    Reviews are tied to specific bookings and can only be created after completion
    """

    __tablename__ = "reviews"

    # Primary key using UUID
    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4, index=True)

    # Foreign key to Booking
    booking_id = Column(
        UUID(as_uuid=True),
        ForeignKey("bookings.id", ondelete="CASCADE"),
        nullable=False,
        unique=True,  # One review per booking
        index=True,
    )

    # Foreign key to User (customer who wrote the review)
    customer_id = Column(
        UUID(as_uuid=True),
        ForeignKey("users.id", ondelete="CASCADE"),
        nullable=False,
        index=True,
    )

    # Foreign key to Provider (provider being reviewed)
    provider_id = Column(
        UUID(as_uuid=True),
        ForeignKey("users.id", ondelete="CASCADE"),
        nullable=False,
        index=True,
    )

    # Rating (1-5 stars)
    rating = Column(Integer, nullable=False, index=True)

    # Review content
    title = Column(String(255), nullable=True)
    comment = Column(Text, nullable=True)

    # Rating categories (for detailed feedback)
    professionalism = Column(Integer, nullable=True)  # 1-5
    quality = Column(Integer, nullable=True)  # 1-5
    timeliness = Column(Integer, nullable=True)  # 1-5
    communication = Column(Integer, nullable=True)  # 1-5
    value = Column(Integer, nullable=True)  # 1-5

    # Response from provider
    provider_response = Column(Text, nullable=True)
    provider_response_at = Column(DateTime(timezone=True), nullable=True)

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
    booking = relationship("Booking", backref="review")
    customer = relationship("User", foreign_keys=[customer_id], backref="given_reviews")
    provider = relationship(
        "User", foreign_keys=[provider_id], backref="received_reviews"
    )

    def __repr__(self):
        return f"<Review(id={self.id}, booking_id={self.booking_id}, rating={self.rating})>"
