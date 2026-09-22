"""
Provider and Category Database Models
Defines the database models for categories, provider profiles, services, areas, and availability
"""

import uuid
from datetime import datetime
from sqlalchemy import (
    Boolean,
    Column,
    DateTime,
    Enum,
    String,
    Text,
    Integer,
    Float,
    ForeignKey,
    func,
    Index,
)
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.orm import relationship

from app.core.database import Base


# =============================================================================
# CATEGORY MODEL
# =============================================================================


class Category(Base):
    """
    Category model for service categories
    Represents the main service categories available on the platform
    Examples: Appliance repair, AC service, Cleaning, Handyman, Plumbing
    """

    __tablename__ = "categories"

    # Primary key using UUID for security and distributed systems
    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4, index=True)

    # Category information
    name_ar = Column(String(100), nullable=False, index=True)  # Arabic name
    name_fr = Column(String(100), nullable=False, index=True)  # French name
    description_ar = Column(Text, nullable=True)  # Arabic description
    description_fr = Column(Text, nullable=True)  # French description
    icon = Column(String(255), nullable=True)  # Icon identifier or URL

    # Category status
    is_active = Column(Boolean, default=True, nullable=False, index=True)
    sort_order = Column(Integer, default=0, nullable=False)  # For display ordering

    # Timestamps
    created_at = Column(
        DateTime(timezone=True), server_default=func.now(), nullable=False
    )
    updated_at = Column(DateTime(timezone=True), onupdate=func.now(), nullable=False)

    # Relationships
    provider_services = relationship("ProviderService", back_populates="category")

    def __repr__(self) -> str:
        """String representation of the category"""
        return (
            f"<Category(id={self.id}, name_ar={self.name_ar}, name_fr={self.name_fr})>"
        )


# =============================================================================
# PROVIDER PROFILE MODEL
# =============================================================================


class ProviderProfile(Base):
    """
    Provider profile model for provider users
    Extends the User model with provider-specific information
    """

    __tablename__ = "provider_profiles"

    # Primary key using UUID
    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4, index=True)

    # Foreign key to User
    user_id = Column(
        UUID(as_uuid=True),
        ForeignKey("users.id", ondelete="CASCADE"),
        unique=True,
        nullable=False,
        index=True,
    )

    # Business information
    business_name = Column(String(255), nullable=True)
    business_description_ar = Column(Text, nullable=True)
    business_description_fr = Column(Text, nullable=True)
    years_experience = Column(Integer, nullable=True)

    # Contact information
    phone_verified = Column(Boolean, default=False, nullable=False)
    email_verified = Column(Boolean, default=False, nullable=False)

    # Location information
    city = Column(String(100), nullable=True, index=True)
    wilaya = Column(String(100), nullable=True, index=True)
    address = Column(String(500), nullable=True)

    # Verification status
    verification_status = Column(
        Enum(
            "pending",
            "submitted",
            "under_review",
            "approved",
            "rejected",
            "suspended",
            name="verification_status",
        ),
        default="pending",
        nullable=False,
        index=True,
    )
    verification_rejection_reason = Column(Text, nullable=True)

    # Profile status
    is_public = Column(Boolean, default=False, nullable=False)  # Visible to customers
    is_available = Column(Boolean, default=True, nullable=False)  # Accepting new jobs

    # Rating and reputation
    rating_average = Column(Float, default=0.0, nullable=False)
    rating_count = Column(Integer, default=0, nullable=False)
    completed_jobs = Column(Integer, default=0, nullable=False)

    # Timestamps
    created_at = Column(
        DateTime(timezone=True), server_default=func.now(), nullable=False
    )
    updated_at = Column(DateTime(timezone=True), onupdate=func.now(), nullable=False)

    # Relationships
    user = relationship("User", backref="provider_profile")
    services = relationship(
        "ProviderService", back_populates="provider", cascade="all, delete-orphan"
    )
    service_areas = relationship(
        "ServiceArea", back_populates="provider", cascade="all, delete-orphan"
    )
    availability_rules = relationship(
        "AvailabilityRule", back_populates="provider", cascade="all, delete-orphan"
    )
    verification_cases = relationship(
        "VerificationCase", back_populates="provider", cascade="all, delete-orphan"
    )

    def __repr__(self) -> str:
        """String representation of the provider profile"""
        return f"<ProviderProfile(id={self.id}, user_id={self.user_id}, business_name={self.business_name})>"


# =============================================================================
# PROVIDER SERVICE MODEL
# =============================================================================


