"""
Provider Profile API endpoints
Handles CRUD operations for provider profiles, services, areas, and availability
"""

from typing import List, Optional
from fastapi import APIRouter, Depends, HTTPException, status, Query
from sqlalchemy import select, and_, or_
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.database import get_db
from app.core.models.provider import (
    ProviderProfile,
    ProviderService,
    ServiceArea,
    AvailabilityRule,
    Category,
)
from app.core.models.user import User
from app.core.schemas.provider import (
    ProviderProfileCreate,
    ProviderProfileUpdate,
    ProviderProfileResponse,
    ProviderProfilePublic,
    ProviderServiceCreate,
    ProviderServiceUpdate,
    ProviderServiceResponse,
    ServiceAreaCreate,
    ServiceAreaUpdate,
    ServiceAreaResponse,
    AvailabilityRuleCreate,
    AvailabilityRuleUpdate,
    AvailabilityRuleResponse,
)
from app.core.security.dependencies import (
    get_current_user,
    require_provider,
    require_admin,
)
from app.api.v1.endpoints.reviews import calculate_provider_reputation

# Create router for provider endpoints
router = APIRouter()


# =============================================================================
# PUBLIC PROVIDER DISCOVERY ENDPOINTS
# =============================================================================


@router.get(
    "", response_model=List[ProviderProfilePublic], status_code=status.HTTP_200_OK
)
async def list_providers(
    skip: int = 0,
    limit: int = 100,
    category_id: Optional[str] = Query(None, description="Filter by category ID"),
    city: Optional[str] = Query(None, description="Filter by city"),
    wilaya: Optional[str] = Query(None, description="Filter by wilaya"),
    verified_only: bool = Query(True, description="Only show verified providers"),
    available_only: bool = Query(True, description="Only show available providers"),
    db: AsyncSession = Depends(get_db),
):
    """
    List public provider profiles with optional filtering

    - **skip**: Number of providers to skip (pagination)
    - **limit**: Maximum number of providers to return
    - **category_id**: Filter by category ID
    - **city**: Filter by city
    - **wilaya**: Filter by wilaya
    - **verified_only**: If True, only return verified providers
    - **available_only**: If True, only return available providers

    Returns a list of public provider profiles
    """
    # Build base query
    query = select(ProviderProfile).where(ProviderProfile.is_public == True)

    # Apply filters
    if verified_only:
        query = query.where(ProviderProfile.verification_status == "approved")

    if available_only:
        query = query.where(ProviderProfile.is_available == True)

    if city:
        query = query.where(ProviderProfile.city == city)

    if wilaya:
        query = query.where(ProviderProfile.wilaya == wilaya)

    if category_id:
        # Join with provider_services to filter by category
        query = query.join(ProviderService).where(
            ProviderService.category_id == category_id
        )

    # Apply pagination
    query = query.offset(skip).limit(limit)

    # Execute query
    result = await db.execute(query)
    providers = result.scalars().all()

    # Add reputation badges to each provider
    for provider in providers:
        reputation = await calculate_provider_reputation(db, provider.user_id)
        provider.badges = reputation.badges

    return providers


@router.get(
    "/{provider_id}",
    response_model=ProviderProfilePublic,
    status_code=status.HTTP_200_OK,
)
async def get_provider_profile(
    provider_id: str,
    db: AsyncSession = Depends(get_db),
):
    """
    Get a public provider profile by ID

    - **provider_id**: UUID of the provider profile

    Returns public provider profile details or 404 if not found
    """
    # Query for provider profile
    query = select(ProviderProfile).where(
        and_(ProviderProfile.id == provider_id, ProviderProfile.is_public == True)
    )
    result = await db.execute(query)
    provider = result.scalar_one_or_none()

    # Check if provider exists
    if not provider:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND, detail="Provider profile not found"
        )

    # Calculate reputation and add badges
    reputation = await calculate_provider_reputation(db, provider.user_id)
    provider.badges = reputation.badges

    return provider


# =============================================================================
# PROVIDER PROFILE MANAGEMENT ENDPOINTS
# =============================================================================


