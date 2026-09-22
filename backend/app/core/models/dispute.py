# Dispute models for KhedmaLink backend
# Contains database models for disputes and dispute evidence

from datetime import datetime
from uuid import UUID, uuid4
from sqlalchemy import Column, String, DateTime, ForeignKey, Text, Enum as SQLEnum
from sqlalchemy.dialects.postgresql import UUID as PG_UUID
from sqlalchemy.orm import relationship
import enum

from app.core.database import Base


class DisputeStatus(str, enum.Enum):
    """Status of a dispute"""

    OPEN = "open"
    INVESTIGATING = "investigating"
    RESOLVED = "resolved"
    CLOSED = "closed"


class DisputeType(str, enum.Enum):
    """Type of dispute"""

    SERVICE_QUALITY = "service_quality"
    PAYMENT_ISSUE = "payment_issue"
    COMMUNICATION = "communication"
    DAMAGE = "damage"
    SAFETY = "safety"
    OTHER = "other"


class Dispute(Base):
    """
    Dispute model for tracking conflicts between customers and providers
    Linked to bookings for context and resolution
    """

    __tablename__ = "disputes"

    id = Column(PG_UUID(as_uuid=True), primary_key=True, default=uuid4)

    # Foreign keys
    booking_id = Column(
        PG_UUID(as_uuid=True), ForeignKey("bookings.id"), nullable=False, index=True
    )
    raised_by = Column(
        PG_UUID(as_uuid=True), ForeignKey("users.id"), nullable=False, index=True
    )

    # Dispute details
    dispute_type = Column(SQLEnum(DisputeType), nullable=False)
    status = Column(
        SQLEnum(DisputeStatus), default=DisputeStatus.OPEN, nullable=False, index=True
    )
    title = Column(String(255), nullable=False)
    description = Column(Text, nullable=False)

    # Resolution details
    resolution = Column(Text, nullable=True)
    resolved_by = Column(PG_UUID(as_uuid=True), ForeignKey("users.id"), nullable=True)
    resolved_at = Column(DateTime(timezone=True), nullable=True)

    # Timestamps
    created_at = Column(
        DateTime(timezone=True), default=datetime.utcnow, nullable=False, index=True
    )
    updated_at = Column(
        DateTime(timezone=True),
        default=datetime.utcnow,
        onupdate=datetime.utcnow,
        nullable=False,
    )

    # Relationships
    booking = relationship("Booking", backref="disputes")
    raiser = relationship("User", foreign_keys=[raised_by], backref="raised_disputes")
    resolver = relationship(
        "User", foreign_keys=[resolved_by], backref="resolved_disputes"
    )
    evidence = relationship(
        "DisputeEvidence", back_populates="dispute", cascade="all, delete-orphan"
    )

    def __repr__(self):
        return f"<Dispute(id={self.id}, booking_id={self.booking_id}, status={self.status})>"


class DisputeEvidence(Base):
    """
    Dispute evidence model for attaching proof to disputes
    Supports images, documents, and text evidence
    """

    __tablename__ = "dispute_evidence"

    id = Column(PG_UUID(as_uuid=True), primary_key=True, default=uuid4)

    # Foreign keys
    dispute_id = Column(
        PG_UUID(as_uuid=True),
        ForeignKey("disputes.id", ondelete="CASCADE"),
        nullable=False,
        index=True,
    )
    submitted_by = Column(
        PG_UUID(as_uuid=True), ForeignKey("users.id"), nullable=False, index=True
    )

    # Evidence details
    evidence_type = Column(String(50), nullable=False)  # image, document, text
    file_url = Column(String(500), nullable=True)  # URL to stored file
    file_name = Column(String(255), nullable=True)
    file_size = Column(String(50), nullable=True)  # Human-readable size
    mime_type = Column(String(100), nullable=True)
    description = Column(Text, nullable=True)

    # Timestamps
    created_at = Column(
        DateTime(timezone=True), default=datetime.utcnow, nullable=False
    )

    # Relationships
    dispute = relationship("Dispute", back_populates="evidence")
    submitter = relationship("User", backref="submitted_evidence")

    def __repr__(self):
        return f"<DisputeEvidence(id={self.id}, dispute_id={self.dispute_id}, type={self.evidence_type})>"
