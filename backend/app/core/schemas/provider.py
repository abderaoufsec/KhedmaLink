"""
Pydantic schemas for provider and category operations
Contains request and response models for categories, provider profiles, services, areas, and availability
"""

from typing import Optional, List
from pydantic import BaseModel, Field, field_validator, ConfigDict


# =============================================================================
# CATEGORY SCHEMAS
# =============================================================================


class CategoryBase(BaseModel):
    """
    Base schema for category operations
    Contains common fields for category requests and responses
    """

    name_ar: str = Field(..., max_length=100, description="Category name in Arabic")
    name_fr: str = Field(..., max_length=100, description="Category name in French")
    description_ar: Optional[str] = Field(
        None, description="Category description in Arabic"
    )
    description_fr: Optional[str] = Field(
        None, description="Category description in French"
    )
    icon: Optional[str] = Field(
        None, max_length=255, description="Category icon identifier or URL"
    )
    is_active: bool = Field(default=True, description="Whether the category is active")
    sort_order: int = Field(default=0, description="Display order for sorting")


class CategoryCreate(CategoryBase):
    """
    Schema for creating a new category
    Used by admin to add new service categories
    """

    pass


class CategoryUpdate(BaseModel):
    """
    Schema for updating an existing category
    All fields are optional to allow partial updates
    """

    name_ar: Optional[str] = Field(None, max_length=100)
    name_fr: Optional[str] = Field(None, max_length=100)
    description_ar: Optional[str] = None
    description_fr: Optional[str] = None
    icon: Optional[str] = Field(None, max_length=255)
    is_active: Optional[bool] = None
    sort_order: Optional[int] = None


class CategoryResponse(CategoryBase):
    """
    Schema for category response
    Returns category information including ID and timestamps
    """

    id: str = Field(..., description="Category ID")
    created_at: str = Field(..., description="Category creation timestamp")
    updated_at: Optional[str] = Field(
        None, description="Category last update timestamp"
    )

    model_config = ConfigDict(from_attributes=True)


# =============================================================================
# PROVIDER PROFILE SCHEMAS
# =============================================================================


class ProviderProfileBase(BaseModel):
    """
    Base schema for provider profile operations
    Contains common fields for provider profile requests and responses
    """

    business_name: Optional[str] = Field(
        None, max_length=255, description="Provider business name"
    )
    business_description_ar: Optional[str] = Field(
        None, description="Business description in Arabic"
    )
    business_description_fr: Optional[str] = Field(
        None, description="Business description in French"
    )
    years_experience: Optional[int] = Field(
        None, ge=0, description="Years of experience"
    )
    city: Optional[str] = Field(None, max_length=100, description="Provider city")
    wilaya: Optional[str] = Field(None, max_length=100, description="Provider wilaya")
    address: Optional[str] = Field(None, max_length=500, description="Provider address")
    is_public: bool = Field(
        default=False, description="Whether profile is visible to customers"
    )
    is_available: bool = Field(
        default=True, description="Whether provider is accepting new jobs"
    )


class ProviderProfileCreate(ProviderProfileBase):
    """
    Schema for creating a new provider profile
    Used by providers to set up their profile
    """

    pass


class ProviderProfileUpdate(BaseModel):
    """
    Schema for updating an existing provider profile
    All fields are optional to allow partial updates
    """

    business_name: Optional[str] = Field(None, max_length=255)
    business_description_ar: Optional[str] = None
    business_description_fr: Optional[str] = None
    years_experience: Optional[int] = Field(None, ge=0)
    city: Optional[str] = Field(None, max_length=100)
    wilaya: Optional[str] = Field(None, max_length=100)
    address: Optional[str] = Field(None, max_length=500)
    is_public: Optional[bool] = None
    is_available: Optional[bool] = None


class ProviderProfileResponse(ProviderProfileBase):
    """
    Schema for provider profile response
    Returns provider profile information including verification status and ratings
    """

    id: str = Field(..., description="Provider profile ID")
    user_id: str = Field(..., description="Associated user ID")
    phone_verified: bool = Field(..., description="Phone verification status")
    email_verified: bool = Field(..., description="Email verification status")
    verification_status: str = Field(..., description="Verification status")
    verification_rejection_reason: Optional[str] = Field(
        None, description="Reason for verification rejection"
    )
    rating_average: float = Field(..., description="Average rating")
    rating_count: int = Field(..., description="Number of ratings")
    completed_jobs: int = Field(..., description="Number of completed jobs")
    created_at: str = Field(..., description="Profile creation timestamp")
    updated_at: Optional[str] = Field(None, description="Profile last update timestamp")

    model_config = ConfigDict(from_attributes=True)


