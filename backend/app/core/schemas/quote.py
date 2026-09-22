"""
Pydantic schemas for quote operations
Contains request and response models for quotes and request matches
"""

from typing import Optional, List
from pydantic import BaseModel, Field, field_validator, ConfigDict
from datetime import datetime


# =============================================================================
# QUOTE SCHEMAS
# =============================================================================


class QuoteBase(BaseModel):
    """
    Base schema for quote operations
    Contains common fields for quote requests and responses
    """

    request_id: str = Field(..., description="Service request ID")
    description: Optional[str] = Field(None, description="Quote description/details")
    estimated_price: float = Field(..., gt=0, description="Estimated price")
    currency: str = Field(default="DZD", max_length=3, description="Currency code")
    estimated_duration: Optional[int] = Field(
        None, gt=0, description="Duration in minutes"
    )
    estimated_duration_unit: Optional[str] = Field(
        None, max_length=20, description="Duration unit (minutes, hours, days)"
    )
    available_date: Optional[datetime] = Field(
        None, description="Available date for service"
    )
    available_time_start: Optional[str] = Field(
        None, description="Available start time (HH:MM)"
    )
    available_time_end: Optional[str] = Field(
        None, description="Available end time (HH:MM)"
    )

    @field_validator("available_time_start", "available_time_end")
    @classmethod
    def validate_time_format(cls, v: Optional[str]) -> Optional[str]:
        """
        Validate time format is HH:MM
        """
        if v is None:
            return v
        if len(v) != 5 or v[2] != ":":
            raise ValueError("Time must be in HH:MM format")
        try:
            hours = int(v[:2])
            minutes = int(v[3:])
            if not (0 <= hours <= 23):
                raise ValueError("Hours must be between 00 and 23")
            if not (0 <= minutes <= 59):
                raise ValueError("Minutes must be between 00 and 59")
        except ValueError:
            raise ValueError("Invalid time format")
        return v

    @field_validator("estimated_duration_unit")
    @classmethod
    def validate_duration_unit(cls, v: Optional[str]) -> Optional[str]:
        """
        Validate duration unit
        """
        if v is None:
            return v
        valid_units = ["minutes", "hours", "days"]
        if v not in valid_units:
            raise ValueError(f"Duration unit must be one of: {', '.join(valid_units)}")
        return v


class QuoteCreate(QuoteBase):
    """
    Schema for creating a new quote
    Used by providers to submit quotes for service requests
    """

    pass


class QuoteUpdate(BaseModel):
    """
    Schema for updating an existing quote
    All fields are optional to allow partial updates
    """

    description: Optional[str] = None
    estimated_price: Optional[float] = Field(None, gt=0)
    currency: Optional[str] = Field(None, max_length=3)
    estimated_duration: Optional[int] = Field(None, gt=0)
    estimated_duration_unit: Optional[str] = Field(None, max_length=20)
    available_date: Optional[datetime] = None
    available_time_start: Optional[str] = None
    available_time_end: Optional[str] = None
    status: Optional[str] = Field(None, description="Quote status")

    @field_validator("available_time_start", "available_time_end")
    @classmethod
    def validate_time_format(cls, v: Optional[str]) -> Optional[str]:
        """
        Validate time format is HH:MM
        """
        if v is None:
            return v
        if len(v) != 5 or v[2] != ":":
            raise ValueError("Time must be in HH:MM format")
        try:
            hours = int(v[:2])
            minutes = int(v[3:])
            if not (0 <= hours <= 23):
                raise ValueError("Hours must be between 00 and 23")
            if not (0 <= minutes <= 59):
                raise ValueError("Minutes must be between 00 and 59")
        except ValueError:
            raise ValueError("Invalid time format")
        return v

    @field_validator("status")
    @classmethod
    def validate_status(cls, v: Optional[str]) -> Optional[str]:
        """
        Validate status
        """
        if v is None:
            return v
        valid_statuses = [
            "draft",
            "submitted",
            "withdrawn",
            "accepted",
            "rejected",
            "expired",
        ]
        if v not in valid_statuses:
            raise ValueError(f"Status must be one of: {', '.join(valid_statuses)}")
        return v

    @field_validator("estimated_duration_unit")
    @classmethod
    def validate_duration_unit(cls, v: Optional[str]) -> Optional[str]:
        """
        Validate duration unit
        """
        if v is None:
            return v
        valid_units = ["minutes", "hours", "days"]
        if v not in valid_units:
            raise ValueError(f"Duration unit must be one of: {', '.join(valid_units)}")
        return v


class QuoteResponse(QuoteBase):
    """
    Schema for quote response
    Returns quote information including ID, provider ID, and timestamps
    """

    id: str = Field(..., description="Quote ID")
    provider_id: str = Field(..., description="Provider user ID")
    status: str = Field(..., description="Quote status")
    rejection_reason: Optional[str] = Field(None, description="Reason for rejection")
    rejected_at: Optional[str] = Field(None, description="Rejection timestamp")
    created_at: str = Field(..., description="Quote creation timestamp")
    updated_at: Optional[str] = Field(None, description="Quote last update timestamp")
    submitted_at: Optional[str] = Field(None, description="Quote submission timestamp")
    accepted_at: Optional[str] = Field(None, description="Quote acceptance timestamp")

    model_config = ConfigDict(from_attributes=True)


class QuotePublic(BaseModel):
    """
    Schema for public quote information
    Returns limited information visible to customers
    """

    id: str = Field(..., description="Quote ID")
    request_id: str = Field(..., description="Service request ID")
    provider_id: str = Field(..., description="Provider user ID")
    description: Optional[str] = Field(None, description="Quote description")
    estimated_price: float = Field(..., description="Estimated price")
    currency: str = Field(..., description="Currency code")
    estimated_duration: Optional[int] = Field(None, description="Duration in minutes")
    estimated_duration_unit: Optional[str] = Field(None, description="Duration unit")
    available_date: Optional[datetime] = Field(None, description="Available date")
    available_time_start: Optional[str] = Field(
        None, description="Available start time"
    )
    available_time_end: Optional[str] = Field(None, description="Available end time")
    status: str = Field(..., description="Quote status")
    created_at: str = Field(..., description="Quote creation timestamp")

    model_config = ConfigDict(from_attributes=True)


# =============================================================================
# REQUEST MATCH SCHEMAS
# =============================================================================


class RequestMatchBase(BaseModel):
    """
    Base schema for request match operations
    Contains common fields for request match requests and responses
    """

    request_id: str = Field(..., description="Service request ID")
    provider_id: str = Field(..., description="Provider user ID")
    match_score: Optional[float] = Field(
        None, ge=0, le=100, description="Match score (0-100)"
    )
    eligibility_reason: Optional[str] = Field(
        None, description="Why this provider is eligible"
    )


class RequestMatchCreate(RequestMatchBase):
    """
    Schema for creating a new request match
    Used by the system to track provider-request matching
    """

    pass


class RequestMatchResponse(RequestMatchBase):
    """
    Schema for request match response
    Returns request match information including ID and timestamps
    """

    id: str = Field(..., description="Request match ID")
    status: str = Field(..., description="Match status")
    created_at: str = Field(..., description="Match creation timestamp")
    updated_at: Optional[str] = Field(None, description="Match last update timestamp")

    model_config = ConfigDict(from_attributes=True)