class ProviderService(Base):
    """
    Provider service model for services offered by providers
    Links providers to categories with specific service details
    """

    __tablename__ = "provider_services"

    # Primary key using UUID
    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4, index=True)

    # Foreign keys
    provider_id = Column(
        UUID(as_uuid=True),
        ForeignKey("provider_profiles.id", ondelete="CASCADE"),
        nullable=False,
        index=True,
    )
    category_id = Column(
        UUID(as_uuid=True),
        ForeignKey("categories.id", ondelete="CASCADE"),
        nullable=False,
        index=True,
    )

    # Service information
    title_ar = Column(String(255), nullable=False)
    title_fr = Column(String(255), nullable=False)
    description_ar = Column(Text, nullable=True)
    description_fr = Column(Text, nullable=True)

    # Pricing information
    base_price = Column(Float, nullable=True)  # Minimum price
    price_unit = Column(String(50), nullable=True)  # Per hour, per job, etc.

    # Service status
    is_active = Column(Boolean, default=True, nullable=False)

    # Timestamps
    created_at = Column(
        DateTime(timezone=True), server_default=func.now(), nullable=False
    )
    updated_at = Column(DateTime(timezone=True), onupdate=func.now(), nullable=False)

    # Relationships
    provider = relationship("ProviderProfile", back_populates="services")
    category = relationship("Category", back_populates="provider_services")

    # Unique constraint: provider can only have one service per category
    __table_args__ = (
        Index(
            "idx_provider_category_unique", "provider_id", "category_id", unique=True
        ),
    )

    def __repr__(self) -> str:
        """String representation of the provider service"""
        return f"<ProviderService(id={self.id}, provider_id={self.provider_id}, category_id={self.category_id})>"


# =============================================================================
# SERVICE AREA MODEL
# =============================================================================


class ServiceArea(Base):
    """
    Service area model for geographic coverage
    Defines the areas where providers offer their services
    """

    __tablename__ = "service_areas"

    # Primary key using UUID
    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4, index=True)

    # Foreign key
    provider_id = Column(
        UUID(as_uuid=True),
        ForeignKey("provider_profiles.id", ondelete="CASCADE"),
        nullable=False,
        index=True,
    )

    # Location information
    city = Column(String(100), nullable=False, index=True)
    wilaya = Column(String(100), nullable=False, index=True)
    commune = Column(String(100), nullable=True, index=True)
    address_details = Column(String(500), nullable=True)

    # Geographic boundaries (optional for advanced filtering)
    latitude = Column(Float, nullable=True)
    longitude = Column(Float, nullable=True)
    radius_km = Column(Float, nullable=True)  # Service radius in kilometers

    # Status
    is_active = Column(Boolean, default=True, nullable=False)

    # Timestamps
    created_at = Column(
        DateTime(timezone=True), server_default=func.now(), nullable=False
    )
    updated_at = Column(DateTime(timezone=True), onupdate=func.now(), nullable=False)

    # Relationships
    provider = relationship("ProviderProfile", back_populates="service_areas")

    def __repr__(self) -> str:
        """String representation of the service area"""
        return f"<ServiceArea(id={self.id}, city={self.city}, wilaya={self.wilaya})>"


# =============================================================================
# AVAILABILITY RULE MODEL
# =============================================================================


class AvailabilityRule(Base):
    """
    Availability rule model for provider schedules
    Defines when providers are available for jobs
    """

    __tablename__ = "availability_rules"

    # Primary key using UUID
    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4, index=True)

    # Foreign key
    provider_id = Column(
        UUID(as_uuid=True),
        ForeignKey("provider_profiles.id", ondelete="CASCADE"),
        nullable=False,
        index=True,
    )

    # Schedule information
    day_of_week = Column(Integer, nullable=False, index=True)  # 0=Monday, 6=Sunday
    start_time = Column(String(10), nullable=False)  # HH:MM format
    end_time = Column(String(10), nullable=False)  # HH:MM format

    # Status
    is_active = Column(Boolean, default=True, nullable=False)

    # Timestamps
    created_at = Column(
        DateTime(timezone=True), server_default=func.now(), nullable=False
    )
    updated_at = Column(DateTime(timezone=True), onupdate=func.now(), nullable=False)

    # Relationships
    provider = relationship("ProviderProfile", back_populates="availability_rules")

    def __repr__(self) -> str:
        """String representation of the availability rule"""
        return f"<AvailabilityRule(id={self.id}, day_of_week={self.day_of_week}, start_time={self.start_time})>"


# =============================================================================
# VERIFICATION CASE MODEL
# =============================================================================


class VerificationCase(Base):
    """
    Verification case model for provider verification tracking
    Tracks the verification process for providers
    """

    __tablename__ = "verification_cases"

    # Primary key using UUID
    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4, index=True)

    # Foreign key
    provider_id = Column(
        UUID(as_uuid=True),
        ForeignKey("provider_profiles.id", ondelete="CASCADE"),
        nullable=False,
        index=True,
    )

    # Verification information
    verification_type = Column(
        Enum(
            "identity",
            "professional",
            "address",
            "phone",
            "email",
            name="verification_type",
        ),
        nullable=False,
        index=True,
    )
    status = Column(
        Enum(
            "pending",
            "submitted",
            "under_review",
            "approved",
            "rejected",
            "expired",
            name="verification_case_status",
        ),
        default="pending",
        nullable=False,
        index=True,
    )

    # Admin information
    reviewed_by = Column(UUID(as_uuid=True), ForeignKey("users.id"), nullable=True)
    reviewed_at = Column(DateTime(timezone=True), nullable=True)
    rejection_reason = Column(Text, nullable=True)
    admin_notes = Column(Text, nullable=True)

    # Timestamps
    created_at = Column(
        DateTime(timezone=True), server_default=func.now(), nullable=False
    )
    updated_at = Column(DateTime(timezone=True), onupdate=func.now(), nullable=False)

    # Relationships
    provider = relationship("ProviderProfile", back_populates="verification_cases")

    def __repr__(self) -> str:
        """String representation of the verification case"""
        return f"<VerificationCase(id={self.id}, type={self.verification_type}, status={self.status})>"