@router.get(
    "/me/profile",
    response_model=ProviderProfileResponse,
    status_code=status.HTTP_200_OK,
)
async def get_my_provider_profile(
    current_user: User = Depends(require_provider),
    db: AsyncSession = Depends(get_db),
):
    """
    Get current user's provider profile

    Returns the provider profile for the authenticated provider user
    """
    # Query for provider profile
    query = select(ProviderProfile).where(
        ProviderProfile.user_id == str(current_user.id)
    )
    result = await db.execute(query)
    provider_profile = result.scalar_one_or_none()

    # Check if profile exists
    if not provider_profile:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Provider profile not found. Please create a profile first.",
        )

    return provider_profile


@router.post(
    "/me/profile",
    response_model=ProviderProfileResponse,
    status_code=status.HTTP_201_CREATED,
)
async def create_provider_profile(
    profile_data: ProviderProfileCreate,
    current_user: User = Depends(require_provider),
    db: AsyncSession = Depends(get_db),
):
    """
    Create a provider profile for the current user

    - **profile_data**: Provider profile creation data

    Creates a new provider profile for the authenticated provider user
    """
    # Check if profile already exists
    query = select(ProviderProfile).where(
        ProviderProfile.user_id == str(current_user.id)
    )
    result = await db.execute(query)
    existing_profile = result.scalar_one_or_none()

    if existing_profile:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Provider profile already exists",
        )

    # Create new provider profile
    new_profile = ProviderProfile(
        user_id=str(current_user.id), **profile_data.model_dump()
    )

    # Add to database
    db.add(new_profile)
    await db.commit()
    await db.refresh(new_profile)

    return new_profile


@router.put(
    "/me/profile",
    response_model=ProviderProfileResponse,
    status_code=status.HTTP_200_OK,
)
async def update_provider_profile(
    profile_data: ProviderProfileUpdate,
    current_user: User = Depends(require_provider),
    db: AsyncSession = Depends(get_db),
):
    """
    Update current user's provider profile

    - **profile_data**: Provider profile update data

    Updates the provider profile for the authenticated provider user
    """
    # Query for existing profile
    query = select(ProviderProfile).where(
        ProviderProfile.user_id == str(current_user.id)
    )
    result = await db.execute(query)
    provider_profile = result.scalar_one_or_none()

    # Check if profile exists
    if not provider_profile:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND, detail="Provider profile not found"
        )

    # Update profile fields
    update_data = profile_data.model_dump(exclude_unset=True)
    for field, value in update_data.items():
        setattr(provider_profile, field, value)

    # Commit changes
    await db.commit()
    await db.refresh(provider_profile)

    return provider_profile


# =============================================================================
# PROVIDER SERVICES ENDPOINTS
# =============================================================================


@router.get(
    "/me/services",
    response_model=List[ProviderServiceResponse],
    status_code=status.HTTP_200_OK,
)
async def list_my_services(
    current_user: User = Depends(require_provider),
    db: AsyncSession = Depends(get_db),
):
    """
    List current provider's services

    Returns all services offered by the authenticated provider
    """
    # Get provider profile
    profile_query = select(ProviderProfile).where(
        ProviderProfile.user_id == str(current_user.id)
    )
    profile_result = await db.execute(profile_query)
    provider_profile = profile_result.scalar_one_or_none()

    if not provider_profile:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND, detail="Provider profile not found"
        )

    # Query for services
    query = select(ProviderService).where(
        ProviderService.provider_id == str(provider_profile.id)
    )
    result = await db.execute(query)
    services = result.scalars().all()

    return services


