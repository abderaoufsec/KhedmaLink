"""
Service Request API endpoints
Handles CRUD operations for customer service requests and attachments
"""

from typing import List, Optional
from fastapi import APIRouter, Depends, HTTPException, status, Query
from sqlalchemy import select, and_, or_
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.database import get_db
from app.core.models.request import ServiceRequest, RequestAttachment
from app.core.models.user import User
from app.core.schemas.request import (
    ServiceRequestCreate,
    ServiceRequestUpdate,
    ServiceRequestResponse,
    ServiceRequestPublic,
    RequestAttachmentCreate,
    RequestAttachmentResponse,
)
from app.core.security.dependencies import get_current_user

# Create router for request endpoints
router = APIRouter()


# =============================================================================
# CUSTOMER REQUEST MANAGEMENT ENDPOINTS
# =============================================================================


@router.get(
    "/me/requests",
    response_model=List[ServiceRequestResponse],
    status_code=status.HTTP_200_OK,
)
async def list_my_requests(
    current_user: User = Depends(get_current_user),
    skip: int = 0,
    limit: int = 100,
    status_filter: Optional[str] = Query(None, description="Filter by status"),
    db: AsyncSession = Depends(get_db),
):
    """
    List current user's service requests

    - **skip**: Number of requests to skip (pagination)
    - **limit**: Maximum number of requests to return
    - **status_filter**: Filter by status (draft, open, closed, cancelled)

    Returns all service requests for the authenticated user
    """
    # Build query
    query = select(ServiceRequest).where(
        ServiceRequest.customer_id == str(current_user.id)
    )

    # Apply status filter if provided
    if status_filter:
        query = query.where(ServiceRequest.status == status_filter)

    # Apply sorting and pagination
    query = query.order_by(ServiceRequest.created_at.desc()).offset(skip).limit(limit)

    # Execute query
    result = await db.execute(query)
    requests = result.scalars().all()

    return requests


@router.post(
    "/me/requests",
    response_model=ServiceRequestResponse,
    status_code=status.HTTP_201_CREATED,
)
async def create_service_request(
    request_data: ServiceRequestCreate,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    """
    Create a new service request for the current user

    - **request_data**: Service request creation data

    Creates a new service request for the authenticated user
    """
    # Check if category exists
    from app.core.models.provider import Category

    category_query = select(Category).where(Category.id == request_data.category_id)
    category_result = await db.execute(category_query)
    category = category_result.scalar_one_or_none()

    if not category:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND, detail="Category not found"
        )

    # Create new service request
    new_request = ServiceRequest(
        customer_id=str(current_user.id), **request_data.model_dump()
    )

    # Add to database
    db.add(new_request)
    await db.commit()
    await db.refresh(new_request)

    return new_request


@router.get(
    "/me/requests/{request_id}",
    response_model=ServiceRequestResponse,
    status_code=status.HTTP_200_OK,
)
async def get_my_request(
    request_id: str,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    """
    Get a specific service request by ID for the current user

    - **request_id**: UUID of the service request

    Returns service request details or 404 if not found
    """
    # Query for service request
    query = select(ServiceRequest).where(
        and_(
            ServiceRequest.id == request_id,
            ServiceRequest.customer_id == str(current_user.id),
        )
    )
    result = await db.execute(query)
    request = result.scalar_one_or_none()

    # Check if request exists and belongs to user
    if not request:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND, detail="Service request not found"
        )

    return request


@router.put(
    "/me/requests/{request_id}",
    response_model=ServiceRequestResponse,
    status_code=status.HTTP_200_OK,
)
async def update_service_request(
    request_id: str,
    request_data: ServiceRequestUpdate,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    """
    Update a service request for the current user

    - **request_id**: UUID of the service request to update
    - **request_data**: Service request update data

    Updates the service request for the authenticated user
    """
    # Query for existing service request
    query = select(ServiceRequest).where(
        and_(
            ServiceRequest.id == request_id,
            ServiceRequest.customer_id == str(current_user.id),
        )
    )
    result = await db.execute(query)
    request = result.scalar_one_or_none()

    # Check if request exists and belongs to user
    if not request:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND, detail="Service request not found"
        )

    # Validate status transition
    if request_data.status:
        # Only allow certain status transitions
        if request.status == "closed" and request_data.status != "closed":
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Cannot change status of a closed request",
            )
        if request.status == "cancelled" and request_data.status != "cancelled":
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Cannot change status of a cancelled request",
            )

    # Update request fields
    update_data = request_data.model_dump(exclude_unset=True)
    for field, value in update_data.items():
        setattr(request, field, value)

    # Set closed_at timestamp if status is being set to closed
    if request_data.status == "closed" and request.closed_at is None:
        from datetime import datetime

        request.closed_at = datetime.utcnow()

    # Commit changes
    await db.commit()
    await db.refresh(request)

    return request


