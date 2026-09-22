"""Add provider and category tables

Create tables for categories, provider profiles, services, areas, availability, and verification

Revision ID: 002
Revises: 001
Create Date: 2025-01-22 23:00:00.000000

"""
from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa
from sqlalchemy.dialects import postgresql

# revision identifiers, used by Alembic.
revision: '002'
down_revision = '001'
branch_labels = None
depends_on = '001'


def upgrade() -> None:
    """
    Upgrade database schema
    Creates tables for categories, provider profiles, services, areas, availability, and verification
    """
    # Create categories table
    op.create_table(
        'categories',
        sa.Column('id', postgresql.UUID(as_uuid=True), nullable=False),
        sa.Column('name_ar', sa.String(length=100), nullable=False),
        sa.Column('name_fr', sa.String(length=100), nullable=False),
        sa.Column('description_ar', sa.Text(), nullable=True),
        sa.Column('description_fr', sa.Text(), nullable=True),
        sa.Column('icon', sa.String(length=255), nullable=True),
        sa.Column('is_active', sa.Boolean(), nullable=False),
        sa.Column('sort_order', sa.Integer(), nullable=False),
        sa.Column('created_at', sa.DateTime(timezone=True), server_default=sa.text('now()'), nullable=False),
        sa.Column('updated_at', sa.DateTime(timezone=True), nullable=True),
        sa.PrimaryKeyConstraint('pk_categories')
    )
    op.create_index('ix_categories_id', 'categories', ['id'])
    op.create_index('ix_categories_name_ar', 'categories', ['name_ar'])
    op.create_index('ix_categories_name_fr', 'categories', ['name_fr'])
    op.create_index('ix_categories_is_active', 'categories', ['is_active'])

    # Create provider_profiles table
    op.create_table(
        'provider_profiles',
        sa.Column('id', postgresql.UUID(as_uuid=True), nullable=False),
        sa.Column('user_id', postgresql.UUID(as_uuid=True), nullable=False),
        sa.Column('business_name', sa.String(length=255), nullable=True),
        sa.Column('business_description_ar', sa.Text(), nullable=True),
        sa.Column('business_description_fr', sa.Text(), nullable=True),
        sa.Column('years_experience', sa.Integer(), nullable=True),
        sa.Column('phone_verified', sa.Boolean(), nullable=False),
        sa.Column('email_verified', sa.Boolean(), nullable=False),
        sa.Column('city', sa.String(length=100), nullable=True),
        sa.Column('wilaya', sa.String(length=100), nullable=True),
        sa.Column('address', sa.String(length=500), nullable=True),
        sa.Column('verification_status', sa.String(length=20), nullable=False),
        sa.Column('verification_rejection_reason', sa.Text(), nullable=True),
        sa.Column('is_public', sa.Boolean(), nullable=False),
        sa.Column('is_available', sa.Boolean(), nullable=False),
        sa.Column('rating_average', sa.Float(), nullable=False),
        sa.Column('rating_count', sa.Integer(), nullable=False),
        sa.Column('completed_jobs', sa.Integer(), nullable=False),
        sa.Column('created_at', sa.DateTime(timezone=True), server_default=sa.text('now()'), nullable=False),
        sa.Column('updated_at', sa.DateTime(timezone=True), nullable=True),
        sa.PrimaryKeyConstraint('pk_provider_profiles'),
        sa.UniqueConstraint('uq_provider_profiles_user_id'),
        sa.ForeignKeyConstraint(['user_id'], 'users', ondelete='CASCADE')
    )
    op.create_index('ix_provider_profiles_id', 'provider_profiles', ['id'])
    op.create_index('ix_provider_profiles_user_id', 'provider_profiles', ['user_id'])
    op.create_index('ix_provider_profiles_city', 'provider_profiles', ['city'])
    op.create_index('ix_provider_profiles_wilaya', 'provider_profiles', ['wilaya'])
    op.create_index('ix_provider_profiles_verification_status', 'provider_profiles', ['verification_status'])

    # Create provider_services table
    op.create_table(
        'provider_services',
        sa.Column('id', postgresql.UUID(as_uuid=True), nullable=False),
        sa.Column('provider_id', postgresql.UUID(as_uuid=True), nullable=False),
        sa.Column('category_id', postgresql.UUID(as_uuid=True), nullable=False),
        sa.Column('title_ar', sa.String(length=255), nullable=False),
        sa.Column('title_fr', sa.String(length=255), nullable=False),
        sa.Column('description_ar', sa.Text(), nullable=True),
        sa.Column('description_fr', sa.Text(), nullable=True),
        sa.Column('base_price', sa.Float(), nullable=True),
        sa.Column('price_unit', sa.String(length=50), nullable=True),
        sa.Column('is_active', sa.Boolean(), nullable=False),
        sa.Column('created_at', sa.DateTime(timezone=True), server_default=sa.text('now()'), nullable=False),
        sa.Column('updated_at', sa.DateTime(timezone=True), nullable=True),
        sa.PrimaryKeyConstraint('pk_provider_services'),
        sa.ForeignKeyConstraint(['provider_id'], 'provider_profiles', ondelete='CASCADE'),
        sa.ForeignKeyConstraint(['category_id'], 'categories', ondelete='CASCADE'),
        sa.UniqueConstraint('uq_provider_services_provider_category', 'provider_id', 'category_id')
    )
    op.create_index('ix_provider_services_id', 'provider_services', ['id'])
    op.create_index('ix_provider_services_provider_id', 'provider_services', ['provider_id'])
    op.create_index('ix_provider_services_category_id', 'provider_services', ['category_id'])
    op.create_index('idx_provider_category_unique', 'provider_services', ['provider_id', 'category_id'], unique=True)

    # Create service_areas table
    op.create_table(
        'service_areas',
        sa.Column('id', postgresql.UUID(as_uuid=True), nullable=False),
        sa.Column('provider_id', postgresql.UUID(as_uuid=True), nullable=False),
        sa.Column('city', sa.String(length=100), nullable=False),
        sa.Column('wilaya', sa.String(length=100), nullable=False),
        sa.Column('commune', sa.String(length=100), nullable=True),
        sa.Column('address_details', sa.String(length=500), nullable=True),
        sa.Column('latitude', sa.Float(), nullable=True),
        sa.Column('longitude', sa.Float(), nullable=True),
        sa.Column('radius_km', sa.Float(), nullable=True),
        sa.Column('is_active', sa.Boolean(), nullable=False),
        sa.Column('created_at', sa.DateTime(timezone=True), server_default=sa.text('now()'), nullable=False),
        sa.Column('updated_at', sa.DateTime(timezone=True), nullable=True),
        sa.PrimaryKeyConstraint('pk_service_areas'),
        sa.ForeignKeyConstraint(['provider_id'], 'provider_profiles', ondelete='CASCADE')
    )
    op.create_index('ix_service_areas_id', 'service_areas', ['id'])
    op.create_index('ix_service_areas_provider_id', 'service_areas', ['provider_id'])
    op.create_index('ix_service_areas_city', 'service_areas', ['city'])
    op.create_index('ix_service_areas_wilaya', 'service_areas', ['wilaya'])
    op.create_index('ix_service_areas_commune', 'service_areas', ['commune'])

    # Create availability_rules table
    op.create_table(
        'availability_rules',
        sa.Column('id', postgresql.UUID(as_uuid=True), nullable=False),
        sa.Column('provider_id', postgresql.UUID(as_uuid=True), nullable=False),
        sa.Column('day_of_week', sa.Integer(), nullable=False),
        sa.Column('start_time', sa.String(length=10), nullable=False),
        sa.Column('end_time', sa.String(length=10), nullable=False),
        sa.Column('is_active', sa.Boolean(), nullable=False),
        sa.Column('created_at', sa.DateTime(timezone=True), server_default=sa.text('now()'), nullable=False),
        sa.Column('updated_at', sa.DateTime(timezone=True), nullable=True),
        sa.PrimaryKeyConstraint('pk_availability_rules'),
        sa.ForeignKeyConstraint(['provider_id'], 'provider_profiles', ondelete='CASCADE')
    )
    op.create_index('ix_availability_rules_id', 'availability_rules', ['id'])
    op.create_index('ix_availability_rules_provider_id', 'availability_rules', ['provider_id'])
    op.create_index('ix_availability_rules_day_of_week', 'availability_rules', ['day_of_week'])

    # Create verification_cases table
    op.create_table(
        'verification_cases',
        sa.Column('id', postgresql.UUID(as_uuid=True), nullable=False),
        sa.Column('provider_id', postgresql.UUID(as_uuid=True), nullable=False),
        sa.Column('verification_type', sa.String(length=20), nullable=False),
        sa.Column('status', sa.String(length=20), nullable=False),
        sa.Column('reviewed_by', postgresql.UUID(as_uuid=True), nullable=True),
        sa.Column('reviewed_at', sa.DateTime(timezone=True), nullable=True),
        sa.Column('rejection_reason', sa.Text(), nullable=True),
        sa.Column('admin_notes', sa.Text(), nullable=True),
        sa.Column('created_at', sa.DateTime(timezone=True), server_default=sa.text('now()'), nullable=False),
        sa.Column('updated_at', sa.DateTime(timezone=True), nullable=True),
        sa.PrimaryKeyConstraint('pk_verification_cases'),
        sa.ForeignKeyConstraint(['provider_id'], 'provider_profiles', ondelete='CASCADE'),
        sa.ForeignKeyConstraint(['reviewed_by'], 'users')
    )
    op.create_index('ix_verification_cases_id', 'verification_cases', ['id'])
    op.create_index('ix_verification_cases_provider_id', 'verification_cases', ['provider_id'])
    op.create_index('ix_verification_cases_verification_type', 'verification_cases', ['verification_type'])
    op.create_index('ix_verification_cases_status', 'verification_cases', ['status'])

    # Insert initial categories
    op.execute(
        sa.insert(
            sa.table('categories')
        ).values(
            [
                {
                    'name_ar': 'إصلاح الأجهزة',
                    'name_fr': 'Réparation d\'appareils',
                    'description_ar': 'إصلاح الأجهزة المنزلية والإلكترونية',
                    'description_fr': 'Réparation d\'appareils ménagers et électroniques',
                    'is_active': True,
                    'sort_order': 1
                },
                {
                    'name_ar': 'خدمة التكييف',
                    'name_fr': 'Service de climatisation',
                    'description_ar': 'خدمة وتشخيص وصيانة أجهزة التكييف',
                    'description_fr': 'Service, diagnostic et entretien de climatisation',
                    'is_active': True,
                    'sort_order': 2
                },
                {
                    'name_ar': 'التنظيف',
                    'name_fr': 'Nettoyage',
                    'description_ar': 'خدمات التنظيف المنزلي والتجاري',
                    'description_fr': 'Services de nettoyage résidentiel et commercial',
                    'is_active': True,
                    'sort_order': 3
                },
                {
                    'name_ar': 'الصيانة العامة',
                    'name_fr': 'Maintenance générale',
                    'description_ar': 'أعمال الصيانة العامة والإصلاحات الصغيرة',
                    'description_fr': 'Travaux de maintenance générale et petites réparations',
                    'is_active': True,
                    'sort_order': 4
                },
                {
                    'name_ar': 'السباكة',
                    'name_fr': 'Plomberie',
                    'description_ar': 'أعمال السباكة البسيطة وغير الخطرة',
                    'description_fr': 'Travaux de plomberie simples et non dangereux',
                    'is_active': True,
                    'sort_order': 5
                },
            ]
        )
    )


def downgrade() -> None:
    """
    Downgrade database schema
    Drops all tables created in the upgrade
    """
    # Drop tables in reverse order of creation
    op.drop_table('verification_cases')
    op.drop_table('availability_rules')
    op.drop_table('service_areas')
    op.drop_table('provider_services')
    op.drop_table('provider_profiles')
    op.drop_table('categories')
