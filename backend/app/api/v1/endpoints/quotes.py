"""
Quote API endpoints
Handles CRUD operations for provider quotes and quote acceptance
"""

from typing import List, Optional
from fastapi import APIRouter, Depends, HTTPException, status, Query
from sqlalchemy import select, and_, or_
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.database import get_db
from app.core.models.quote import Quote, RequestMatch
from app.core.models.request import ServiceRequest
from app.core.models.user import User
from app.core.models.booking import Booking
from app.core.schemas.quote import (
    QuoteCreate,
    QuoteUpdate,
    QuoteResponse,
    QuotePublic,
    RequestMatchCreate,
    RequestMatchResponse,
)
from app.api.v1.endpoints.messages import _create_notification
from app.core.security.dependencies import get_current_user, require_provider

# Create router for quote endpoints
router = APIRouter()


# =============================================================================
# PROVIDER QUOTE MANAGEMENT ENDPOINTS
# =============================================================================


@router.get(
    "/me/quotes", response_model=List[QuoteResponse], status_code=status.HTTP_200_OK
)
async def list_my_quotes(
    current_user: User = Depends(get_current_user),
    skip: int = 0,
    limit: int = 100,
    status_filter: Optional[str] = Query(None, description="Filter by status"),
    db: AsyncSession = Depends(get_db),
):
    """
    List current provider's quotes

    - **skip**: Number of quotes to skip (pagination)
    - **limit**: Maximum number of quotes to return
    - **status_filter**: Filter by status (draft, submitted, withdrawn, accepted, rejected, expired)

    Returns all quotes for the authenticated provider
    """
    # Build query
    query = select(Quote).where(Quote.provider_id == str(current_user.id))

    # Apply status filter if provided
    if status_filter:
        query = query.where(Quote.status == status_filter)

    # Apply sorting and pagination
    query = query.order_by(Quote.created_at.desc()).offset(skip).limit(limit)

    # Execute query
    result = await db.execute(query)
    quotes = result.scalars().all()

    return quotes


@router.post(
    "/me/quotes", response_model=QuoteResponse, status_code=status.HTTP_201_CREATED
)
async def create_quote(
    quote_data: QuoteCreate,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    """
    Create a new quote for a service request

    - **quote_data**: Quote creation data

    Creates a new quote for the authenticated provider
    Suspended providers cannot create quotes
    """
    # Check if provider is suspended
    if current_user.status != "active":
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Suspended providers cannot create quotes",
        )

    # Check if request exists and is open
    request_query = select(ServiceRequest).where(
        and_(
            ServiceRequest.id == quote_data.request_id, ServiceRequest.status == "open"
        )
    )
    request_result = await db.execute(request_query)
    request = request_result.scalar_one_or_none()

    if not request:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Service request not found or not open",
        )

    # Check if provider already has a quote for this request
    existing_quote_query = select(Quote).where(
        and_(
            Quote.request_id == quote_data.request_id,
            Quote.provider_id == str(current_user.id),
            Quote.status.in_(["draft", "submitted"]),
        )
    )
    existing_quote_result = await db.execute(existing_quote_query)
    existing_quote = existing_quote_result.scalar_one_or_none()

    if existing_quote:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="You already have an active quote for this request",
        )

    # Create new quote
    new_quote = Quote(provider_id=str(current_user.id), **quote_data.model_dump())

    # Add to database
    db.add(new_quote)
    await db.commit()
    await db.refresh(new_quote)

    return new_quote


@router.get(
    "/me/quotes/{quote_id}",
    response_model=QuoteResponse,
    status_code=status.HTTP_200_OK,
)
async def get_my_quote(
    quote_id: str,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    """
    Get a specific quote by ID for the current provider

    - **quote_id**: UUID of the quote

    Returns quote details or 404 if not found
    """
    # Query for quote
    query = select(Quote).where(
        and_(Quote.id == quote_id, Quote.provider_id == str(current_user.id))
    )
    result = await db.execute(query)
    quote = result.scalar_one_or_none()

    # Check if quote exists and belongs to provider
    if not quote:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND, detail="Quote not found"
        )

    return quote


