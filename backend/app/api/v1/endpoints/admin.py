# Admin endpoints for KhedmaLink backend
# Provides admin operations for user management, verification, and audit logs

from typing import List, Optional
from uuid import UUID
from datetime import datetime
from fastapi import APIRouter, Depends, HTTPException, Query, status
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select, and_, or_, func
from sqlalchemy.orm import selectinload

from app.core.database import get_db
from app.core.security.dependencies import get_current_user, require_any_role
from app.core.models import (
    User,
    Role,
    ProviderProfile,
    VerificationCase,
    AuditLog,
    AuditActionType,
)
from app.core.schemas import (
    AuditLogCreate,
    AuditLogResponse,
    AuditLogListResponse,
    UserStatusUpdate,
    UserStatusResponse,
    VerificationAction,
    VerificationActionResponse,
    ContentDeletion,
    UserListFilters,
    UserListItem,
    UserListResponse,
    ProviderVerificationQueueItem,
    VerificationQueueResponse,
)


router = APIRouter()


async def create_audit_log(
    db: AsyncSession,
    action_type: AuditActionType,
    actor_id: UUID,
    description: str,
    target_user_id: Optional[UUID] = None,
    target_resource_type: Optional[str] = None,
    target_resource_id: Optional[UUID] = None,
    reason: Optional[str] = None,
    changes: Optional[str] = None,
    ip_address: Optional[str] = None,
    user_agent: Optional[str] = None,
) -> AuditLog:
    """
    Create an audit log entry for tracking admin actions
    Ensures all privileged operations are auditable for compliance
    """
    audit_log = AuditLog(
        action_type=action_type,
        actor_id=actor_id,
        target_user_id=target_user_id,
        target_resource_type=target_resource_type,
        target_resource_id=target_resource_id,
        description=description,
        reason=reason,
        changes=changes,
        ip_address=ip_address,
        user_agent=user_agent,
    )
    db.add(audit_log)
    await db.commit()
    await db.refresh(audit_log)
    return audit_log


@router.get("/users", response_model=UserListResponse)
async def list_users(
    filters: UserListFilters = Depends(),
    current_user: User = Depends(require_any_role("admin", "super_admin")),
    db: AsyncSession = Depends(get_db),
):
    """
    List all users with optional filters
    Admin only endpoint for user management
    """
    # Build query with filters
    query = select(User)

    if filters.status:
        query = query.where(User.status == filters.status)

    if filters.email:
        query = query.where(User.email.ilike(f"%{filters.email}%"))

    # Count total
    count_query = select(func.count()).select_from(query.subquery())
    total_result = await db.execute(count_query)
    total = total_result.scalar()

    # Apply pagination
    query = query.offset((filters.page - 1) * filters.page_size).limit(
        filters.page_size
    )
    query = query.order_by(User.created_at.desc())

    result = await db.execute(query)
    users = result.scalars().all()

    # Filter by role if specified
    if filters.role:
        filtered_users = []
        for user in users:
            await db.refresh(user, ["roles"])
            if any(role.name == filters.role for role in user.roles):
                filtered_users.append(user)
        users = filtered_users

    return UserListResponse(
        items=[UserListItem.model_validate(user) for user in users],
        total=total,
        page=filters.page,
        page_size=filters.page_size,
    )


@router.post("/users/status", response_model=UserStatusResponse)
async def update_user_status(
    status_update: UserStatusUpdate,
    current_user: User = Depends(require_any_role("admin", "super_admin")),
    db: AsyncSession = Depends(get_db),
):
    """
    Update user status (suspend/unsuspend)
    Admin only endpoint for user suspension management
    Creates audit log for compliance
    """
    # Get target user
    result = await db.execute(select(User).where(User.id == status_update.user_id))
    user = result.scalar_one_or_none()

    if not user:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND, detail="User not found"
        )

    # Validate status
    valid_statuses = ["active", "suspended", "deleted"]
    if status_update.status not in valid_statuses:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=f"Invalid status. Must be one of: {', '.join(valid_statuses)}",
        )

    # Update status
    old_status = user.status
    user.status = status_update.status
    user.updated_at = datetime.utcnow()

    await db.commit()
    await db.refresh(user)

    # Create audit log
    action_type = (
        AuditActionType.USER_SUSPENDED
        if status_update.status == "suspended"
        else AuditActionType.USER_UNSUSPENDED
    )
    await create_audit_log(
        db=db,
        action_type=action_type,
        actor_id=current_user.id,
        description=f"Changed user status from {old_status} to {status_update.status}",
        target_user_id=user.id,
        reason=status_update.reason,
    )

    return UserStatusResponse(
        id=user.id,
        email=user.email,
        status=user.status,
        updated_at=user.updated_at,
    )


@router.get("/verification/queue", response_model=VerificationQueueResponse)
async def list_verification_queue(
    page: int = Query(1, ge=1),
    page_size: int = Query(20, ge=1, le=100),
    current_user: User = Depends(require_any_role("admin", "super_admin")),
    db: AsyncSession = Depends(get_db),
):
    """
    List pending provider verification requests
    Admin only endpoint for verification queue management
    """
    # Query providers with pending verification
    query = (
        select(ProviderProfile)
        .options(selectinload(ProviderProfile.user))
        .where(ProviderProfile.verification_status == "pending")
        .order_by(ProviderProfile.created_at.asc())
    )

    # Count total
    count_query = select(func.count()).select_from(query.subquery())
    total_result = await db.execute(count_query)
    total = total_result.scalar()

    # Apply pagination
    query = query.offset((page - 1) * page_size).limit(page_size)

    result = await db.execute(query)
    providers = result.scalars().all()

    items = []
    for provider in providers:
        items.append(
            ProviderVerificationQueueItem(
                provider_id=provider.id,
                user_id=provider.user_id,
                business_name=provider.business_name,
                business_type=provider.business_type,
                verification_status=provider.verification_status,
                verification_level=provider.verification_level,
                submitted_at=provider.verification_submitted_at,
                created_at=provider.created_at,
            )
        )

    return VerificationQueueResponse(
        items=items,
        total=total,
        page=page,
        page_size=page_size,
    )


