"""
Booking API endpoints
Handles CRUD operations for bookings and booking state transitions
"""

from typing import List, Optional
from fastapi import APIRouter, Depends, HTTPException, status, Query
from sqlalchemy import select, and_, or_
from sqlalchemy.ext.asyncio import AsyncSession
from datetime import datetime

from app.core.database import get_db
from app.core.models.booking import Booking, BookingEvent
from app.core.models.quote import Quote
from app.core.models.request import ServiceRequest
from app.core.models.user import User
from app.core.schemas.booking import (
    BookingCreate,
    BookingUpdate,
    BookingResponse,
    BookingCancel,
    BookingComplete,
    BookingEventResponse,
    BookingListResponse,
)
from app.api.v1.endpoints.messages import _create_notification
from app.core.security.dependencies import get_current_user
from app.core.security.ownership import check_ownership, require_ownership

# Create router for booking endpoints
router = APIRouter()


# =============================================================================
# BOOKING STATE MACHINE VALIDATION
# =============================================================================


VALID_TRANSITIONS = {
    "draft": ["pending", "cancelled"],
    "pending": ["quoted", "cancelled"],
    "quoted": ["accepted", "cancelled"],
    "accepted": ["scheduled", "cancelled"],
    "scheduled": ["in_progress", "cancelled"],
    "in_progress": ["completed", "disputed"],
    "completed": [],  # Terminal state
    "cancelled": [],  # Terminal state
    "expired": [],  # Terminal state
    "rejected": [],  # Terminal state
    "disputed": [],  # Terminal state
}


def validate_state_transition(current_status: str, new_status: str) -> bool:
    """
    Validate that a state transition is allowed

    Args:
        current_status: Current booking status
        new_status: Target booking status

    Returns:
        True if transition is valid, False otherwise
    """
    if current_status == new_status:
        return True  # No change is valid
    return new_status in VALID_TRANSITIONS.get(current_status, [])


async def create_booking_event(
    db: AsyncSession,
    booking_id: str,
    event_type: str,
    triggered_by: Optional[str],
    old_status: Optional[str],
    new_status: Optional[str],
    notes: Optional[str] = None,
    event_metadata: Optional[str] = None,
) -> BookingEvent:
    """
    Create a booking event for audit trail

    Args:
        db: Database session
        booking_id: Booking ID
        event_type: Event type
        triggered_by: User ID who triggered the event
        old_status: Previous status
        new_status: New status
        notes: Event notes
        event_metadata: Additional metadata

    Returns:
        Created booking event
    """
    event = BookingEvent(
        booking_id=booking_id,
        triggered_by=triggered_by,
        event_type=event_type,
        old_status=old_status,
        new_status=new_status,
        notes=notes,
        event_metadata=event_metadata,
    )
    db.add(event)
    await db.commit()
    await db.refresh(event)
    return event


# =============================================================================
# BOOKING MANAGEMENT ENDPOINTS
# =============================================================================


@router.get(
    "/me/bookings",
    response_model=List[BookingResponse],
    status_code=status.HTTP_200_OK,
)
async def list_my_bookings(
    current_user: User = Depends(get_current_user),
    skip: int = 0,
    limit: int = 100,
    status_filter: Optional[str] = Query(None, description="Filter by status"),
    db: AsyncSession = Depends(get_db),
):
    """
    List current user's bookings (both as customer and provider)

    - **skip**: Number of bookings to skip (pagination)
    - **limit**: Maximum number of bookings to return
    - **status_filter**: Filter by status

    Returns all bookings where the user is either customer or provider
    """
    # Build query - user can be customer or provider
    query = select(Booking).where(
        or_(
            Booking.customer_id == str(current_user.id),
            Booking.provider_id == str(current_user.id),
        )
    )

    # Apply status filter if provided
    if status_filter:
        query = query.where(Booking.status == status_filter)

    # Apply sorting and pagination
    query = query.order_by(Booking.created_at.desc()).offset(skip).limit(limit)

    # Execute query
    result = await db.execute(query)
    bookings = result.scalars().all()

    return bookings


@router.get(
    "/me/bookings/{booking_id}",
    response_model=BookingResponse,
    status_code=status.HTTP_200_OK,
)
async def get_my_booking(
    booking_id: str,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    """
    Get a specific booking for the current user

    - **booking_id**: Booking ID

    Returns booking details if user is customer or provider
    """
    # Get booking
    query = select(Booking).where(Booking.id == booking_id)
    result = await db.execute(query)
    booking = result.scalar_one_or_none()

    if not booking:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Booking not found",
        )

    # Check ownership - user must be customer or provider
    if str(booking.customer_id) != str(current_user.id) and str(
        booking.provider_id
    ) != str(current_user.id):
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="You do not have permission to access this booking",
        )

    return booking