@router.put(
    "/me/quotes/{quote_id}",
    response_model=QuoteResponse,
    status_code=status.HTTP_200_OK,
)
async def update_quote(
    quote_id: str,
    quote_data: QuoteUpdate,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    """
    Update a quote for the current provider

    - **quote_id**: UUID of the quote to update
    - **quote_data**: Quote update data

    Updates the quote for the authenticated provider
    """
    # Query for existing quote
    query = select(Quote).where(
        and_(Quote.id == quote_id, Quote.provider_id == str(current_user.id))
    )
    result = await db.execute(query)
    quote = result.scalar_one_or_none()

    # Check if quote exists and belongs to provider
    if not quote:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND, detail="Quote not found"
        )

    # Validate status transition
    if quote_data.status:
        # Only allow certain status transitions
        if quote.status == "accepted" and quote_data.status != "accepted":
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Cannot change status of an accepted quote",
            )
        if quote.status == "rejected" and quote_data.status != "rejected":
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Cannot change status of a rejected quote",
            )
        if quote.status == "withdrawn" and quote_data.status != "withdrawn":
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Cannot change status of a withdrawn quote",
            )

    # Update quote fields
    update_data = quote_data.model_dump(exclude_unset=True)
    for field, value in update_data.items():
        setattr(quote, field, value)

    # Set timestamps based on status
    if quote_data.status == "submitted" and quote.submitted_at is None:
        from datetime import datetime

        quote.submitted_at = datetime.utcnow()
    if quote_data.status == "rejected" and quote.rejected_at is None:
        from datetime import datetime

        quote.rejected_at = datetime.utcnow()
    if quote_data.status == "accepted" and quote.accepted_at is None:
        from datetime import datetime

        quote.accepted_at = datetime.utcnow()

    # Commit changes
    await db.commit()
    await db.refresh(quote)

    return quote


@router.delete("/me/quotes/{quote_id}", status_code=status.HTTP_204_NO_CONTENT)
async def delete_quote(
    quote_id: str,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    """
    Delete a quote for the current provider

    - **quote_id**: UUID of the quote to delete

    Deletes the quote for the authenticated provider
    """
    # Query for existing quote
    query = select(Quote).where(
        and_(Quote.id == quote_id, Quote.provider_id == str(current_user.id))
    )
    result = await db.execute(query)
    quote = result.scalar_one_or_none()

    # Check if quote exists and belongs to provider
    if not quote:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND, detail="Quote not found"
        )

    # Only allow deletion of draft quotes
    if quote.status != "draft":
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Cannot delete a quote that is not in draft status",
        )

    # Delete quote
    await db.delete(quote)
    await db.commit()

    return None


# =============================================================================
# CUSTOMER QUOTE MANAGEMENT ENDPOINTS
# =============================================================================


@router.get(
    "/me/requests/{request_id}/quotes",
    response_model=List[QuotePublic],
    status_code=status.HTTP_200_OK,
)
async def list_request_quotes(
    request_id: str,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    """
    List quotes for a service request (customer's request)

    - **request_id**: UUID of the service request

    Returns all submitted quotes for the service request
    """
    # Verify request ownership
    request_query = select(ServiceRequest).where(
        and_(
            ServiceRequest.id == request_id,
            ServiceRequest.customer_id == str(current_user.id),
        )
    )
    request_result = await db.execute(request_query)
    request = request_result.scalar_one_or_none()

    if not request:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND, detail="Service request not found"
        )

    # Query for submitted quotes
    query = select(Quote).where(
        and_(Quote.request_id == request_id, Quote.status == "submitted")
    )
    result = await db.execute(query)
    quotes = result.scalars().all()

    return quotes


