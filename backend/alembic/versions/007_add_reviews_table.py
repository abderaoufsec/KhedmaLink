"""Add reviews table

Revision ID: 007_add_reviews_table
Revises: 006_add_messaging_and_notifications_tables
Create Date: 2026-09-22 23:30:00.000000

"""
from alembic import op
import sqlalchemy as sa
from sqlalchemy.dialects import postgresql

# revision identifiers, used by Alembic.
revision = '007'
down_revision = '006'
branch_labels = None
depends_on = None


def upgrade():
    """
    Create reviews table with proper constraints and indexes
    """
    # Create reviews table
    op.create_table(
        'reviews',
        sa.Column(
            'id',
            postgresql.UUID(as_uuid=True),
            primary_key=True,
            server_default=sa.text('gen_random_uuid()')
        ),
        sa.Column(
            'booking_id',
            postgresql.UUID(as_uuid=True),
            sa.ForeignKey('bookings.id', ondelete='CASCADE'),
            nullable=False,
            unique=True,
            index=True
        ),
        sa.Column(
            'customer_id',
            postgresql.UUID(as_uuid=True),
            sa.ForeignKey('users.id', ondelete='CASCADE'),
            nullable=False,
            index=True
        ),
        sa.Column(
            'provider_id',
            postgresql.UUID(as_uuid=True),
            sa.ForeignKey('users.id', ondelete='CASCADE'),
            nullable=False,
            index=True
        ),
        sa.Column('rating', sa.Integer(), nullable=False, index=True),
        sa.Column('title', sa.String(255), nullable=True),
        sa.Column('comment', sa.Text(), nullable=True),
        sa.Column('professionalism', sa.Integer(), nullable=True),
        sa.Column('quality', sa.Integer(), nullable=True),
        sa.Column('timeliness', sa.Integer(), nullable=True),
        sa.Column('communication', sa.Integer(), nullable=True),
        sa.Column('value', sa.Integer(), nullable=True),
        sa.Column('provider_response', sa.Text(), nullable=True),
        sa.Column('provider_response_at', sa.DateTime(timezone=True), nullable=True),
        sa.Column(
            'created_at',
            sa.DateTime(timezone=True),
            server_default=sa.text('now()'),
            nullable=False
        ),
        sa.Column(
            'updated_at',
            sa.DateTime(timezone=True),
            server_default=sa.text('now()'),
            onupdate=sa.text('now()'),
            nullable=False
        ),
    )

    # Create index on reviews for booking_id
    op.create_index('ix_reviews_booking_id', 'reviews', ['booking_id'])

    # Create index on reviews for provider_id
    op.create_index('ix_reviews_provider_id', 'reviews', ['provider_id'])

    # Create index on reviews for rating
    op.create_index('ix_reviews_rating', 'reviews', ['rating'])


def downgrade():
    """
    Drop reviews table
    """
    # Drop indexes
    op.drop_index('ix_reviews_rating', table_name='reviews')
    op.drop_index('ix_reviews_provider_id', table_name='reviews')
    op.drop_index('ix_reviews_booking_id', table_name='reviews')

    # Drop reviews table
    op.drop_table('reviews')
