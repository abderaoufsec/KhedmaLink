# Dispute API endpoints for KhedmaLink backend
# Handles dispute creation, evidence submission, responses, and resolution

from typing import List, Optional
from fastapi import APIRouter, Depends, HTTPException, status, Query
from sqlalchemy import select, and_, or_, func
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.orm import selectinload
from datetime import datetime

from app.core.database import get_db
from app.core.models.dispute import Dispute, DisputeEvidence, DisputeStatus
from app.core.models.booking import Booking
from app.core.models.user import User
from app.core.schemas.dispute import (
    DisputeCreate,
    DisputeUpdate,
    DisputeResolve,
    DisputeResponse,
    DisputeListResponse,
    DisputeEvidenceCreate,
    DisputeEvidenceResponse,
    DisputeEvidenceListResponse,
)
from app.core.security.dependencies import get_current_user, require_any_role
from app.api.v1.endpoints.admin import create_audit_log
from app.core.models.admin import AuditActionType


router = APIRouter()


@router.post(
    "/disputes", response_model=DisputeResponse, status_code=status.HTTP_201_CREATED
)
async def create_dispute(
    dispute_data: DisputeCreate,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    """
    Create a new dispute for a booking
    Customer or provider can raise a dispute for their booking
    """
    # Get booking
    result = await db.execute(
        select(Booking).where(Booking.id == dispute_data.booking_id)
    )
    booking = result.scalar_one_or_none()

    if not booking:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND, detail="Booking not found"
        )

    # Check if user is participant in the booking
    if str(booking.customer_id) != str(current_user.id) and str(
        booking.provider_id
    ) != str(current_user.id):
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="You are not a participant in this booking",
        )

    # Check if dispute already exists for this booking
    existing_dispute_query = select(Dispute).where(
        and_(
            Dispute.booking_id == dispute_data.booking_id,
            Dispute.status.in_([DisputeStatus.OPEN, DisputeStatus.INVESTIGATING]),
        )
    )
    existing_dispute_result = await db.execute(existing_dispute_query)
    existing_dispute = existing_dispute_result.scalar_one_or_none()

    if existing_dispute:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="An active dispute already exists for this booking",
        )

    # Create dispute
    new_dispute = Dispute(
        booking_id=dispute_data.booking_id,
        raised_by=current_user.id,
        dispute_type=dispute_data.dispute_type,
        title=dispute_data.title,
        description=dispute_data.description,
    )

    db.add(new_dispute)
    await db.commit()
    await db.refresh(new_dispute)

    # Update booking status to disputed
    booking.status = "disputed"
    await db.commit()

    return new_dispute


@router.get("/disputes", response_model=DisputeListResponse)
async def list_disputes(
    page: int = Query(1, ge=1),
    page_size: int = Query(20, ge=1, le=100),
    status_filter: Optional[str] = Query(None),
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    """
    List disputes for the current user
    Shows disputes where the user is the raiser or participant
    """
    # Build query - user can be raiser or participant in booking
    query = (
        select(Dispute)
        .options(selectinload(Dispute.booking))
        .where(
            or_(
                Dispute.raised_by == current_user.id,
                Dispute.booking_id.in_(
                    select(Booking.id).where(
                        or_(
                            Booking.customer_id == current_user.id,
                            Booking.provider_id == current_user.id,
                        )
                    )
                ),
            )
        )
    )

    # Apply status filter if provided
    if status_filter:
        query = query.where(Dispute.status == status_filter)

    # Count total
    count_query = select(func.count()).select_from(query.subquery())
    total_result = await db.execute(count_query)
    total = total_result.scalar()

    # Apply pagination
    query = query.offset((page - 1) * page_size).limit(page_size)
    query = query.order_by(Dispute.created_at.desc())

    result = await db.execute(query)
    disputes = result.scalars().all()

    return DisputeListResponse(
        items=[DisputeResponse.model_validate(d) for d in disputes],
        total=total,
        page=page,
        page_size=page_size,
    )


@router.get("/disputes/{dispute_id}", response_model=DisputeResponse)
async def get_dispute(
    dispute_id: str,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    """
    Get a specific dispute
    User must be participant in the booking or admin
    """
    from sqlalchemy import func

    # Get dispute
    query = (
        select(Dispute)
        .options(selectinload(Dispute.booking))
        .where(Dispute.id == dispute_id)
    )
    result = await db.execute(query)
    dispute = result.scalar_one_or_none()

    if not dispute:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND, detail="Dispute not found"
        )

    # Check if user is participant or admin
    is_participant = str(dispute.booking.customer_id) == str(current_user.id) or str(
        dispute.booking.provider_id
    ) == str(current_user.id)
    is_admin = any(role.name in ["admin", "super_admin"] for role in current_user.roles)

    if not is_participant and not is_admin:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="You do not have permission to access this dispute",
        )

    return dispute