@router.delete("/me/requests/{request_id}", status_code=status.HTTP_204_NO_CONTENT)
async def delete_service_request(
    request_id: str,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    """
    Delete a service request for the current user

    - **request_id**: UUID of the service request to delete

    Deletes the service request for the authenticated user
    """
    # Query for existing service request
    query = select(ServiceRequest).where(
        and_(
            ServiceRequest.id == request_id,
            ServiceRequest.customer_id == str(current_user.id),
        )
    )
    result = await db.execute(query)
    request = result.scalar_one_or_none()

    # Check if request exists and belongs to user
    if not request:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND, detail="Service request not found"
        )

    # Only allow deletion of draft or open requests
    if request.status not in ["draft", "open"]:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Cannot delete a request that is not in draft or open status",
        )

    # Delete service request
    await db.delete(request)
    await db.commit()

    return None


# =============================================================================
# PUBLIC REQUEST DISCOVERY ENDPOINTS (FOR PROVIDERS)
# =============================================================================


@router.get(
    "/public/requests",
    response_model=List[ServiceRequestPublic],
    status_code=status.HTTP_200_OK,
)
async def list_public_requests(
    skip: int = 0,
    limit: int = 100,
    category_id: Optional[str] = Query(None, description="Filter by category ID"),
    city: Optional[str] = Query(None, description="Filter by city"),
    wilaya: Optional[str] = Query(None, description="Filter by wilaya"),
    urgency: Optional[str] = Query(None, description="Filter by urgency"),
    db: AsyncSession = Depends(get_db),
):
    """
    List public service requests for providers to view

    - **skip**: Number of requests to skip (pagination)
    - **limit**: Maximum number of requests to return
    - **category_id**: Filter by category ID
    - **city**: Filter by city
    - **wilaya**: Filter by wilaya
    - **urgency**: Filter by urgency level

    Returns a list of public service requests
    """
    # Build base query
    query = select(ServiceRequest).where(
        and_(ServiceRequest.is_public == True, ServiceRequest.status == "open")
    )

    # Apply filters
    if category_id:
        query = query.where(ServiceRequest.category_id == category_id)

    if city:
        query = query.where(ServiceRequest.city == city)

    if wilaya:
        query = query.where(ServiceRequest.wilaya == wilaya)

    if urgency:
        query = query.where(ServiceRequest.urgency == urgency)

    # Apply sorting and pagination
    query = query.order_by(ServiceRequest.created_at.desc()).offset(skip).limit(limit)

    # Execute query
    result = await db.execute(query)
    requests = result.scalars().all()

    return requests


@router.get(
    "/public/requests/{request_id}",
    response_model=ServiceRequestPublic,
    status_code=status.HTTP_200_OK,
)
async def get_public_request(
    request_id: str,
    db: AsyncSession = Depends(get_db),
):
    """
    Get a public service request by ID

    - **request_id**: UUID of the service request

    Returns public service request details or 404 if not found
    """
    # Query for service request
    query = select(ServiceRequest).where(
        and_(
            ServiceRequest.id == request_id,
            ServiceRequest.is_public == True,
            ServiceRequest.status == "open",
        )
    )
    result = await db.execute(query)
    request = result.scalar_one_or_none()

    # Check if request exists
    if not request:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND, detail="Service request not found"
        )

    return request


# =============================================================================
# REQUEST ATTACHMENT ENDPOINTS
# =============================================================================


@router.get(
    "/me/requests/{request_id}/attachments",
    response_model=List[RequestAttachmentResponse],
    status_code=status.HTTP_200_OK,
)
async def list_request_attachments(
    request_id: str,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    """
    List attachments for a service request

    - **request_id**: UUID of the service request

    Returns all attachments for the service request
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

    # Query for attachments
    query = select(RequestAttachment).where(RequestAttachment.request_id == request_id)
    result = await db.execute(query)
    attachments = result.scalars().all()

    return attachments


@router.post(
    "/me/requests/{request_id}/attachments",
    response_model=RequestAttachmentResponse,
    status_code=status.HTTP_201_CREATED,
)
async def create_request_attachment(
    request_id: str,
    attachment_data: RequestAttachmentCreate,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    """
    Create a new attachment for a service request

    - **request_id**: UUID of the service request
    - **attachment_data**: Attachment creation data

    Creates a new attachment for the service request
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

    # Create new attachment
    new_attachment = RequestAttachment(
        request_id=request_id,
        uploaded_by=str(current_user.id),
        **attachment_data.model_dump()
    )

    # Add to database
    db.add(new_attachment)
    await db.commit()
    await db.refresh(new_attachment)

    return new_attachment


@router.delete(
    "/me/requests/{request_id}/attachments/{attachment_id}",
    status_code=status.HTTP_204_NO_CONTENT,
)
async def delete_request_attachment(
    request_id: str,
    attachment_id: str,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    """
    Delete an attachment from a service request

    - **request_id**: UUID of the service request
    - **attachment_id**: UUID of the attachment to delete

    Deletes the attachment from the service request
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

    # Query for attachment
    query = select(RequestAttachment).where(
        and_(
            RequestAttachment.id == attachment_id,
            RequestAttachment.request_id == request_id,
        )
    )
    result = await db.execute(query)
    attachment = result.scalar_one_or_none()

    # Check if attachment exists
    if not attachment:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND, detail="Attachment not found"
        )

    # Delete attachment
    await db.delete(attachment)
    await db.commit()

    return None