class ProviderProfilePublic(BaseModel):
    """
    Schema for public provider profile information
    Returns limited information visible to customers
    """

    id: str = Field(..., description="Provider profile ID")
    business_name: Optional[str] = Field(None, description="Provider business name")
    business_description_ar: Optional[str] = Field(
        None, description="Business description in Arabic"
    )
    business_description_fr: Optional[str] = Field(
        None, description="Business description in French"
    )
    years_experience: Optional[int] = Field(None, description="Years of experience")
    city: Optional[str] = Field(None, description="Provider city")
    wilaya: Optional[str] = Field(None, description="Provider wilaya")
    verification_status: str = Field(..., description="Verification status")
    rating_average: float = Field(..., description="Average rating")
    rating_count: int = Field(..., description="Number of ratings")
    completed_jobs: int = Field(..., description="Number of completed jobs")
    badges: list = Field(default_factory=list, description="Earned badges")

    model_config = ConfigDict(from_attributes=True)


# =============================================================================
# PROVIDER SERVICE SCHEMAS
# =============================================================================


class ProviderServiceBase(BaseModel):
    """
    Base schema for provider service operations
    Contains common fields for provider service requests and responses
    """

    category_id: str = Field(..., description="Category ID")
    title_ar: str = Field(..., max_length=255, description="Service title in Arabic")
    title_fr: str = Field(..., max_length=255, description="Service title in French")
    description_ar: Optional[str] = Field(
        None, description="Service description in Arabic"
    )
    description_fr: Optional[str] = Field(
        None, description="Service description in French"
    )
    base_price: Optional[float] = Field(
        None, ge=0, description="Base price for the service"
    )
    price_unit: Optional[str] = Field(
        None, max_length=50, description="Price unit (hour, job, etc.)"
    )
    is_active: bool = Field(default=True, description="Whether the service is active")


class ProviderServiceCreate(ProviderServiceBase):
    """
    Schema for creating a new provider service
    Used by providers to add services they offer
    """

    pass


class ProviderServiceUpdate(BaseModel):
    """
    Schema for updating an existing provider service
    All fields are optional to allow partial updates
    """

    title_ar: Optional[str] = Field(None, max_length=255)
    title_fr: Optional[str] = Field(None, max_length=255)
    description_ar: Optional[str] = None
    description_fr: Optional[str] = None
    base_price: Optional[float] = Field(None, ge=0)
    price_unit: Optional[str] = Field(None, max_length=50)
    is_active: Optional[bool] = None


class ProviderServiceResponse(ProviderServiceBase):
    """
    Schema for provider service response
    Returns provider service information including ID and timestamps
    """

    id: str = Field(..., description="Provider service ID")
    provider_id: str = Field(..., description="Provider profile ID")
    created_at: str = Field(..., description="Service creation timestamp")
    updated_at: Optional[str] = Field(None, description="Service last update timestamp")

    model_config = ConfigDict(from_attributes=True)


# =============================================================================
# SERVICE AREA SCHEMAS
# =============================================================================


class ServiceAreaBase(BaseModel):
    """
    Base schema for service area operations
    Contains common fields for service area requests and responses
    """

    city: str = Field(..., max_length=100, description="City name")
    wilaya: str = Field(..., max_length=100, description="Wilaya name")
    commune: Optional[str] = Field(None, max_length=100, description="Commune name")
    address_details: Optional[str] = Field(
        None, max_length=500, description="Detailed address"
    )
    latitude: Optional[float] = Field(
        None, ge=-90, le=90, description="Latitude coordinate"
    )
    longitude: Optional[float] = Field(
        None, ge=-180, le=180, description="Longitude coordinate"
    )
    radius_km: Optional[float] = Field(
        None, ge=0, description="Service radius in kilometers"
    )
    is_active: bool = Field(
        default=True, description="Whether the service area is active"
    )


class ServiceAreaCreate(ServiceAreaBase):
    """
    Schema for creating a new service area
    Used by providers to define where they offer services
    """

    pass


