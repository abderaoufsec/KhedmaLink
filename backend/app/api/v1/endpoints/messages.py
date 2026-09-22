"""
Messaging API endpoints
Handles CRUD operations for booking-scoped messaging and notifications
"""

from typing import List, Optional
from fastapi import APIRouter, Depends, HTTPException, status, Query
from sqlalchemy import select, and_, or_
from sqlalchemy.ext.asyncio import AsyncSession
from datetime import datetime

from app.core.database import get_db
from app.core.models.message import Message, MessageAttachment, Notification
from app.core.models.booking import Booking
from app.core.models.user import User
from app.core.schemas.message import (
    MessageCreate,
    MessageUpdate,
    MessageResponse,
    MessageAttachmentCreate,
    MessageAttachmentResponse,
    NotificationCreate,
    NotificationResponse,
    NotificationUpdate,
    MessageListResponse,
    NotificationListResponse,
)
from app.core.security.dependencies import get_current_user

# Create router for messaging endpoints
router = APIRouter()


# =============================================================================
# MESSAGE ENDPOINTS
# =============================================================================


@router.get(
    "/me/bookings/{booking_id}/messages",
    response_model=List[MessageResponse],
    status_code=status.HTTP_200_OK,
)
async def list_booking_messages(
    booking_id: str,
    current_user: User = Depends(get_current_user),
    skip: int = 0,
    limit: int = 100,
    db: AsyncSession = Depends(get_db),
):
    """
    List messages for a booking

    - **booking_id**: Booking ID
    - **skip**: Number of messages to skip (pagination)
    - **limit**: Maximum number of messages to return

    Returns all messages for the booking if user is customer or provider
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

    # Get messages
    query = (
        select(Message)
        .where(Message.booking_id == booking_id)
        .order_by(Message.created_at.asc())
        .offset(skip)
        .limit(limit)
    )
    result = await db.execute(query)
    messages = result.scalars().all()

    return messages


@router.post(
    "/me/bookings/{booking_id}/messages",
    response_model=MessageResponse,
    status_code=status.HTTP_201_CREATED,
)
async def create_message(
    booking_id: str,
    message_data: MessageCreate,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    """
    Create a new message for a booking

    - **booking_id**: Booking ID
    - **message_data**: Message creation data

    Creates a new message for the authenticated user
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

    # Create message
    message = Message(
        booking_id=booking_id,
        sender_id=str(current_user.id),
        content=message_data.content,
        message_type=message_data.message_type,
    )
    db.add(message)
    await db.commit()
    await db.refresh(message)

    # Send notification to the other party
    recipient_id = (
        booking.provider_id
        if str(booking.customer_id) == str(current_user.id)
        else booking.customer_id
    )
    await _create_notification(
        db=db,
        user_id=recipient_id,
        notification_type="message_received",
        title_ar="رسالة جديدة",
        title_fr="Nouveau message",
        body_ar=f"تم استلام رسالة جديدة للحجز",
        body_fr="Un nouveau message a été envoyé pour la réservation",
        entity_type="booking",
        entity_id=booking_id,
    )

    return message


@router.patch(
    "/me/messages/{message_id}",
    response_model=MessageResponse,
    status_code=status.HTTP_200_OK,
)
async def update_message(
    message_id: str,
    message_data: MessageUpdate,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    """
    Update a message (mark as read)

    - **message_id**: Message ID
    - **message_data**: Message update data

    Updates the message read status
    """
    # Get message
    query = select(Message).where(Message.id == message_id)
    result = await db.execute(query)
    message = result.scalar_one_or_none()

    if not message:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Message not found",
        )

    # Get booking to check ownership
    booking_query = select(Booking).where(Booking.id == message.booking_id)
    booking_result = await db.execute(booking_query)
    booking = booking_result.scalar_one_or_none()

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
            detail="You do not have permission to access this message",
        )

    # Update message
    if message_data.is_read and not message.is_read:
        message.is_read = message_data.is_read
        message.read_at = datetime.utcnow()

    await db.commit()
    await db.refresh(message)

    return message


# =============================================================================
# NOTIFICATION ENDPOINTS
# =============================================================================


@router.get(
    "/me/notifications",
    response_model=List[NotificationResponse],
    status_code=status.HTTP_200_OK,
)
async def list_my_notifications(
    current_user: User = Depends(get_current_user),
    skip: int = 0,
    limit: int = 100,
    unread_only: bool = Query(False, description="Filter by unread status"),
    db: AsyncSession = Depends(get_db),
):
    """
    List current user's notifications

    - **skip**: Number of notifications to skip (pagination)
    - **limit**: Maximum number of notifications to return
    - **unread_only**: Filter to show only unread notifications

    Returns all notifications for the authenticated user
    """
    # Build query
    query = select(Notification).where(Notification.user_id == str(current_user.id))

    # Apply unread filter if requested
    if unread_only:
        query = query.where(Notification.is_read == False)

    # Apply sorting and pagination
    query = query.order_by(Notification.created_at.desc()).offset(skip).limit(limit)

    # Execute query
    result = await db.execute(query)
    notifications = result.scalars().all()

    return notifications


@router.patch(
    "/me/notifications/{notification_id}",
    response_model=NotificationResponse,
    status_code=status.HTTP_200_OK,
)
async def update_notification(
    notification_id: str,
    notification_data: NotificationUpdate,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    """
    Update a notification (mark as read)

    - **notification_id**: Notification ID
    - **notification_data**: Notification update data

    Updates the notification read status
    """
    # Get notification
    query = select(Notification).where(Notification.id == notification_id)
    result = await db.execute(query)
    notification = result.scalar_one_or_none()

    if not notification:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Notification not found",
        )

    # Check ownership
    if str(notification.user_id) != str(current_user.id):
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="You do not have permission to access this notification",
        )

    # Update notification
    if notification_data.is_read and not notification.is_read:
        notification.is_read = notification_data.is_read
        notification.read_at = datetime.utcnow()

    await db.commit()
    await db.refresh(notification)

    return notification


# =============================================================================
# NOTIFICATION HELPER FUNCTIONS
# =============================================================================


async def _create_notification(
    db: AsyncSession,
    user_id: str,
    notification_type: str,
    title_ar: str,
    title_fr: str,
    body_ar: str,
    body_fr: str,
    entity_type: Optional[str] = None,
    entity_id: Optional[str] = None,
) -> Notification:
    """
    Create a notification for a user

    Args:
        db: Database session
        user_id: Recipient user ID
        notification_type: Notification type
        title_ar: Title in Arabic
        title_fr: Title in French
        body_ar: Body in Arabic
        body_fr: Body in French
        entity_type: Related entity type
        entity_id: Related entity ID

    Returns:
        Created notification
    """
    notification = Notification(
        user_id=user_id,
        notification_type=notification_type,
        title_ar=title_ar,
        title_fr=title_fr,
        body_ar=body_ar,
        body_fr=body_fr,
        entity_type=entity_type,
        entity_id=entity_id,
    )
    db.add(notification)
    await db.commit()
    await db.refresh(notification)
    return notification
