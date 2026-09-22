"""
Pydantic schemas for booking operations
Contains request and response models for bookings and booking events
"""

from typing import Optional, List
from pydantic import BaseModel, Field, field_validator, ConfigDict
from datetime import datetime


# =============================================================================
# BOOKING SCHEMAS
# =============================================================================


class BookingBase(BaseModel):
    """
    Base schema for booking operations
    Contains common fields for booking requests and responses
    """

    request_id: str = Field(..., description="Service request ID")
    quote_id: str = Field(..., description="Accepted quote ID")
    customer_id: str = Field(..., description="Customer user ID")
    provider_id: str = Field(..., description="Provider user ID")
    scheduled_date: Optional[datetime] = Field(
        None, description="Scheduled date for service"
    )
    scheduled_time_start: Optional[str] = Field(
        None, description="Scheduled start time (HH:MM)"
    )
    scheduled_time_end: Optional[str] = Field(
        None, description="Scheduled end time (HH:MM)"
    )
    estimated_duration: Optional[int] = Field(
        None, ge=0, description="Estimated duration in minutes"
    )
    estimated_duration_unit: Optional[str] = Field(
        "minutes", description="Duration unit"
    )
    agreed_price: float = Field(..., gt=0, description="Agreed price from quote")
    currency: str = Field(default="DZD", max_length=3, description="Currency code")
    address: Optional[str] = Field(None, max_length=500, description="Service address")
    city: Optional[str] = Field(None, max_length=100, description="City name")
    wilaya: Optional[str] = Field(None, max_length=100, description="Wilaya name")
    latitude: Optional[float] = Field(
        None, ge=-90, le=90, description="Latitude coordinate"
    )
    longitude: Optional[float] = Field(
        None, ge=-180, le=180, description="Longitude coordinate"
    )


class BookingCreate(BookingBase):
    """
    Schema for creating a new booking
    Used when a customer accepts a quote
    """

    pass


class BookingUpdate(BaseModel):
    """
    Schema for updating booking information
    Allows updating scheduling and notes
    """

    scheduled_date: Optional[datetime] = Field(
        None, description="Scheduled date for service"
    )
    scheduled_time_start: Optional[str] = Field(
        None, description="Scheduled start time (HH:MM)"
    )
    scheduled_time_end: Optional[str] = Field(
        None, description="Scheduled end time (HH:MM)"
    )
    estimated_duration: Optional[int] = Field(
        None, ge=0, description="Estimated duration in minutes"
    )
    estimated_duration_unit: Optional[str] = Field(None, description="Duration unit")
    completion_notes: Optional[str] = Field(None, description="Completion notes")


class BookingResponse(BookingBase):
    """
    Schema for booking response
    Includes all booking fields with timestamps
    """

    model_config = ConfigDict(from_attributes=True)

    id: str = Field(..., description="Booking ID")
    status: str = Field(..., description="Booking status")
    cancelled_at: Optional[datetime] = Field(None, description="Cancellation timestamp")
    cancelled_by: Optional[str] = Field(None, description="User ID who cancelled")
    cancellation_reason: Optional[str] = Field(None, description="Cancellation reason")
    completed_at: Optional[datetime] = Field(None, description="Completion timestamp")
    completion_notes: Optional[str] = Field(None, description="Completion notes")
    created_at: datetime = Field(..., description="Creation timestamp")
    updated_at: datetime = Field(..., description="Last update timestamp")


class BookingCancel(BaseModel):
    """
    Schema for cancelling a booking
    Requires cancellation reason
    """

    cancellation_reason: str = Field(
        ..., min_length=1, max_length=1000, description="Reason for cancellation"
    )


class BookingComplete(BaseModel):
    """
    Schema for completing a booking
    Optional completion notes
    """

    completion_notes: Optional[str] = Field(
        None, max_length=2000, description="Completion notes"
    )


# =============================================================================
# BOOKING EVENT SCHEMAS
# =============================================================================


class BookingEventBase(BaseModel):
    """
    Base schema for booking events
    Contains common fields for booking events
    """

    booking_id: str = Field(..., description="Booking ID")
    event_type: str = Field(..., description="Event type")
    old_status: Optional[str] = Field(None, description="Previous status")
    new_status: Optional[str] = Field(None, description="New status")
    notes: Optional[str] = Field(None, description="Event notes")
    event_metadata: Optional[str] = Field(
        None, description="Additional metadata (JSON)"
    )


class BookingEventResponse(BookingEventBase):
    """
    Schema for booking event response
    Includes all event fields with timestamp
    """

    model_config = ConfigDict(from_attributes=True)

    id: str = Field(..., description="Event ID")
    triggered_by: Optional[str] = Field(
        None, description="User ID who triggered the event"
    )
    created_at: datetime = Field(..., description="Event timestamp")


# =============================================================================
# BOOKING LIST SCHEMAS
# =============================================================================


class BookingListResponse(BaseModel):
    """
    Schema for booking list response
    Includes pagination metadata
    """

    bookings: List[BookingResponse] = Field(..., description="List of bookings")
    total: int = Field(..., description="Total number of bookings")
    skip: int = Field(..., description="Number of bookings skipped")
    limit: int = Field(..., description="Maximum number of bookings returned")