@router.put("/disputes/{dispute_id}", response_model=DisputeResponse)
async def update_dispute(
    dispute_id: str,
    update_data: DisputeUpdate,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    """
    Update a dispute (add response)
    The other party in the booking can respond to the dispute
    """
    # Get dispute
    query = (
        select(Dispute)
        .options(selectinload(Dispute.booking))
        .where(Dispute.id == dispute_id)
    )
    result = await db.execute(query)
    dispute = result.scalar_one_or_none()

    if not dispute:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND, detail="Dispute not found"
        )

    # Check if user is the other party in the booking
    is_raisers_opponent = str(dispute.raised_by) != str(current_user.id)
    is_booking_participant = str(dispute.booking.customer_id) == str(
        current_user.id
    ) or str(dispute.booking.provider_id) == str(current_user.id)

    if not (is_raisers_opponent and is_booking_participant):
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Only the other party in the booking can respond",
        )

    # Add response to description
    if update_data.response:
        dispute.description = (
            f"{dispute.description}\n\nResponse: {update_data.response}"
        )
        dispute.status = DisputeStatus.INVESTIGATING

    await db.commit()
    await db.refresh(dispute)

    return dispute


@router.post("/disputes/{dispute_id}/resolve", response_model=DisputeResponse)
async def resolve_dispute(
    dispute_id: str,
    resolve_data: DisputeResolve,
    current_user: User = Depends(require_any_role("admin", "super_admin")),
    db: AsyncSession = Depends(get_db),
):
    """
    Resolve a dispute
    Admin only endpoint for dispute resolution
    Creates audit log for compliance
    """
    # Get dispute
    query = (
        select(Dispute)
        .options(selectinload(Dispute.booking))
        .where(Dispute.id == dispute_id)
    )
    result = await db.execute(query)
    dispute = result.scalar_one_or_none()

    if not dispute:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND, detail="Dispute not found"
        )

    # Update dispute
    dispute.resolution = resolve_data.resolution
    dispute.status = DisputeStatus.RESOLVED
    dispute.resolved_by = current_user.id
    dispute.resolved_at = datetime.utcnow()

    await db.commit()
    await db.refresh(dispute)

    # Create audit log
    await create_audit_log(
        db=db,
        action_type=AuditActionType.DISPUTE_RESOLVED,
        actor_id=current_user.id,
        description=f"Resolved dispute {dispute.id}",
        target_user_id=dispute.raised_by,
        target_resource_type="dispute",
        target_resource_id=dispute.id,
        reason=resolve_data.resolution,
    )

    return dispute


@router.post(
    "/disputes/{dispute_id}/evidence",
    response_model=DisputeEvidenceResponse,
    status_code=status.HTTP_201_CREATED,
)
async def add_evidence(
    dispute_id: str,
    evidence_data: DisputeEvidenceCreate,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    """
    Add evidence to a dispute
    Participants in the booking can add evidence
    """
    # Get dispute
    query = (
        select(Dispute)
        .options(selectinload(Dispute.booking))
        .where(Dispute.id == dispute_id)
    )
    result = await db.execute(query)
    dispute = result.scalar_one_or_none()

    if not dispute:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND, detail="Dispute not found"
        )

    # Check if user is participant in the booking
    if str(dispute.booking.customer_id) != str(current_user.id) and str(
        dispute.booking.provider_id
    ) != str(current_user.id):
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="You are not a participant in this booking",
        )

    # Create evidence
    new_evidence = DisputeEvidence(
        dispute_id=dispute_id,
        submitted_by=current_user.id,
        evidence_type=evidence_data.evidence_type,
        file_url=evidence_data.file_url,
        file_name=evidence_data.file_name,
        file_size=evidence_data.file_size,
        mime_type=evidence_data.mime_type,
        description=evidence_data.description,
    )

    db.add(new_evidence)
    await db.commit()
    await db.refresh(new_evidence)

    return new_evidence


@router.get(
    "/disputes/{dispute_id}/evidence", response_model=DisputeEvidenceListResponse
)
async def list_evidence(
    dispute_id: str,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    """
    List evidence for a dispute
    Participants in the booking or admins can view evidence
    """
    # Get dispute
    query = (
        select(Dispute)
        .options(selectinload(Dispute.booking))
        .where(Dispute.id == dispute_id)
    )
    result = await db.execute(query)
    dispute = result.scalar_one_or_none()

    if not dispute:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND, detail="Dispute not found"
        )

    # Check if user is participant or admin
    is_participant = str(dispute.booking.customer_id) == str(current_user.id) or str(
        dispute.booking.provider_id
    ) == str(current_user.id)
    is_admin = any(role.name in ["admin", "super_admin"] for role in current_user.roles)

    if not is_participant and not is_admin:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="You do not have permission to view this dispute's evidence",
        )

    # Get evidence
    evidence_query = select(DisputeEvidence).where(
        DisputeEvidence.dispute_id == dispute_id
    )
    evidence_result = await db.execute(evidence_query)
    evidence = evidence_result.scalars().all()

    return DisputeEvidenceListResponse(
        items=[DisputeEvidenceResponse.model_validate(e) for e in evidence]
    )
