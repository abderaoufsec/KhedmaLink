# Dispute schemas for KhedmaLink backend
# Contains Pydantic schemas for dispute operations and evidence

from datetime import datetime
from uuid import UUID
from typing import Optional, List
from pydantic import BaseModel, Field
from enum import Enum


class DisputeStatus(str, Enum):
    """Status of a dispute"""

    OPEN = "open"
    INVESTIGATING = "investigating"
    RESOLVED = "resolved"
    CLOSED = "closed"


class DisputeType(str, Enum):
    """Type of dispute"""

    SERVICE_QUALITY = "service_quality"
    PAYMENT_ISSUE = "payment_issue"
    COMMUNICATION = "communication"
    DAMAGE = "damage"
    SAFETY = "safety"
    OTHER = "other"


class DisputeCreate(BaseModel):
    """Schema for creating a dispute"""

    booking_id: UUID = Field(..., description="ID of the booking being disputed")
    dispute_type: DisputeType = Field(..., description="Type of dispute")
    title: str = Field(
        ..., min_length=1, max_length=255, description="Title of the dispute"
    )
    description: str = Field(
        ...,
        min_length=1,
        max_length=5000,
        description="Detailed description of the dispute",
    )


class DisputeUpdate(BaseModel):
    """Schema for updating a dispute (response)"""

    response: Optional[str] = Field(
        None, max_length=5000, description="Response to the dispute"
    )


class DisputeResolve(BaseModel):
    """Schema for resolving a dispute (admin only)"""

    resolution: str = Field(
        ..., min_length=1, max_length=5000, description="Resolution details"
    )


class DisputeResponse(BaseModel):
    """Schema for dispute response"""

    id: UUID
    booking_id: UUID
    raised_by: UUID
    dispute_type: DisputeType
    status: DisputeStatus
    title: str
    description: str
    resolution: Optional[str]
    resolved_by: Optional[UUID]
    resolved_at: Optional[datetime]
    created_at: datetime
    updated_at: datetime

    class Config:
        from_attributes = True


class DisputeListResponse(BaseModel):
    """Schema for paginated dispute list"""

    items: List[DisputeResponse]
    total: int
    page: int
    page_size: int


class DisputeEvidenceCreate(BaseModel):
    """Schema for creating dispute evidence"""

    evidence_type: str = Field(
        ..., description="Type of evidence: image, document, text"
    )
    file_url: Optional[str] = Field(None, description="URL to stored file")
    file_name: Optional[str] = Field(
        None, max_length=255, description="Name of the file"
    )
    file_size: Optional[str] = Field(
        None, max_length=50, description="Human-readable file size"
    )
    mime_type: Optional[str] = Field(
        None, max_length=100, description="MIME type of the file"
    )
    description: Optional[str] = Field(
        None, max_length=2000, description="Description of the evidence"
    )


class DisputeEvidenceResponse(BaseModel):
    """Schema for dispute evidence response"""

    id: UUID
    dispute_id: UUID
    submitted_by: UUID
    evidence_type: str
    file_url: Optional[str]
    file_name: Optional[str]
    file_size: Optional[str]
    mime_type: Optional[str]
    description: Optional[str]
    created_at: datetime

    class Config:
        from_attributes = True


class DisputeEvidenceListResponse(BaseModel):
    """Schema for dispute evidence list"""

    items: List[DisputeEvidenceResponse]
