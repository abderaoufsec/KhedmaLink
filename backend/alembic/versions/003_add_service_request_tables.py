"""Add service request tables

Create tables for customer service requests and attachments

Revision ID: 003
Revises: 002
Create Date: 2025-01-22 23:30:00.000000

"""
from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa
from sqlalchemy.dialects import postgresql

# revision identifiers, used by Alembic.
revision = '003'
down_revision = '002'
branch_labels = None
depends_on = None


def upgrade() -> None:
    """
    Upgrade database schema
    Creates tables for service requests and attachments
    """
    # Create service_requests table
    op.create_table(
        'service_requests',
        sa.Column('id', postgresql.UUID(as_uuid=True), nullable=False),
        sa.Column('customer_id', postgresql.UUID(as_uuid=True), nullable=False),
        sa.Column('category_id', postgresql.UUID(as_uuid=True), nullable=False),
        sa.Column('title_ar', sa.String(length=255), nullable=False),
        sa.Column('title_fr', sa.String(length=255), nullable=False),
        sa.Column('description_ar', sa.Text(), nullable=False),
        sa.Column('description_fr', sa.Text(), nullable=False),
        sa.Column('city', sa.String(length=100), nullable=False),
        sa.Column('wilaya', sa.String(length=100), nullable=False),
        sa.Column('commune', sa.String(length=100), nullable=True),
        sa.Column('address', sa.String(length=500), nullable=True),
        sa.Column('latitude', sa.Float(), nullable=True),
        sa.Column('longitude', sa.Float(), nullable=True),
        sa.Column('preferred_date', sa.DateTime(timezone=True), nullable=True),
        sa.Column('preferred_time_start', sa.String(length=10), nullable=True),
        sa.Column('preferred_time_end', sa.String(length=10), nullable=True),
        sa.Column('is_flexible', sa.Boolean(), nullable=False),
        sa.Column('budget_min', sa.Float(), nullable=True),
        sa.Column('budget_max', sa.Float(), nullable=True),
        sa.Column('currency', sa.String(length=3), nullable=False),
        sa.Column('status', sa.String(length=20), nullable=False),
        sa.Column('urgency', sa.String(length=20), nullable=False),
        sa.Column('is_public', sa.Boolean(), nullable=False),
        sa.Column('created_at', sa.DateTime(timezone=True), server_default=sa.text('now()'), nullable=False),
        sa.Column('updated_at', sa.DateTime(timezone=True), nullable=True),
        sa.Column('closed_at', sa.DateTime(timezone=True), nullable=True),
        sa.PrimaryKeyConstraint('pk_service_requests'),
        sa.ForeignKeyConstraint(['customer_id'], 'users', ondelete='CASCADE'),
        sa.ForeignKeyConstraint(['category_id'], 'categories', ondelete='RESTRICT')
    )
    op.create_index('ix_service_requests_id', 'service_requests', ['id'])
    op.create_index('ix_service_requests_customer_id', 'service_requests', ['customer_id'])
    op.create_index('ix_service_requests_category_id', 'service_requests', ['category_id'])
    op.create_index('ix_service_requests_title_ar', 'service_requests', ['title_ar'])
    op.create_index('ix_service_requests_title_fr', 'service_requests', ['title_fr'])
    op.create_index('ix_service_requests_city', 'service_requests', ['city'])
    op.create_index('ix_service_requests_wilaya', 'service_requests', ['wilaya'])
    op.create_index('ix_service_requests_commune', 'service_requests', ['commune'])
    op.create_index('ix_service_requests_status', 'service_requests', ['status'])

    # Create request_attachments table
    op.create_table(
        'request_attachments',
        sa.Column('id', postgresql.UUID(as_uuid=True), nullable=False),
        sa.Column('request_id', postgresql.UUID(as_uuid=True), nullable=False),
        sa.Column('file_url', sa.String(length=500), nullable=False),
        sa.Column('file_name', sa.String(length=255), nullable=False),
        sa.Column('file_type', sa.String(length=100), nullable=False),
        sa.Column('file_size', sa.Integer(), nullable=False),
        sa.Column('thumbnail_url', sa.String(length=500), nullable=True),
        sa.Column('attachment_type', sa.String(length=20), nullable=False),
        sa.Column('uploaded_by', postgresql.UUID(as_uuid=True), nullable=True),
        sa.Column('upload_status', sa.String(length=20), nullable=False),
        sa.Column('created_at', sa.DateTime(timezone=True), server_default=sa.text('now()'), nullable=False),
        sa.PrimaryKeyConstraint('pk_request_attachments'),
        sa.ForeignKeyConstraint(['request_id'], 'service_requests', ondelete='CASCADE'),
        sa.ForeignKeyConstraint(['uploaded_by'], 'users', ondelete='SET NULL')
    )
    op.create_index('ix_request_attachments_id', 'request_attachments', ['id'])
    op.create_index('ix_request_attachments_request_id', 'request_attachments', ['request_id'])


def downgrade() -> None:
    """
    Downgrade database schema
    Drops all tables created in the upgrade
    """
    # Drop tables in reverse order of creation
    op.drop_table('request_attachments')
    op.drop_table('service_requests')