@router.post(
    "/me/services",
    response_model=ProviderServiceResponse,
    status_code=status.HTTP_201_CREATED,
)
async def create_service(
    service_data: ProviderServiceCreate,
    current_user: User = Depends(require_provider),
    db: AsyncSession = Depends(get_db),
):
    """
    Create a new service for the current provider

    - **service_data**: Service creation data

    Creates a new service for the authenticated provider
    """
    # Get provider profile
    profile_query = select(ProviderProfile).where(
        ProviderProfile.user_id == str(current_user.id)
    )
    profile_result = await db.execute(profile_query)
    provider_profile = profile_result.scalar_one_or_none()

    if not provider_profile:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND, detail="Provider profile not found"
        )

    # Check if category exists
    category_query = select(Category).where(Category.id == service_data.category_id)
    category_result = await db.execute(category_query)
    category = category_result.scalar_one_or_none()

    if not category:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND, detail="Category not found"
        )

    # Check if provider already has a service for this category
    existing_query = select(ProviderService).where(
        and_(
            ProviderService.provider_id == str(provider_profile.id),
            ProviderService.category_id == service_data.category_id,
        )
    )
    existing_result = await db.execute(existing_query)
    existing_service = existing_result.scalar_one_or_none()

    if existing_service:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Provider already has a service for this category",
        )

    # Create new service
    new_service = ProviderService(
        provider_id=str(provider_profile.id), **service_data.model_dump()
    )

    # Add to database
    db.add(new_service)
    await db.commit()
    await db.refresh(new_service)

    return new_service


@router.put(
    "/me/services/{service_id}",
    response_model=ProviderServiceResponse,
    status_code=status.HTTP_200_OK,
)
async def update_service(
    service_id: str,
    service_data: ProviderServiceUpdate,
    current_user: User = Depends(require_provider),
    db: AsyncSession = Depends(get_db),
):
    """
    Update a service for the current provider

    - **service_id**: UUID of the service to update
    - **service_data**: Service update data

    Updates the service for the authenticated provider
    """
    # Get provider profile
    profile_query = select(ProviderProfile).where(
        ProviderProfile.user_id == str(current_user.id)
    )
    profile_result = await db.execute(profile_query)
    provider_profile = profile_result.scalar_one_or_none()

    if not provider_profile:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND, detail="Provider profile not found"
        )

    # Query for existing service
    query = select(ProviderService).where(
        and_(
            ProviderService.id == service_id,
            ProviderService.provider_id == str(provider_profile.id),
        )
    )
    result = await db.execute(query)
    service = result.scalar_one_or_none()

    # Check if service exists and belongs to provider
    if not service:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND, detail="Service not found"
        )

    # Update service fields
    update_data = service_data.model_dump(exclude_unset=True)
    for field, value in update_data.items():
        setattr(service, field, value)

    # Commit changes
    await db.commit()
    await db.refresh(service)

    return service


@router.delete("/me/services/{service_id}", status_code=status.HTTP_204_NO_CONTENT)
async def delete_service(
    service_id: str,
    current_user: User = Depends(require_provider),
    db: AsyncSession = Depends(get_db),
):
    """
    Delete a service for the current provider

    - **service_id**: UUID of the service to delete

    Deletes the service for the authenticated provider
    """
    # Get provider profile
    profile_query = select(ProviderProfile).where(
        ProviderProfile.user_id == str(current_user.id)
    )
    profile_result = await db.execute(profile_query)
    provider_profile = profile_result.scalar_one_or_none()

    if not provider_profile:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND, detail="Provider profile not found"
        )

    # Query for existing service
    query = select(ProviderService).where(
        and_(
            ProviderService.id == service_id,
            ProviderService.provider_id == str(provider_profile.id),
        )
    )
    result = await db.execute(query)
    service = result.scalar_one_or_none()

    # Check if service exists and belongs to provider
    if not service:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND, detail="Service not found"
        )

    # Delete service
    await db.delete(service)
    await db.commit()

    return None


# =============================================================================
# SERVICE AREAS ENDPOINTS
# =============================================================================


@router.get(
    "/me/service-areas",
    response_model=List[ServiceAreaResponse],
    status_code=status.HTTP_200_OK,
)
async def list_my_service_areas(
    current_user: User = Depends(require_provider),
    db: AsyncSession = Depends(get_db),
):
    """
    List current provider's service areas

    Returns all service areas for the authenticated provider
    """
    # Get provider profile
    profile_query = select(ProviderProfile).where(
        ProviderProfile.user_id == str(current_user.id)
    )
    profile_result = await db.execute(profile_query)
    provider_profile = profile_result.scalar_one_or_none()

    if not provider_profile:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND, detail="Provider profile not found"
        )

    # Query for service areas
    query = select(ServiceArea).where(
        ServiceArea.provider_id == str(provider_profile.id)
    )
    result = await db.execute(query)
    areas = result.scalars().all()

    return areas


