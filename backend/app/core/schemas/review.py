"""
Pydantic schemas for review operations
Contains request and response models for reviews
"""

from typing import Optional, List
from pydantic import BaseModel, Field, field_validator, ConfigDict
from datetime import datetime


# =============================================================================
# REVIEW SCHEMAS
# =============================================================================


class ReviewBase(BaseModel):
    """
    Base schema for review operations
    Contains common fields for review requests and responses
    """

    rating: int = Field(..., ge=1, le=5, description="Overall rating (1-5 stars)")
    title: Optional[str] = Field(None, max_length=255, description="Review title")
    comment: Optional[str] = Field(None, description="Review comment")
    professionalism: Optional[int] = Field(
        None, ge=1, le=5, description="Professionalism rating (1-5)"
    )
    quality: Optional[int] = Field(None, ge=1, le=5, description="Quality rating (1-5)")
    timeliness: Optional[int] = Field(
        None, ge=1, le=5, description="Timeliness rating (1-5)"
    )
    communication: Optional[int] = Field(
        None, ge=1, le=5, description="Communication rating (1-5)"
    )
    value: Optional[int] = Field(None, ge=1, le=5, description="Value rating (1-5)")


class ReviewCreate(ReviewBase):
    """
    Schema for creating a new review
    Used when a customer reviews a completed booking
    """

    booking_id: str = Field(..., description="Booking ID")


class ReviewUpdate(BaseModel):
    """
    Schema for updating a review
    Allows updating review content and adding provider response
    """

    title: Optional[str] = Field(None, max_length=255, description="Review title")
    comment: Optional[str] = Field(None, description="Review comment")
    provider_response: Optional[str] = Field(None, description="Provider response")


class ReviewResponse(ReviewBase):
    """
    Schema for review response
    Includes all review fields with timestamps
    """

    model_config = ConfigDict(from_attributes=True)

    id: str = Field(..., description="Review ID")
    booking_id: str = Field(..., description="Booking ID")
    customer_id: str = Field(..., description="Customer user ID")
    provider_id: str = Field(..., description="Provider user ID")
    provider_response: Optional[str] = Field(None, description="Provider response")
    provider_response_at: Optional[datetime] = Field(
        None, description="Provider response timestamp"
    )
    created_at: datetime = Field(..., description="Creation timestamp")
    updated_at: datetime = Field(..., description="Last update timestamp")


# =============================================================================
# REPUTATION SCHEMAS
# =============================================================================


class ProviderReputation(BaseModel):
    """
    Schema for provider reputation metrics
    Calculated from reviews
    """

    average_rating: float = Field(..., description="Average overall rating")
    total_reviews: int = Field(..., description="Total number of reviews")
    rating_distribution: dict = Field(
        ..., description="Distribution of ratings (1-5 stars)"
    )
    category_averages: dict = Field(..., description="Average ratings by category")
    badges: List[str] = Field(..., description="Earned badges based on performance")


class ProviderBadge(BaseModel):
    """
    Schema for provider badges
    Explains why a badge was earned
    """

    name: str = Field(..., description="Badge name")
    description: str = Field(..., description="Badge description")
    earned_at: datetime = Field(..., description="Badge earned timestamp")
