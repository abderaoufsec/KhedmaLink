"""Add quote and request match tables

Create tables for provider quotes and request matching

Revision ID: 004
Revises: 003
Create Date: 2025-01-22 23:45:00.000000

"""
from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa
from sqlalchemy.dialects import postgresql

# revision identifiers, used by Alembic.
revision = '004'
down_revision = '003'
branch_labels = None
depends_on = None


def upgrade() -> None:
    """
    Upgrade database schema
    Creates tables for quotes and request matches
    """
    # Create quotes table
    op.create_table(
        'quotes',
        sa.Column('id', postgresql.UUID(as_uuid=True), nullable=False),
        sa.Column('request_id', postgresql.UUID(as_uuid=True), nullable=False),
        sa.Column('provider_id', postgresql.UUID(as_uuid=True), nullable=False),
        sa.Column('description', sa.Text(), nullable=True),
        sa.Column('estimated_price', sa.Float(), nullable=False),
        sa.Column('currency', sa.String(length=3), nullable=False),
        sa.Column('estimated_duration', sa.Integer(), nullable=True),
        sa.Column('estimated_duration_unit', sa.String(length=20), nullable=True),
        sa.Column('available_date', sa.DateTime(timezone=True), nullable=True),
        sa.Column('available_time_start', sa.String(length=10), nullable=True),
        sa.Column('available_time_end', sa.String(length=10), nullable=True),
        sa.Column('status', sa.String(length=20), nullable=False),
        sa.Column('rejection_reason', sa.Text(), nullable=True),
        sa.Column('rejected_at', sa.DateTime(timezone=True), nullable=True),
        sa.Column('created_at', sa.DateTime(timezone=True), server_default=sa.text('now()'), nullable=False),
        sa.Column('updated_at', sa.DateTime(timezone=True), nullable=True),
        sa.Column('submitted_at', sa.DateTime(timezone=True), nullable=True),
        sa.Column('accepted_at', sa.DateTime(timezone=True), nullable=True),
        sa.PrimaryKeyConstraint('pk_quotes'),
        sa.ForeignKeyConstraint(['request_id'], 'service_requests', ondelete='CASCADE'),
        sa.ForeignKeyConstraint(['provider_id'], 'users', ondelete='CASCADE')
    )
    op.create_index('ix_quotes_id', 'quotes', ['id'])
    op.create_index('ix_quotes_request_id', 'quotes', ['request_id'])
    op.create_index('ix_quotes_provider_id', 'quotes', ['provider_id'])
    op.create_index('ix_quotes_status', 'quotes', ['status'])

    # Create request_matches table
    op.create_table(
        'request_matches',
        sa.Column('id', postgresql.UUID(as_uuid=True), nullable=False),
        sa.Column('request_id', postgresql.UUID(as_uuid=True), nullable=False),
        sa.Column('provider_id', postgresql.UUID(as_uuid=True), nullable=False),
        sa.Column('match_score', sa.Float(), nullable=True),
        sa.Column('eligibility_reason', sa.Text(), nullable=True),
        sa.Column('status', sa.String(length=20), nullable=False),
        sa.Column('created_at', sa.DateTime(timezone=True), server_default=sa.text('now()'), nullable=False),
        sa.Column('updated_at', sa.DateTime(timezone=True), nullable=True),
        sa.PrimaryKeyConstraint('pk_request_matches'),
        sa.ForeignKeyConstraint(['request_id'], 'service_requests', ondelete='CASCADE'),
        sa.ForeignKeyConstraint(['provider_id'], 'users', ondelete='CASCADE')
    )
    op.create_index('ix_request_matches_id', 'request_matches', ['id'])
    op.create_index('ix_request_matches_request_id', 'request_matches', ['request_id'])
    op.create_index('ix_request_matches_provider_id', 'request_matches', ['provider_id'])


def downgrade() -> None:
    """
    Downgrade database schema
    Drops all tables created in the upgrade
    """
    # Drop tables in reverse order of creation
    op.drop_table('request_matches')
    op.drop_table('quotes')