@router.post(
    "/me/service-areas",
    response_model=ServiceAreaResponse,
    status_code=status.HTTP_201_CREATED,
)
async def create_service_area(
    area_data: ServiceAreaCreate,
    current_user: User = Depends(require_provider),
    db: AsyncSession = Depends(get_db),
):
    """
    Create a new service area for the current provider

    - **area_data**: Service area creation data

    Creates a new service area for the authenticated provider
    """
    # Get provider profile
    profile_query = select(ProviderProfile).where(
        ProviderProfile.user_id == str(current_user.id)
    )
    profile_result = await db.execute(profile_query)
    provider_profile = profile_result.scalar_one_or_none()

    if not provider_profile:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND, detail="Provider profile not found"
        )

    # Create new service area
    new_area = ServiceArea(
        provider_id=str(provider_profile.id), **area_data.model_dump()
    )

    # Add to database
    db.add(new_area)
    await db.commit()
    await db.refresh(new_area)

    return new_area


@router.put(
    "/me/service-areas/{area_id}",
    response_model=ServiceAreaResponse,
    status_code=status.HTTP_200_OK,
)
async def update_service_area(
    area_id: str,
    area_data: ServiceAreaUpdate,
    current_user: User = Depends(require_provider),
    db: AsyncSession = Depends(get_db),
):
    """
    Update a service area for the current provider

    - **area_id**: UUID of the service area to update
    - **area_data**: Service area update data

    Updates the service area for the authenticated provider
    """
    # Get provider profile
    profile_query = select(ProviderProfile).where(
        ProviderProfile.user_id == str(current_user.id)
    )
    profile_result = await db.execute(profile_query)
    provider_profile = profile_result.scalar_one_or_none()

    if not provider_profile:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND, detail="Provider profile not found"
        )

    # Query for existing service area
    query = select(ServiceArea).where(
        and_(
            ServiceArea.id == area_id,
            ServiceArea.provider_id == str(provider_profile.id),
        )
    )
    result = await db.execute(query)
    area = result.scalar_one_or_none()

    # Check if service area exists and belongs to provider
    if not area:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND, detail="Service area not found"
        )

    # Update service area fields
    update_data = area_data.model_dump(exclude_unset=True)
    for field, value in update_data.items():
        setattr(area, field, value)

    # Commit changes
    await db.commit()
    await db.refresh(area)

    return area


@router.delete("/me/service-areas/{area_id}", status_code=status.HTTP_204_NO_CONTENT)
async def delete_service_area(
    area_id: str,
    current_user: User = Depends(require_provider),
    db: AsyncSession = Depends(get_db),
):
    """
    Delete a service area for the current provider

    - **area_id**: UUID of the service area to delete

    Deletes the service area for the authenticated provider
    """
    # Get provider profile
    profile_query = select(ProviderProfile).where(
        ProviderProfile.user_id == str(current_user.id)
    )
    profile_result = await db.execute(profile_query)
    provider_profile = profile_result.scalar_one_or_none()

    if not provider_profile:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND, detail="Provider profile not found"
        )

    # Query for existing service area
    query = select(ServiceArea).where(
        and_(
            ServiceArea.id == area_id,
            ServiceArea.provider_id == str(provider_profile.id),
        )
    )
    result = await db.execute(query)
    area = result.scalar_one_or_none()

    # Check if service area exists and belongs to provider
    if not area:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND, detail="Service area not found"
        )

    # Delete service area
    await db.delete(area)
    await db.commit()

    return None


# =============================================================================
# AVAILABILITY RULES ENDPOINTS
# =============================================================================


