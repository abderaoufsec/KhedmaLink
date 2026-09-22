"""
Review API endpoints
Handles CRUD operations for reviews and provider reputation
"""

from typing import List, Optional
from fastapi import APIRouter, Depends, HTTPException, status, Query
from sqlalchemy import select, and_, func
from sqlalchemy.ext.asyncio import AsyncSession
from datetime import datetime

from app.core.database import get_db
from app.core.models.review import Review
from app.core.models.booking import Booking
from app.core.models.user import User
from app.core.schemas.review import (
    ReviewCreate,
    ReviewUpdate,
    ReviewResponse,
    ProviderReputation,
)
from app.core.security.dependencies import get_current_user

# Create router for review endpoints
router = APIRouter()


# =============================================================================
# REPUTATION HELPER FUNCTIONS
# =============================================================================


async def calculate_provider_reputation(
    db: AsyncSession,
    provider_id: str,
) -> ProviderReputation:
    """
    Calculate provider reputation metrics from reviews

    Args:
        db: Database session
        provider_id: Provider user ID

    Returns:
        Provider reputation metrics
    """
    # Get all reviews for the provider
    query = select(Review).where(Review.provider_id == provider_id)
    result = await db.execute(query)
    reviews = result.scalars().all()

    if not reviews:
        return ProviderReputation(
            average_rating=0.0,
            total_reviews=0,
            rating_distribution={},
            category_averages={},
            badges=[],
        )

    # Calculate average rating
    total_rating = sum(review.rating for review in reviews)
    average_rating = total_rating / len(reviews)

    # Calculate rating distribution
    rating_distribution = {str(i): 0 for i in range(1, 6)}
    for review in reviews:
        rating_distribution[str(review.rating)] += 1

    # Calculate category averages
    category_averages = {}
    categories = ["professionalism", "quality", "timeliness", "communication", "value"]
    for category in categories:
        values = [
            getattr(review, category)
            for review in reviews
            if getattr(review, category) is not None
        ]
        if values:
            category_averages[category] = sum(values) / len(values)

    # Calculate badges
    badges = []
    if average_rating >= 4.5:
        badges.append("Top Rated")
    if average_rating >= 4.0 and len(reviews) >= 10:
        badges.append("Highly Rated")
    if len(reviews) >= 5:
        badges.append("Established Provider")
    if len(reviews) >= 20:
        badges.append("Popular Provider")
    if category_averages.get("timeliness", 0) >= 4.5:
        badges.append("Punctual")
    if category_averages.get("communication", 0) >= 4.5:
        badges.append("Great Communicator")

    return ProviderReputation(
        average_rating=round(average_rating, 2),
        total_reviews=len(reviews),
        rating_distribution=rating_distribution,
        category_averages=category_averages,
        badges=badges,
    )


# =============================================================================
# REVIEW ENDPOINTS
# =============================================================================


@router.get(
    "/me/bookings/{booking_id}/review",
    response_model=Optional[ReviewResponse],
    status_code=status.HTTP_200_OK,
)
async def get_booking_review(
    booking_id: str,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    """
    Get review for a specific booking

    - **booking_id**: Booking ID

    Returns the review if it exists, null otherwise
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

    # Get review
    query = select(Review).where(Review.booking_id == booking_id)
    result = await db.execute(query)
    review = result.scalar_one_or_none()

    return review


@router.post(
    "/me/bookings/{booking_id}/review",
    response_model=ReviewResponse,
    status_code=status.HTTP_201_CREATED,
)
async def create_review(
    booking_id: str,
    review_data: ReviewCreate,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    """
    Create a review for a completed booking

    - **booking_id**: Booking ID
    - **review_data**: Review creation data

    Only the customer can create a review, and only for completed bookings
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

    # Check ownership - only customer can create review
    if str(booking.customer_id) != str(current_user.id):
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Only the customer can create a review",
        )

    # Validate booking is completed
    if booking.status != "completed":
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Can only review completed bookings",
        )

    # Check if review already exists
    existing_query = select(Review).where(Review.booking_id == booking_id)
    existing_result = await db.execute(existing_query)
    existing_review = existing_result.scalar_one_or_none()

    if existing_review:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Review already exists for this booking",
        )

    # Create review
    review = Review(
        booking_id=booking_id,
        customer_id=str(current_user.id),
        provider_id=booking.provider_id,
        rating=review_data.rating,
        title=review_data.title,
        comment=review_data.comment,
        professionalism=review_data.professionalism,
        quality=review_data.quality,
        timeliness=review_data.timeliness,
        communication=review_data.communication,
        value=review_data.value,
    )
    db.add(review)
    await db.commit()
    await db.refresh(review)

    return review


@router.get(
    "/providers/{provider_id}/reviews",
    response_model=List[ReviewResponse],
    status_code=status.HTTP_200_OK,
)
async def list_provider_reviews(
    provider_id: str,
    skip: int = 0,
    limit: int = 100,
    db: AsyncSession = Depends(get_db),
):
    """
    List reviews for a provider

    - **provider_id**: Provider user ID
    - **skip**: Number of reviews to skip (pagination)
    - **limit**: Maximum number of reviews to return

    Returns all reviews for the specified provider
    """
    # Get reviews
    query = (
        select(Review)
        .where(Review.provider_id == provider_id)
        .order_by(Review.created_at.desc())
        .offset(skip)
        .limit(limit)
    )
    result = await db.execute(query)
    reviews = result.scalars().all()

    return reviews


@router.get(
    "/providers/{provider_id}/reputation",
    response_model=ProviderReputation,
    status_code=status.HTTP_200_OK,
)
async def get_provider_reputation(
    provider_id: str,
    db: AsyncSession = Depends(get_db),
):
    """
    Get provider reputation metrics

    - **provider_id**: Provider user ID

    Returns calculated reputation metrics including ratings, badges, and category averages
    """
    reputation = await calculate_provider_reputation(db, provider_id)
    return reputation


@router.patch(
    "/me/reviews/{review_id}",
    response_model=ReviewResponse,
    status_code=status.HTTP_200_OK,
)
async def update_review(
    review_id: str,
    review_data: ReviewUpdate,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    """
    Update a review

    - **review_id**: Review ID
    - **review_data**: Review update data

    Customer can update review content, provider can add response
    """
    # Get review
    query = select(Review).where(Review.id == review_id)
    result = await db.execute(query)
    review = result.scalar_one_or_none()

    if not review:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Review not found",
        )

    # Check ownership
    is_customer = str(review.customer_id) == str(current_user.id)
    is_provider = str(review.provider_id) == str(current_user.id)

    if not is_customer and not is_provider:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="You do not have permission to update this review",
        )

    # Update review
    update_data = review_data.model_dump(exclude_unset=True)

    # Customer can update title and comment
    if is_customer:
        if "title" in update_data:
            review.title = update_data["title"]
        if "comment" in update_data:
            review.comment = update_data["comment"]

    # Provider can add response
    if is_provider and "provider_response" in update_data:
        review.provider_response = update_data["provider_response"]
        review.provider_response_at = datetime.utcnow()

    await db.commit()
    await db.refresh(review)

    return review
