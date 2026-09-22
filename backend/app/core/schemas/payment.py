# Payment schemas for KhedmaLink backend
# Pydantic schemas for payment operations

from pydantic import BaseModel, Field, validator
from typing import Optional, List
from datetime import datetime
from decimal import Decimal
from enum import Enum

from app.core.models.payment import (
    PaymentMethod,
    PaymentStatus,
    TransactionType,
    PayoutStatus,
)


# =============================================================================
# PAYMENT SCHEMAS
# =============================================================================


class PaymentMethodEnum(str, Enum):
    """Payment method enum for API"""

    CASH = "cash"
    MANUAL = "manual"
    CARD = "card"


class PaymentStatusEnum(str, Enum):
    """Payment status enum for API"""

    PENDING = "pending"
    PROCESSING = "processing"
    COMPLETED = "completed"
    FAILED = "failed"
    REFUNDED = "refunded"
    PARTIALLY_REFUNDED = "partially_refunded"


class PaymentCreate(BaseModel):
    """Schema for creating a payment"""

    booking_id: str = Field(..., description="ID of the booking to pay for")
    payment_method: PaymentMethodEnum = Field(
        default=PaymentMethodEnum.CASH,
        description="Payment method (cash, manual, or card)",
    )
    external_payment_id: Optional[str] = Field(
        None, description="External payment ID from PSP (if using card)"
    )

    class Config:
        json_schema_extra = {
            "example": {
                "booking_id": "123e4567-e89b-12d3-a456-426614174000",
                "payment_method": "cash",
            }
        }


class PaymentUpdate(BaseModel):
    """Schema for updating a payment (status changes)"""

    status: Optional[PaymentStatusEnum] = Field(None, description="New payment status")
    external_payment_id: Optional[str] = Field(
        None, description="External payment ID from PSP"
    )

    class Config:
        json_schema_extra = {
            "example": {
                "status": "completed",
            }
        }


class PaymentResponse(BaseModel):
    """Schema for payment response"""

    id: str
    booking_id: str
    customer_id: str
    provider_id: str
    amount: Decimal
    currency: str
    commission_rate: Decimal
    commission_amount: Decimal
    provider_amount: Decimal
    payment_method: PaymentMethodEnum
    status: PaymentStatusEnum
    external_payment_id: Optional[str]
    created_at: datetime
    updated_at: datetime
    completed_at: Optional[datetime]

    class Config:
        from_attributes = True


class PaymentListResponse(BaseModel):
    """Schema for payment list response with pagination"""

    items: List[PaymentResponse]
    total: int
    page: int
    page_size: int


# =============================================================================
# TRANSACTION SCHEMAS
# =============================================================================


class TransactionTypeEnum(str, Enum):
    """Transaction type enum for API"""

    CAPTURE = "capture"
    REFUND = "refund"
    PAYOUT = "payout"


class TransactionCreate(BaseModel):
    """Schema for creating a transaction"""

    transaction_type: TransactionTypeEnum = Field(
        ..., description="Type of transaction"
    )
    amount: Decimal = Field(..., gt=0, description="Transaction amount")
    currency: str = Field(default="DZD", description="Currency code")
    external_transaction_id: Optional[str] = Field(
        None, description="External transaction ID from PSP"
    )
    transaction_metadata: Optional[str] = Field(
        None, description="Additional metadata as JSON string"
    )

    class Config:
        json_schema_extra = {
            "example": {
                "transaction_type": "capture",
                "amount": 1000.00,
                "currency": "DZD",
            }
        }


class TransactionResponse(BaseModel):
    """Schema for transaction response"""

    id: str
    payment_id: str
    transaction_type: TransactionTypeEnum
    amount: Decimal
    currency: str
    external_transaction_id: Optional[str]
    transaction_metadata: Optional[str]
    created_at: datetime

    class Config:
        from_attributes = True


class TransactionListResponse(BaseModel):
    """Schema for transaction list response"""

    items: List[TransactionResponse]


# =============================================================================
# PAYOUT SCHEMAS
# =============================================================================


class PayoutStatusEnum(str, Enum):
    """Payout status enum for API"""

    PENDING = "pending"
    PROCESSING = "processing"
    COMPLETED = "completed"
    FAILED = "failed"


class PayoutCreate(BaseModel):
    """Schema for creating a payout"""

    payout_method: str = Field(
        default="cash", description="Payout method (cash, bank transfer, etc.)"
    )
    external_payout_id: Optional[str] = Field(
        None, description="External payout ID from PSP"
    )
    notes: Optional[str] = Field(None, description="Additional notes for the payout")

    class Config:
        json_schema_extra = {
            "example": {
                "payout_method": "cash",
                "notes": "Cash payment for completed service",
            }
        }


class PayoutUpdate(BaseModel):
    """Schema for updating a payout"""

    status: Optional[PayoutStatusEnum] = Field(None, description="New payout status")
    external_payout_id: Optional[str] = Field(
        None, description="External payout ID from PSP"
    )
    notes: Optional[str] = Field(None, description="Additional notes for the payout")

    class Config:
        json_schema_extra = {
            "example": {
                "status": "completed",
            }
        }


class PayoutResponse(BaseModel):
    """Schema for payout response"""

    id: str
    payment_id: str
    provider_id: str
    amount: Decimal
    currency: str
    payout_method: str
    status: PayoutStatusEnum
    external_payout_id: Optional[str]
    notes: Optional[str]
    created_at: datetime
    updated_at: datetime
    completed_at: Optional[datetime]

    class Config:
        from_attributes = True


class PayoutListResponse(BaseModel):
    """Schema for payout list response"""

    items: List[PayoutResponse]


# =============================================================================
# REFUND SCHEMAS
# =============================================================================


class RefundCreate(BaseModel):
    """Schema for creating a refund"""

    amount: Decimal = Field(..., gt=0, description="Refund amount")
    reason: str = Field(..., min_length=1, description="Reason for refund")
    external_transaction_id: Optional[str] = Field(
        None, description="External transaction ID from PSP"
    )

    class Config:
        json_schema_extra = {
            "example": {
                "amount": 500.00,
                "reason": "Service not provided as agreed",
            }
        }


class RefundResponse(BaseModel):
    """Schema for refund response"""

    payment_id: str
    refund_amount: Decimal
    refund_status: PaymentStatusEnum
    transaction_id: str

    class Config:
        from_attributes = True
