# Payment API endpoints for KhedmaLink backend
# Handles payment creation, processing, refunds, and payouts

from typing import List, Optional
from fastapi import APIRouter, Depends, HTTPException, status, Query
from sqlalchemy import select, and_, or_, func
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.orm import selectinload
from datetime import datetime
from decimal import Decimal

from app.core.database import get_db
from app.core.models.payment import (
    Payment,
    Transaction,
    Payout,
    PaymentMethod,
    PaymentStatus,
    TransactionType,
    PayoutStatus,
)
from app.core.models.booking import Booking
from app.core.models.user import User
from app.core.schemas.payment import (
    PaymentCreate,
    PaymentUpdate,
    PaymentResponse,
    PaymentListResponse,
    PaymentMethodEnum,
    PaymentStatusEnum,
    TransactionCreate,
    TransactionResponse,
    TransactionListResponse,
    TransactionTypeEnum,
    PayoutCreate,
    PayoutUpdate,
    PayoutResponse,
    PayoutListResponse,
    PayoutStatusEnum,
    RefundCreate,
    RefundResponse,
)
from app.core.security.dependencies import (
    get_current_user,
    require_customer,
    require_provider,
    require_admin,
)

# Default commission rate (10%)
DEFAULT_COMMISSION_RATE = Decimal("0.10")

router = APIRouter()


# =============================================================================
# COMMISSION CALCULATION HELPER
# =============================================================================


def calculate_commission(
    amount: Decimal, commission_rate: Decimal = DEFAULT_COMMISSION_RATE
) -> tuple:
    """
    Calculate commission amount and provider amount

    Args:
        amount: Total payment amount
        commission_rate: Commission rate (e.g., 0.10 for 10%)

    Returns:
        Tuple of (commission_amount, provider_amount)
    """
    commission_amount = amount * commission_rate
    provider_amount = amount - commission_amount
    return commission_amount, provider_amount


# =============================================================================
# PAYMENT ENDPOINTS
# =============================================================================


@router.post("", response_model=PaymentResponse, status_code=status.HTTP_201_CREATED)
async def create_payment(
    payment_data: PaymentCreate,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    """
    Create a payment for a booking
    Only the booking customer can create a payment
    """
    # Get the booking
    result = await db.execute(
        select(Booking).where(Booking.id == payment_data.booking_id)
    )
    booking = result.scalar_one_or_none()

    if not booking:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND, detail="Booking not found"
        )

    # Check if user is the customer
    if booking.customer_id != current_user.id:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Only the booking customer can create a payment",
        )

    # Check if payment already exists for this booking
    existing_payment = await db.execute(
        select(Payment).where(Payment.booking_id == payment_data.booking_id)
    )
    if existing_payment.scalar_one_or_none():
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Payment already exists for this booking",
        )

    # Calculate commission
    commission_amount, provider_amount = calculate_commission(
        Decimal(str(booking.agreed_price))
    )

    # Create payment
    payment = Payment(
        booking_id=payment_data.booking_id,
        customer_id=current_user.id,
        provider_id=booking.provider_id,
        amount=Decimal(str(booking.agreed_price)),
        currency=booking.currency,
        commission_rate=DEFAULT_COMMISSION_RATE,
        commission_amount=commission_amount,
        provider_amount=provider_amount,
        payment_method=PaymentMethod(payment_data.payment_method.value),
        external_payment_id=payment_data.external_payment_id,
    )

    db.add(payment)
    await db.commit()
    await db.refresh(payment)

    return payment


