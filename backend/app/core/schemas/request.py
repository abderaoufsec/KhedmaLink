"""
Pydantic schemas for service request operations
Contains request and response models for service requests and attachments
"""

from typing import Optional, List
from pydantic import BaseModel, Field, field_validator, ConfigDict
from datetime import datetime


# =============================================================================
# SERVICE REQUEST SCHEMAS
# =============================================================================


class ServiceRequestBase(BaseModel):
    """
    Base schema for service request operations
    Contains common fields for service request requests and responses
    """

    category_id: str = Field(..., description="Category ID")
    title_ar: str = Field(..., max_length=255, description="Request title in Arabic")
    title_fr: str = Field(..., max_length=255, description="Request title in French")
    description_ar: str = Field(..., description="Request description in Arabic")
    description_fr: str = Field(..., description="Request description in French")
    city: str = Field(..., max_length=100, description="City name")
    wilaya: str = Field(..., max_length=100, description="Wilaya name")
    commune: Optional[str] = Field(None, max_length=100, description="Commune name")
    address: Optional[str] = Field(None, max_length=500, description="Detailed address")
    latitude: Optional[float] = Field(
        None, ge=-90, le=90, description="Latitude coordinate"
    )
    longitude: Optional[float] = Field(
        None, ge=-180, le=180, description="Longitude coordinate"
    )
    preferred_date: Optional[datetime] = Field(
        None, description="Preferred date for service"
    )
    preferred_time_start: Optional[str] = Field(
        None, description="Preferred start time (HH:MM)"
    )
    preferred_time_end: Optional[str] = Field(
        None, description="Preferred end time (HH:MM)"
    )
    is_flexible: bool = Field(default=False, description="Whether schedule is flexible")
    budget_min: Optional[float] = Field(None, ge=0, description="Minimum budget")
    budget_max: Optional[float] = Field(None, ge=0, description="Maximum budget")
    currency: str = Field(default="DZD", max_length=3, description="Currency code")
    urgency: str = Field(
        default="medium", description="Urgency level (low, medium, high, urgent)"
    )
    is_public: bool = Field(
        default=True, description="Whether request is visible to providers"
    )

    @field_validator("preferred_time_start", "preferred_time_end")
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

    @field_validator("urgency")
    @classmethod
    def validate_urgency(cls, v: str) -> str:
        """
        Validate urgency level
        """
        valid_urgencies = ["low", "medium", "high", "urgent"]
        if v not in valid_urgencies:
            raise ValueError(f"Urgency must be one of: {', '.join(valid_urgencies)}")
        return v


class ServiceRequestCreate(ServiceRequestBase):
    """
    Schema for creating a new service request
    Used by customers to submit service requests
    """

    pass


class ServiceRequestUpdate(BaseModel):
    """
    Schema for updating an existing service request
    All fields are optional to allow partial updates
    """

    category_id: Optional[str] = None
    title_ar: Optional[str] = Field(None, max_length=255)
    title_fr: Optional[str] = Field(None, max_length=255)
    description_ar: Optional[str] = None
    description_fr: Optional[str] = None
    city: Optional[str] = Field(None, max_length=100)
    wilaya: Optional[str] = Field(None, max_length=100)
    commune: Optional[str] = Field(None, max_length=100)
    address: Optional[str] = Field(None, max_length=500)
    latitude: Optional[float] = Field(None, ge=-90, le=90)
    longitude: Optional[float] = Field(None, ge=-180, le=180)
    preferred_date: Optional[datetime] = None
    preferred_time_start: Optional[str] = None
    preferred_time_end: Optional[str] = None
    is_flexible: Optional[bool] = None
    budget_min: Optional[float] = Field(None, ge=0)
    budget_max: Optional[float] = Field(None, ge=0)
    currency: Optional[str] = Field(None, max_length=3)
    status: Optional[str] = Field(
        None, description="Request status (draft, open, closed, cancelled)"
    )
    urgency: Optional[str] = None
    is_public: Optional[bool] = None

    @field_validator("preferred_time_start", "preferred_time_end")
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
        valid_statuses = ["draft", "open", "closed", "cancelled"]
        if v not in valid_statuses:
            raise ValueError(f"Status must be one of: {', '.join(valid_statuses)}")
        return v

    @field_validator("urgency")
    @classmethod
    def validate_urgency(cls, v: Optional[str]) -> Optional[str]:
        """
        Validate urgency level
        """
        if v is None:
            return v
        valid_urgencies = ["low", "medium", "high", "urgent"]
        if v not in valid_urgencies:
            raise ValueError(f"Urgency must be one of: {', '.join(valid_urgencies)}")
        return v