class ServiceAreaUpdate(BaseModel):
    """
    Schema for updating an existing service area
    All fields are optional to allow partial updates
    """

    city: Optional[str] = Field(None, max_length=100)
    wilaya: Optional[str] = Field(None, max_length=100)
    commune: Optional[str] = Field(None, max_length=100)
    address_details: Optional[str] = Field(None, max_length=500)
    latitude: Optional[float] = Field(None, ge=-90, le=90)
    longitude: Optional[float] = Field(None, ge=-180, le=180)
    radius_km: Optional[float] = Field(None, ge=0)
    is_active: Optional[bool] = None


class ServiceAreaResponse(ServiceAreaBase):
    """
    Schema for service area response
    Returns service area information including ID and timestamps
    """

    id: str = Field(..., description="Service area ID")
    provider_id: str = Field(..., description="Provider profile ID")
    created_at: str = Field(..., description="Service area creation timestamp")
    updated_at: Optional[str] = Field(
        None, description="Service area last update timestamp"
    )

    model_config = ConfigDict(from_attributes=True)


# =============================================================================
# AVAILABILITY RULE SCHEMAS
# =============================================================================


class AvailabilityRuleBase(BaseModel):
    """
    Base schema for availability rule operations
    Contains common fields for availability rule requests and responses
    """

    day_of_week: int = Field(
        ..., ge=0, le=6, description="Day of week (0=Monday, 6=Sunday)"
    )
    start_time: str = Field(..., description="Start time in HH:MM format")
    end_time: str = Field(..., description="End time in HH:MM format")
    is_active: bool = Field(
        default=True, description="Whether the availability rule is active"
    )

    @field_validator("start_time", "end_time")
    @classmethod
    def validate_time_format(cls, v: str) -> str:
        """
        Validate time format is HH:MM
        """
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


class AvailabilityRuleCreate(AvailabilityRuleBase):
    """
    Schema for creating a new availability rule
    Used by providers to define their schedule
    """

    pass


class AvailabilityRuleUpdate(BaseModel):
    """
    Schema for updating an existing availability rule
    All fields are optional to allow partial updates
    """

    day_of_week: Optional[int] = Field(None, ge=0, le=6)
    start_time: Optional[str] = None
    end_time: Optional[str] = None
    is_active: Optional[bool] = None


class AvailabilityRuleResponse(AvailabilityRuleBase):
    """
    Schema for availability rule response
    Returns availability rule information including ID and timestamps
    """

    id: str = Field(..., description="Availability rule ID")
    provider_id: str = Field(..., description="Provider profile ID")
    created_at: str = Field(..., description="Availability rule creation timestamp")
    updated_at: Optional[str] = Field(
        None, description="Availability rule last update timestamp"
    )

    model_config = ConfigDict(from_attributes=True)


# =============================================================================
# VERIFICATION CASE SCHEMAS
# =============================================================================


class VerificationCaseBase(BaseModel):
    """
    Base schema for verification case operations
    Contains common fields for verification case requests and responses
    """

    verification_type: str = Field(
        ...,
        description="Type of verification (identity, professional, address, phone, email)",
    )


class VerificationCaseCreate(VerificationCaseBase):
    """
    Schema for creating a new verification case
    Used by providers to submit verification information
    """

    pass


class VerificationCaseResponse(VerificationCaseBase):
    """
    Schema for verification case response
    Returns verification case information including status and review details
    """

    id: str = Field(..., description="Verification case ID")
    provider_id: str = Field(..., description="Provider profile ID")
    status: str = Field(..., description="Verification status")
    reviewed_by: Optional[str] = Field(
        None, description="ID of admin who reviewed the case"
    )
    reviewed_at: Optional[str] = Field(None, description="Review timestamp")
    rejection_reason: Optional[str] = Field(None, description="Reason for rejection")
    admin_notes: Optional[str] = Field(None, description="Admin notes")
    created_at: str = Field(..., description="Verification case creation timestamp")
    updated_at: Optional[str] = Field(
        None, description="Verification case last update timestamp"
    )

    model_config = ConfigDict(from_attributes=True)


class VerificationCaseAdminUpdate(BaseModel):
    """
    Schema for admin updates to verification cases
    Used by admins to approve/reject verification cases
    """

    status: str = Field(
        ..., description="New status (approved, rejected, under_review)"
    )
    rejection_reason: Optional[str] = Field(
        None, description="Reason for rejection if rejected"
    )
    admin_notes: Optional[str] = Field(None, description="Admin notes")