@router.post("/verification/action", response_model=VerificationActionResponse)
async def verification_action(
    action: VerificationAction,
    current_user: User = Depends(require_any_role("admin", "super_admin")),
    db: AsyncSession = Depends(get_db),
):
    """
    Perform verification action (approve, reject, revoke)
    Admin only endpoint for provider verification management
    Creates audit log for compliance
    """
    # Get provider profile
    result = await db.execute(
        select(ProviderProfile).where(ProviderProfile.id == action.provider_id)
    )
    provider = result.scalar_one_or_none()

    if not provider:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND, detail="Provider profile not found"
        )

    # Validate action
    valid_actions = ["approve", "reject", "revoke"]
    if action.action not in valid_actions:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=f"Invalid action. Must be one of: {', '.join(valid_actions)}",
        )

    # Perform action
    old_status = provider.verification_status

    if action.action == "approve":
        provider.verification_status = "verified"
        provider.verification_level = "verified"
        provider.verified_at = datetime.utcnow()
        action_type = AuditActionType.VERIFICATION_APPROVED
    elif action.action == "reject":
        provider.verification_status = "rejected"
        provider.verification_level = "unverified"
        action_type = AuditActionType.VERIFICATION_REJECTED
    else:  # revoke
        provider.verification_status = "unverified"
        provider.verification_level = "unverified"
        provider.verified_at = None
        action_type = AuditActionType.VERIFICATION_REVOKED

    provider.updated_at = datetime.utcnow()

    await db.commit()
    await db.refresh(provider)

    # Create audit log
    await create_audit_log(
        db=db,
        action_type=action_type,
        actor_id=current_user.id,
        description=f"Changed provider verification from {old_status} to {provider.verification_status}",
        target_user_id=provider.user_id,
        target_resource_type="provider_profile",
        target_resource_id=provider.id,
        reason=action.reason,
    )

    return VerificationActionResponse(
        provider_id=provider.id,
        verification_status=provider.verification_status,
        updated_at=provider.updated_at,
    )


@router.post("/content/delete")
async def delete_content(
    deletion: ContentDeletion,
    current_user: User = Depends(require_any_role("admin", "super_admin")),
    db: AsyncSession = Depends(get_db),
):
    """
    Delete content (reviews, requests, etc.)
    Admin only endpoint for content moderation
    Creates audit log for compliance
    """
    # Determine action type based on resource type
    if deletion.resource_type == "review":
        from app.core.models import Review

        result = await db.execute(
            select(Review).where(Review.id == deletion.resource_id)
        )
        resource = result.scalar_one_or_none()
        if not resource:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND, detail="Review not found"
            )
        action_type = AuditActionType.REVIEW_DELETED
        target_user_id = resource.customer_id
    elif deletion.resource_type == "request":
        from app.core.models import ServiceRequest

        result = await db.execute(
            select(ServiceRequest).where(ServiceRequest.id == deletion.resource_id)
        )
        resource = result.scalar_one_or_none()
        if not resource:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Service request not found",
            )
        action_type = AuditActionType.REQUEST_DELETED
        target_user_id = resource.customer_id
    else:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=f"Unsupported resource type: {deletion.resource_type}",
        )

    # Delete the resource
    await db.delete(resource)
    await db.commit()

    # Create audit log
    await create_audit_log(
        db=db,
        action_type=action_type,
        actor_id=current_user.id,
        description=f"Deleted {deletion.resource_type}",
        target_user_id=target_user_id,
        target_resource_type=deletion.resource_type,
        target_resource_id=deletion.resource_id,
        reason=deletion.reason,
    )

    return {"message": f"{deletion.resource_type} deleted successfully"}


@router.get("/audit-logs", response_model=AuditLogListResponse)
async def list_audit_logs(
    page: int = Query(1, ge=1),
    page_size: int = Query(20, ge=1, le=100),
    action_type: Optional[str] = Query(None),
    current_user: User = Depends(require_any_role("admin", "super_admin")),
    db: AsyncSession = Depends(get_db),
):
    """
    List audit logs with optional filters
    Admin only endpoint for audit trail visibility
    """
    # Build query
    query = select(AuditLog)

    if action_type:
        try:
            query = query.where(AuditLog.action_type == AuditActionType(action_type))
        except ValueError:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail=f"Invalid action type: {action_type}",
            )

    # Count total
    count_query = select(func.count()).select_from(query.subquery())
    total_result = await db.execute(count_query)
    total = total_result.scalar()

    # Apply pagination
    query = query.offset((page - 1) * page_size).limit(page_size)
    query = query.order_by(AuditLog.created_at.desc())

    result = await db.execute(query)
    audit_logs = result.scalars().all()

    return AuditLogListResponse(
        items=[AuditLogResponse.model_validate(log) for log in audit_logs],
        total=total,
        page=page,
        page_size=page_size,
    )