class ServiceRequestResponse(ServiceRequestBase):
    """
    Schema for service request response
    Returns service request information including ID and timestamps
    """

    id: str = Field(..., description="Service request ID")
    customer_id: str = Field(..., description="Customer user ID")
    status: str = Field(..., description="Request status")
    created_at: str = Field(..., description="Request creation timestamp")
    updated_at: Optional[str] = Field(None, description="Request last update timestamp")
    closed_at: Optional[str] = Field(None, description="Request closure timestamp")

    model_config = ConfigDict(from_attributes=True)


class ServiceRequestPublic(BaseModel):
    """
    Schema for public service request information
    Returns limited information visible to providers
    """

    id: str = Field(..., description="Service request ID")
    category_id: str = Field(..., description="Category ID")
    title_ar: str = Field(..., description="Request title in Arabic")
    title_fr: str = Field(..., description="Request title in French")
    description_ar: str = Field(..., description="Request description in Arabic")
    description_fr: str = Field(..., description="Request description in French")
    city: str = Field(..., description="City name")
    wilaya: str = Field(..., description="Wilaya name")
    commune: Optional[str] = Field(None, description="Commune name")
    preferred_date: Optional[datetime] = Field(None, description="Preferred date")
    preferred_time_start: Optional[str] = Field(
        None, description="Preferred start time"
    )
    preferred_time_end: Optional[str] = Field(None, description="Preferred end time")
    is_flexible: bool = Field(..., description="Whether schedule is flexible")
    budget_min: Optional[float] = Field(None, description="Minimum budget")
    budget_max: Optional[float] = Field(None, description="Maximum budget")
    currency: str = Field(..., description="Currency code")
    urgency: str = Field(..., description="Urgency level")
    created_at: str = Field(..., description="Request creation timestamp")

    model_config = ConfigDict(from_attributes=True)


# =============================================================================
# REQUEST ATTACHMENT SCHEMAS
# =============================================================================


class RequestAttachmentBase(BaseModel):
    """
    Base schema for request attachment operations
    Contains common fields for request attachment requests and responses
    """

    file_url: str = Field(..., max_length=500, description="File URL")
    file_name: str = Field(..., max_length=255, description="Original filename")
    file_type: str = Field(..., max_length=100, description="MIME type")
    file_size: int = Field(..., ge=0, description="File size in bytes")
    thumbnail_url: Optional[str] = Field(
        None, max_length=500, description="Thumbnail URL"
    )
    attachment_type: str = Field(
        default="photo", description="Attachment type (photo, document, other)"
    )

    @field_validator("attachment_type")
    @classmethod
    def validate_attachment_type(cls, v: str) -> str:
        """
        Validate attachment type
        """
        valid_types = ["photo", "document", "other"]
        if v not in valid_types:
            raise ValueError(
                f"Attachment type must be one of: {', '.join(valid_types)}"
            )
        return v


class RequestAttachmentCreate(RequestAttachmentBase):
    """
    Schema for creating a new request attachment
    Used by customers to attach photos/documents to requests
    """

    pass


class RequestAttachmentResponse(RequestAttachmentBase):
    """
    Schema for request attachment response
    Returns request attachment information including ID and timestamps
    """

    id: str = Field(..., description="Attachment ID")
    request_id: str = Field(..., description="Service request ID")
    uploaded_by: Optional[str] = Field(
        None, description="User ID who uploaded the file"
    )
    upload_status: str = Field(..., description="Upload status")
    created_at: str = Field(..., description="Attachment creation timestamp")

    model_config = ConfigDict(from_attributes=True)
