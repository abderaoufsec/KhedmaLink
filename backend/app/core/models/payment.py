# Payment models for KhedmaLink backend
# Handles payment abstraction, transactions, commission calculation, and payouts

from sqlalchemy import (
    Column,
    String,
    UUID,
    Numeric,
    DateTime,
    ForeignKey,
    Enum as SQLEnum,
    Text,
    Integer,
    func,
)
from sqlalchemy.orm import relationship
from datetime import datetime, timezone
import enum
import uuid

from app.core.database import Base


class PaymentMethod(str, enum.Enum):
    """Payment method enum - provider-independent abstraction"""

    CASH = "cash"  # Cash payments handled manually
    MANUAL = "manual"  # Manual payments (bank transfer, etc.)
    CARD = "card"  # Card payments (abstracted through PSP if approved)
    # NO crypto or custodial escrow allowed


class PaymentStatus(str, enum.Enum):
    """Payment status enum - server-controlled payment states"""

    PENDING = "pending"  # Payment initiated but not processed
    PROCESSING = "processing"  # Payment being processed
    COMPLETED = "completed"  # Payment successfully completed
    FAILED = "failed"  # Payment failed
    REFUNDED = "refunded"  # Payment refunded
    PARTIALLY_REFUNDED = "partially_refunded"  # Payment partially refunded


class TransactionType(str, enum.Enum):
    """Transaction type enum"""

    CAPTURE = "capture"  # Payment capture
    REFUND = "refund"  # Payment refund
    PAYOUT = "payout"  # Provider payout


class PayoutStatus(str, enum.Enum):
    """Payout status enum"""

    PENDING = "pending"  # Payout pending
    PROCESSING = "processing"  # Payout being processed
    COMPLETED = "completed"  # Payout completed
    FAILED = "failed"  # Payout failed


class Payment(Base):
    """
    Payment model for booking payments
    Links to bookings and tracks payment status and amount
    """

    __tablename__ = "payments"
    __table_args__ = {"extend_existing": True}

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    booking_id = Column(
        UUID(as_uuid=True),
        ForeignKey("bookings.id", ondelete="CASCADE"),
        nullable=False,
        unique=True,
    )
    customer_id = Column(
        UUID(as_uuid=True), ForeignKey("users.id", ondelete="CASCADE"), nullable=False
    )
    provider_id = Column(
        UUID(as_uuid=True), ForeignKey("users.id", ondelete="CASCADE"), nullable=False
    )

    # Payment details
    amount = Column(Numeric(precision=10, scale=2), nullable=False)  # Total amount
    currency = Column(String(3), nullable=False, default="DZD")  # Algerian Dinar
    commission_rate = Column(
        Numeric(precision=5, scale=4), nullable=False
    )  # Commission rate (e.g., 0.10 for 10%)
    commission_amount = Column(
        Numeric(precision=10, scale=2), nullable=False
    )  # Commission amount
    provider_amount = Column(
        Numeric(precision=10, scale=2), nullable=False
    )  # Amount to provider

    # Payment method and status
    payment_method = Column(
        SQLEnum(PaymentMethod), nullable=False, default=PaymentMethod.CASH
    )
    status = Column(
        SQLEnum(PaymentStatus), nullable=False, default=PaymentStatus.PENDING
    )

    # External payment reference (if using PSP)
    external_payment_id = Column(String(255), nullable=True)  # PSP payment ID

    # Timestamps
    created_at = Column(DateTime, default=lambda: datetime.now(timezone.utc), nullable=False)
    updated_at = Column(
        DateTime, default=lambda: datetime.now(timezone.utc), onupdate=lambda: datetime.now(timezone.utc), nullable=False
    )
    completed_at = Column(DateTime, nullable=True)

    # Relationships
    booking = relationship("Booking", back_populates="payment")
    customer = relationship("User", foreign_keys=[customer_id])
    provider = relationship("User", foreign_keys=[provider_id])
    transactions = relationship(
        "Transaction", back_populates="payment", cascade="all, delete-orphan"
    )
    payouts = relationship(
        "Payout", back_populates="payment", cascade="all, delete-orphan"
    )

    def __repr__(self):
        return f"<Payment(id={self.id}, booking_id={self.booking_id}, amount={self.amount}, status={self.status})>"


class Transaction(Base):
    """
    Transaction model for tracking individual payment operations
    Captures, refunds, and other payment-related transactions
    """

    __tablename__ = "transactions"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    payment_id = Column(
        UUID(as_uuid=True),
        ForeignKey("payments.id", ondelete="CASCADE"),
        nullable=False,
    )

    # Transaction details
    transaction_type = Column(SQLEnum(TransactionType), nullable=False)
    amount = Column(Numeric(precision=10, scale=2), nullable=False)
    currency = Column(String(3), nullable=False, default="DZD")

    # External transaction reference (if using PSP)
    external_transaction_id = Column(String(255), nullable=True)  # PSP transaction ID

    # Transaction metadata
    transaction_metadata = Column(Text, nullable=True)  # JSON metadata for additional info

    # Timestamps
    created_at = Column(DateTime, default=lambda: datetime.now(timezone.utc), nullable=False)

    # Relationships
    payment = relationship("Payment", back_populates="transactions")

    def __repr__(self):
        return f"<Transaction(id={self.id}, payment_id={self.payment_id}, type={self.transaction_type}, amount={self.amount})>"


class Payout(Base):
    """
    Payout model for tracking payouts to providers
    Providers receive their share after commission deduction
    """

    __tablename__ = "payouts"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    payment_id = Column(
        UUID(as_uuid=True),
        ForeignKey("payments.id", ondelete="CASCADE"),
        nullable=False,
    )
    provider_id = Column(
        UUID(as_uuid=True), ForeignKey("users.id", ondelete="CASCADE"), nullable=False
    )

    # Payout details
    amount = Column(Numeric(precision=10, scale=2), nullable=False)
    currency = Column(String(3), nullable=False, default="DZD")

    # Payout method (cash, bank transfer, etc.)
    payout_method = Column(String(50), nullable=False, default="cash")

    # Payout status
    status = Column(SQLEnum(PayoutStatus), nullable=False, default=PayoutStatus.PENDING)

    # External payout reference (if using PSP)
    external_payout_id = Column(String(255), nullable=True)  # PSP payout ID

    # Notes
    notes = Column(Text, nullable=True)

    # Timestamps
    created_at = Column(DateTime, default=lambda: datetime.now(timezone.utc), nullable=False)
    updated_at = Column(
        DateTime, default=lambda: datetime.now(timezone.utc), onupdate=lambda: datetime.now(timezone.utc), nullable=False
    )
    completed_at = Column(DateTime, nullable=True)

    # Relationships
    payment = relationship("Payment", back_populates="payouts")
    provider = relationship("User")

    def __repr__(self):
        return f"<Payout(id={self.id}, provider_id={self.provider_id}, amount={self.amount}, status={self.status})>"