@router.get("", response_model=PaymentListResponse)
async def list_payments(
    page: int = Query(1, ge=1),
    page_size: int = Query(20, ge=1, le=100),
    status_filter: Optional[PaymentStatusEnum] = Query(None),
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    """
    List payments for the current user
    Customers see their payments, providers see payments for their bookings
    """
    # Build base query
    query = select(Payment).options(
        selectinload(Payment.booking),
        selectinload(Payment.customer),
        selectinload(Payment.provider),
    )

    # Filter by user (customer or provider)
    query = query.where(
        or_(
            Payment.customer_id == current_user.id,
            Payment.provider_id == current_user.id,
        )
    )

    # Apply status filter if provided
    if status_filter:
        query = query.where(Payment.status == PaymentStatus(status_filter.value))

    # Count total
    count_query = select(func.count()).select_from(query.subquery())
    total_result = await db.execute(count_query)
    total = total_result.scalar()

    # Apply pagination
    query = query.offset((page - 1) * page_size).limit(page_size)
    query = query.order_by(Payment.created_at.desc())

    result = await db.execute(query)
    payments = result.scalars().all()

    return PaymentListResponse(
        items=[PaymentResponse.model_validate(p) for p in payments],
        total=total,
        page=page,
        page_size=page_size,
    )


@router.get("/{payment_id}", response_model=PaymentResponse)
async def get_payment(
    payment_id: str,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    """
    Get a specific payment
    Only the customer or provider of the payment can access it
    """
    result = await db.execute(
        select(Payment)
        .options(
            selectinload(Payment.booking),
            selectinload(Payment.customer),
            selectinload(Payment.provider),
        )
        .where(Payment.id == payment_id)
    )
    payment = result.scalar_one_or_none()

    if not payment:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND, detail="Payment not found"
        )

    # Check if user is the customer or provider
    if (
        payment.customer_id != current_user.id
        and payment.provider_id != current_user.id
    ):
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Only the customer or provider can access this payment",
        )

    return payment


@router.put("/{payment_id}", response_model=PaymentResponse)
async def update_payment(
    payment_id: str,
    payment_data: PaymentUpdate,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(require_admin),
):
    """
    Update a payment (status changes)
    Admin only - for processing payments or updating status
    """
    result = await db.execute(select(Payment).where(Payment.id == payment_id))
    payment = result.scalar_one_or_none()

    if not payment:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND, detail="Payment not found"
        )

    # Update fields
    if payment_data.status:
        payment.status = PaymentStatus(payment_data.status.value)

        # Set completed_at if status is completed
        if payment.status == PaymentStatus.COMPLETED and not payment.completed_at:
            payment.completed_at = datetime.utcnow()

    if payment_data.external_payment_id:
        payment.external_payment_id = payment_data.external_payment_id

    await db.commit()
    await db.refresh(payment)

    return payment


# =============================================================================
# TRANSACTION ENDPOINTS
# =============================================================================


@router.post(
    "/{payment_id}/transactions",
    response_model=TransactionResponse,
    status_code=status.HTTP_201_CREATED,
)
async def create_transaction(
    payment_id: str,
    transaction_data: TransactionCreate,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(require_admin),
):
    """
    Create a transaction for a payment
    Admin only - for recording captures, refunds, etc.
    """
    result = await db.execute(select(Payment).where(Payment.id == payment_id))
    payment = result.scalar_one_or_none()

    if not payment:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND, detail="Payment not found"
        )

    # Create transaction
    transaction = Transaction(
        payment_id=payment_id,
        transaction_type=TransactionType(transaction_data.transaction_type.value),
        amount=transaction_data.amount,
        currency=transaction_data.currency,
        external_transaction_id=transaction_data.external_transaction_id,
        transaction_metadata=transaction_data.transaction_metadata,
    )

    db.add(transaction)
    await db.commit()
    await db.refresh(transaction)

    return transaction


@router.get("/{payment_id}/transactions", response_model=TransactionListResponse)
async def list_transactions(
    payment_id: str,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    """
    List transactions for a payment
    Only the customer or provider of the payment can access it
    """
    # Check payment access
    result = await db.execute(select(Payment).where(Payment.id == payment_id))
    payment = result.scalar_one_or_none()

    if not payment:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND, detail="Payment not found"
        )

    if (
        payment.customer_id != current_user.id
        and payment.provider_id != current_user.id
    ):
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Only the customer or provider can access this payment",
        )

    # Get transactions
    result = await db.execute(
        select(Transaction)
        .where(Transaction.payment_id == payment_id)
        .order_by(Transaction.created_at.desc())
    )
    transactions = result.scalars().all()

    return TransactionListResponse(
        items=[TransactionResponse.model_validate(t) for t in transactions]
    )


# =============================================================================
# PAYOUT ENDPOINTS
# =============================================================================