@router.post(
    "/me/requests/{request_id}/quotes/{quote_id}/accept",
    response_model=QuoteResponse,
    status_code=status.HTTP_200_OK,
)
async def accept_quote(
    request_id: str,
    quote_id: str,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    """
    Accept a quote for a service request

    - **request_id**: UUID of the service request
    - **quote_id**: UUID of the quote to accept

    Accepts the quote and closes competing quotes
    """
    # Verify request ownership
    request_query = select(ServiceRequest).where(
        and_(
            ServiceRequest.id == request_id,
            ServiceRequest.customer_id == str(current_user.id),
        )
    )
    request_result = await db.execute(request_query)
    request = request_result.scalar_one_or_none()

    if not request:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND, detail="Service request not found"
        )

    # Check if request is open
    if request.status != "open":
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Cannot accept quote for a request that is not open",
        )

    # Query for quote
    quote_query = select(Quote).where(
        and_(
            Quote.id == quote_id,
            Quote.request_id == request_id,
            Quote.status == "submitted",
        )
    )
    quote_result = await db.execute(quote_query)
    quote = quote_result.scalar_one_or_none()

    if not quote:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Quote not found or not in submitted status",
        )

    # Accept the quote
    from datetime import datetime

    quote.status = "accepted"
    quote.accepted_at = datetime.utcnow()

    # Close competing quotes
    competing_quotes_query = select(Quote).where(
        and_(
            Quote.request_id == request_id,
            Quote.id != quote_id,
            Quote.status == "submitted",
        )
    )
    competing_quotes_result = await db.execute(competing_quotes_query)
    competing_quotes = competing_quotes_result.scalars().all()

    for competing_quote in competing_quotes:
        competing_quote.status = "rejected"
        competing_quote.rejected_at = datetime.utcnow()
        competing_quote.rejection_reason = "Another quote was accepted"

    # Update request status
    request.status = "closed"
    request.closed_at = datetime.utcnow()

    # Create booking from accepted quote
    booking = Booking(
        request_id=request_id,
        quote_id=quote_id,
        customer_id=str(current_user.id),
        provider_id=quote.provider_id,
        scheduled_date=quote.available_date,
        scheduled_time_start=quote.available_time_start,
        scheduled_time_end=quote.available_time_end,
        estimated_duration=quote.estimated_duration,
        estimated_duration_unit=quote.estimated_duration_unit,
        agreed_price=quote.estimated_price,
        currency=quote.currency,
        address=request.address,
        city=request.city,
        wilaya=request.wilaya,
        latitude=request.latitude,
        longitude=request.longitude,
        status="accepted",
    )
    db.add(booking)

    # Send notification to provider about quote acceptance
    await _create_notification(
        db=db,
        user_id=quote.provider_id,
        notification_type="quote_accepted",
        title_ar="تم قبول عرضك",
        title_fr="Votre devis a été accepté",
        body_ar=f"تم قبول عرضك على طلب الخدمة",
        body_fr="Votre devis a été accepté pour la demande de service",
        entity_type="quote",
        entity_id=quote_id,
    )

    # Commit changes
    await db.commit()
    await db.refresh(quote)

    return quote


# =============================================================================
# REQUEST MATCH ENDPOINTS
# =============================================================================


@router.get(
    "/me/eligible-requests",
    response_model=List[RequestMatchResponse],
    status_code=status.HTTP_200_OK,
)
async def list_eligible_requests(
    current_user: User = Depends(get_current_user),
    skip: int = 0,
    limit: int = 100,
    db: AsyncSession = Depends(get_db),
):
    """
    List eligible requests for the current provider

    - **skip**: Number of matches to skip (pagination)
    - **limit**: Maximum number of matches to return

    Returns all eligible service requests for the provider
    """
    # Build query for eligible matches
    query = select(RequestMatch).where(
        and_(
            RequestMatch.provider_id == str(current_user.id),
            RequestMatch.status == "eligible",
        )
    )

    # Apply sorting and pagination
    query = query.order_by(RequestMatch.match_score.desc()).offset(skip).limit(limit)

    # Execute query
    result = await db.execute(query)
    matches = result.scalars().all()

    return matches