@router.post(
    "/me/bookings/{booking_id}/cancel",
    response_model=BookingResponse,
    status_code=status.HTTP_200_OK,
)
async def cancel_booking(
    booking_id: str,
    cancel_data: BookingCancel,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    """
    Cancel a booking

    - **booking_id**: Booking ID
    - **cancel_data**: Cancellation reason

    Only customer or provider can cancel a booking
    """
    # Get booking
    query = select(Booking).where(Booking.id == booking_id)
    result = await db.execute(query)
    booking = result.scalar_one_or_none()

    if not booking:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Booking not found",
        )

    # Check ownership - user must be customer or provider
    if str(booking.customer_id) != str(current_user.id) and str(
        booking.provider_id
    ) != str(current_user.id):
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="You do not have permission to cancel this booking",
        )

    # Validate state transition
    if not validate_state_transition(booking.status, "cancelled"):
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=f"Cannot cancel booking in status: {booking.status}",
        )

    # Update booking
    old_status = booking.status
    booking.status = "cancelled"
    booking.cancelled_at = datetime.utcnow()
    booking.cancelled_by = str(current_user.id)
    booking.cancellation_reason = cancel_data.cancellation_reason

    # Create event
    await create_booking_event(
        db=db,
        booking_id=booking.id,
        event_type="cancelled",
        triggered_by=str(current_user.id),
        old_status=old_status,
        new_status="cancelled",
        notes=cancel_data.cancellation_reason,
    )

    # Send notification to the other party about cancellation
    recipient_id = (
        booking.provider_id
        if str(booking.customer_id) == str(current_user.id)
        else booking.customer_id
    )
    await _create_notification(
        db=db,
        user_id=recipient_id,
        notification_type="booking_cancelled",
        title_ar="تم إلغاء الحجز",
        title_fr="Réservation annulée",
        body_ar=f"تم إلغاء الحجز",
        body_fr="La réservation a été annulée",
        entity_type="booking",
        entity_id=booking_id,
    )

    await db.commit()
    await db.refresh(booking)

    return booking


@router.post(
    "/me/bookings/{booking_id}/start",
    response_model=BookingResponse,
    status_code=status.HTTP_200_OK,
)
async def start_booking(
    booking_id: str,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    """
    Start a booking (move to in_progress)

    - **booking_id**: Booking ID

    Only provider can start a booking
    Suspended providers cannot start bookings
    """
    # Check if provider is suspended
    if current_user.status != "active":
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Suspended providers cannot start bookings",
        )

    # Get booking
    query = select(Booking).where(Booking.id == booking_id)
    result = await db.execute(query)
    booking = result.scalar_one_or_none()

    if not booking:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Booking not found",
        )

    # Check ownership - only provider can start
    if str(booking.provider_id) != str(current_user.id):
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Only the provider can start this booking",
        )

    # Validate state transition
    if not validate_state_transition(booking.status, "in_progress"):
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=f"Cannot start booking in status: {booking.status}",
        )

    # Update booking
    old_status = booking.status
    booking.status = "in_progress"

    # Create event
    await create_booking_event(
        db=db,
        booking_id=booking.id,
        event_type="started",
        triggered_by=str(current_user.id),
        old_status=old_status,
        new_status="in_progress",
    )

    # Send notification to customer about booking start
    await _create_notification(
        db=db,
        user_id=booking.customer_id,
        notification_type="booking_started",
        title_ar="بدأ العمل على حجزك",
        title_fr="Le travail a commencé sur votre réservation",
        body_ar=f"بدأ مقدم الخدمة العمل على حجزك",
        body_fr="Le prestataire a commencé le travail sur votre réservation",
        entity_type="booking",
        entity_id=booking_id,
    )

    await db.commit()
    await db.refresh(booking)

    return booking


@router.post(
    "/me/bookings/{booking_id}/complete",
    response_model=BookingResponse,
    status_code=status.HTTP_200_OK,
)
async def complete_booking(
    booking_id: str,
    complete_data: BookingComplete,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    """
    Complete a booking

    - **booking_id**: Booking ID
    - **complete_data**: Optional completion notes

    Only provider can complete a booking
    Suspended providers cannot complete bookings
    """
    # Check if provider is suspended
    if current_user.status != "active":
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Suspended providers cannot complete bookings",
        )

    # Get booking
    query = select(Booking).where(Booking.id == booking_id)
    result = await db.execute(query)
    booking = result.scalar_one_or_none()

    if not booking:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Booking not found",
        )

    # Check ownership - only provider can complete
    if str(booking.provider_id) != str(current_user.id):
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Only the provider can complete this booking",
        )

    # Validate state transition
    if not validate_state_transition(booking.status, "completed"):
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=f"Cannot complete booking in status: {booking.status}",
        )

    # Update booking
    old_status = booking.status
    booking.status = "completed"
    booking.completed_at = datetime.utcnow()
    booking.completion_notes = complete_data.completion_notes

    # Create event
    await create_booking_event(
        db=db,
        booking_id=booking.id,
        event_type="completed",
        triggered_by=str(current_user.id),
        old_status=old_status,
        new_status="completed",
        notes=complete_data.completion_notes,
    )

    # Send notification to customer about booking completion
    await _create_notification(
        db=db,
        user_id=booking.customer_id,
        notification_type="booking_completed",
        title_ar="اكتمل حجزك",
        title_fr="Votre réservation est terminée",
        body_ar=f"اكتمل العمل على حجزك بنجاح",
        body_fr="Le travail sur votre réservation est terminé avec succès",
        entity_type="booking",
        entity_id=booking_id,
    )

    await db.commit()
    await db.refresh(booking)

    return booking


@router.get(
    "/me/bookings/{booking_id}/events",
    response_model=List[BookingEventResponse],
    status_code=status.HTTP_200_OK,
)
async def list_booking_events(
    booking_id: str,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    """
    List events for a booking

    - **booking_id**: Booking ID

    Returns all events for the booking if user is customer or provider
    """
    # Get booking
    query = select(Booking).where(Booking.id == booking_id)
    result = await db.execute(query)
    booking = result.scalar_one_or_none()

    if not booking:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Booking not found",
        )

    # Check ownership - user must be customer or provider
    if str(booking.customer_id) != str(current_user.id) and str(
        booking.provider_id
    ) != str(current_user.id):
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="You do not have permission to access this booking",
        )

    # Get events
    query = (
        select(BookingEvent)
        .where(BookingEvent.booking_id == booking_id)
        .order_by(BookingEvent.created_at.asc())
    )
    result = await db.execute(query)
    events = result.scalars().all()

    return events