@router.post(
    "/{payment_id}/payouts",
    response_model=PayoutResponse,
    status_code=status.HTTP_201_CREATED,
)
async def create_payout(
    payment_id: str,
    payout_data: PayoutCreate,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(require_admin),
):
    """
    Create a payout for a payment
    Admin only - for processing provider payouts
    """
    result = await db.execute(select(Payment).where(Payment.id == payment_id))
    payment = result.scalar_one_or_none()

    if not payment:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND, detail="Payment not found"
        )

    # Check if payment is completed
    if payment.status != PaymentStatus.COMPLETED:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Payment must be completed before creating a payout",
        )

    # Check if payout already exists
    existing_payout = await db.execute(
        select(Payout).where(Payout.payment_id == payment_id)
    )
    if existing_payout.scalar_one_or_none():
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Payout already exists for this payment",
        )

    # Create payout
    payout = Payout(
        payment_id=payment_id,
        provider_id=payment.provider_id,
        amount=payment.provider_amount,
        currency=payment.currency,
        payout_method=payout_data.payout_method,
        external_payout_id=payout_data.external_payout_id,
        notes=payout_data.notes,
    )

    db.add(payout)
    await db.commit()
    await db.refresh(payout)

    return payout


@router.get("/{payment_id}/payouts", response_model=PayoutListResponse)
async def list_payouts(
    payment_id: str,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    """
    List payouts for a payment
    Only the customer or provider of the payment can access it
    """
    # Check payment access
    result = await db.execute(select(Payment).where(Payment.id == payment_id))
    payment = result.scalar_one_or_none()

    if not payment:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND, detail="Payment not found"
        )

    if (
        payment.customer_id != current_user.id
        and payment.provider_id != current_user.id
    ):
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Only the customer or provider can access this payment",
        )

    # Get payouts
    result = await db.execute(
        select(Payout)
        .where(Payout.payment_id == payment_id)
        .order_by(Payout.created_at.desc())
    )
    payouts = result.scalars().all()

    return PayoutListResponse(items=[PayoutResponse.model_validate(p) for p in payouts])


@router.put("/payouts/{payout_id}", response_model=PayoutResponse)
async def update_payout(
    payout_id: str,
    payout_data: PayoutUpdate,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(require_admin),
):
    """
    Update a payout (status changes)
    Admin only - for processing payouts
    """
    result = await db.execute(select(Payout).where(Payout.id == payout_id))
    payout = result.scalar_one_or_none()

    if not payout:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND, detail="Payout not found"
        )

    # Update fields
    if payout_data.status:
        payout.status = PayoutStatus(payout_data.status.value)

        # Set completed_at if status is completed
        if payout.status == PayoutStatus.COMPLETED and not payout.completed_at:
            payout.completed_at = datetime.utcnow()

    if payout_data.external_payout_id:
        payout.external_payout_id = payout_data.external_payout_id

    if payout_data.notes:
        payout.notes = payout_data.notes

    await db.commit()
    await db.refresh(payout)

    return payout


# =============================================================================
# REFUND ENDPOINTS
# =============================================================================


@router.post("/{payment_id}/refund", response_model=RefundResponse)
async def refund_payment(
    payment_id: str,
    refund_data: RefundCreate,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(require_admin),
):
    """
    Refund a payment
    Admin only - for processing refunds
    """
    result = await db.execute(select(Payment).where(Payment.id == payment_id))
    payment = result.scalar_one_or_none()

    if not payment:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND, detail="Payment not found"
        )

    # Check if payment is completed
    if payment.status != PaymentStatus.COMPLETED:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Only completed payments can be refunded",
        )

    # Check refund amount
    if refund_data.amount > payment.amount:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Refund amount cannot exceed payment amount",
        )

    # Create refund transaction
    transaction = Transaction(
        payment_id=payment_id,
        transaction_type=TransactionType.REFUND,
        amount=refund_data.amount,
        currency=payment.currency,
        transaction_metadata=f"Reason: {refund_data.reason}",
    )

    db.add(transaction)

    # Update payment status
    if refund_data.amount == payment.amount:
        payment.status = PaymentStatus.REFUNDED
    else:
        payment.status = PaymentStatus.PARTIALLY_REFUNDED

    await db.commit()
    await db.refresh(payment)
    await db.refresh(transaction)

    return RefundResponse(
        payment_id=payment_id,
        refund_amount=refund_data.amount,
        refund_status=PaymentStatusEnum(payment.status.value),
        transaction_id=str(transaction.id),
    )