@router.get(
    "/me/availability",
    response_model=List[AvailabilityRuleResponse],
    status_code=status.HTTP_200_OK,
)
async def list_my_availability(
    current_user: User = Depends(require_provider),
    db: AsyncSession = Depends(get_db),
):
    """
    List current provider's availability rules

    Returns all availability rules for the authenticated provider
    """
    # Get provider profile
    profile_query = select(ProviderProfile).where(
        ProviderProfile.user_id == str(current_user.id)
    )
    profile_result = await db.execute(profile_query)
    provider_profile = profile_result.scalar_one_or_none()

    if not provider_profile:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND, detail="Provider profile not found"
        )

    # Query for availability rules
    query = select(AvailabilityRule).where(
        AvailabilityRule.provider_id == str(provider_profile.id)
    )
    result = await db.execute(query)
    rules = result.scalars().all()

    return rules


@router.post(
    "/me/availability",
    response_model=AvailabilityRuleResponse,
    status_code=status.HTTP_201_CREATED,
)
async def create_availability_rule(
    rule_data: AvailabilityRuleCreate,
    current_user: User = Depends(require_provider),
    db: AsyncSession = Depends(get_db),
):
    """
    Create a new availability rule for the current provider

    - **rule_data**: Availability rule creation data

    Creates a new availability rule for the authenticated provider
    """
    # Get provider profile
    profile_query = select(ProviderProfile).where(
        ProviderProfile.user_id == str(current_user.id)
    )
    profile_result = await db.execute(profile_query)
    provider_profile = profile_result.scalar_one_or_none()

    if not provider_profile:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND, detail="Provider profile not found"
        )

    # Create new availability rule
    new_rule = AvailabilityRule(
        provider_id=str(provider_profile.id), **rule_data.model_dump()
    )

    # Add to database
    db.add(new_rule)
    await db.commit()
    await db.refresh(new_rule)

    return new_rule


@router.put(
    "/me/availability/{rule_id}",
    response_model=AvailabilityRuleResponse,
    status_code=status.HTTP_200_OK,
)
async def update_availability_rule(
    rule_id: str,
    rule_data: AvailabilityRuleUpdate,
    current_user: User = Depends(require_provider),
    db: AsyncSession = Depends(get_db),
):
    """
    Update an availability rule for the current provider

    - **rule_id**: UUID of the availability rule to update
    - **rule_data**: Availability rule update data

    Updates the availability rule for the authenticated provider
    """
    # Get provider profile
    profile_query = select(ProviderProfile).where(
        ProviderProfile.user_id == str(current_user.id)
    )
    profile_result = await db.execute(profile_query)
    provider_profile = profile_result.scalar_one_or_none()

    if not provider_profile:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND, detail="Provider profile not found"
        )

    # Query for existing availability rule
    query = select(AvailabilityRule).where(
        and_(
            AvailabilityRule.id == rule_id,
            AvailabilityRule.provider_id == str(provider_profile.id),
        )
    )
    result = await db.execute(query)
    rule = result.scalar_one_or_none()

    # Check if availability rule exists and belongs to provider
    if not rule:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND, detail="Availability rule not found"
        )

    # Update availability rule fields
    update_data = rule_data.model_dump(exclude_unset=True)
    for field, value in update_data.items():
        setattr(rule, field, value)

    # Commit changes
    await db.commit()
    await db.refresh(rule)

    return rule


@router.delete("/me/availability/{rule_id}", status_code=status.HTTP_204_NO_CONTENT)
async def delete_availability_rule(
    rule_id: str,
    current_user: User = Depends(require_provider),
    db: AsyncSession = Depends(get_db),
):
    """
    Delete an availability rule for the current provider

    - **rule_id**: UUID of the availability rule to delete

    Deletes the availability rule for the authenticated provider
    """
    # Get provider profile
    profile_query = select(ProviderProfile).where(
        ProviderProfile.user_id == str(current_user.id)
    )
    profile_result = await db.execute(profile_query)
    provider_profile = profile_result.scalar_one_or_none()

    if not provider_profile:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND, detail="Provider profile not found"
        )

    # Query for existing availability rule
    query = select(AvailabilityRule).where(
        and_(
            AvailabilityRule.id == rule_id,
            AvailabilityRule.provider_id == str(provider_profile.id),
        )
    )
    result = await db.execute(query)
    rule = result.scalar_one_or_none()

    # Check if availability rule exists and belongs to provider
    if not rule:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND, detail="Availability rule not found"
        )

    # Delete availability rule
    await db.delete(rule)
    await db.commit()

    return None
