"""Add booking and booking events tables

Revision ID: 005_add_booking_tables
Revises: 004_add_quote_and_match_tables
Create Date: 2026-09-22 21:00:00.000000

"""
from alembic import op
import sqlalchemy as sa
from sqlalchemy.dialects import postgresql

# revision identifiers, used by Alembic.
revision = '005_add_booking_tables'
down_revision = '004_add_quote_and_match_tables'
branch_labels = None
depends_on = None


def upgrade():
    """
    Create bookings and booking_events tables with proper constraints and indexes
    """
    # Create booking_status enum type
    booking_status_enum = postgresql.ENUM(
        'draft', 'pending', 'quoted', 'accepted', 'scheduled',
        'in_progress', 'completed', 'cancelled', 'expired',
        'rejected', 'disputed',
        name='booking_status',
        create_type=True
    )
    booking_status_enum.create(op.get_bind())

    # Create booking_event_type enum type
    booking_event_type_enum = postgresql.ENUM(
        'created', 'scheduled', 'started', 'completed',
        'cancelled', 'disputed', 'status_changed',
        name='booking_event_type',
        create_type=True
    )
    booking_event_type_enum.create(op.get_bind())

    # Create bookings table
    op.create_table(
        'bookings',
        sa.Column(
            'id',
            postgresql.UUID(as_uuid=True),
            primary_key=True,
            server_default=sa.text('gen_random_uuid()')
        ),
        sa.Column(
            'request_id',
            postgresql.UUID(as_uuid=True),
            sa.ForeignKey('service_requests.id', ondelete='CASCADE'),
            nullable=False,
            index=True
        ),
        sa.Column(
            'quote_id',
            postgresql.UUID(as_uuid=True),
            sa.ForeignKey('quotes.id', ondelete='RESTRICT'),
            nullable=False,
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
        sa.Column('scheduled_date', sa.DateTime(timezone=True), nullable=True),
        sa.Column('scheduled_time_start', sa.String(10), nullable=True),
        sa.Column('scheduled_time_end', sa.String(10), nullable=True),
        sa.Column('estimated_duration', sa.Integer(), nullable=True),
        sa.Column('estimated_duration_unit', sa.String(20), nullable=True, server_default='minutes'),
        sa.Column('agreed_price', sa.Float(), nullable=False),
        sa.Column('currency', sa.String(3), nullable=False, server_default='DZD'),
        sa.Column('address', sa.String(500), nullable=True),
        sa.Column('city', sa.String(100), nullable=True),
        sa.Column('wilaya', sa.String(100), nullable=True),
        sa.Column('latitude', sa.Float(), nullable=True),
        sa.Column('longitude', sa.Float(), nullable=True),
        sa.Column(
            'status',
            booking_status_enum,
            nullable=False,
            server_default='accepted',
            index=True
        ),
        sa.Column('cancelled_at', sa.DateTime(timezone=True), nullable=True),
        sa.Column('cancelled_by', postgresql.UUID(as_uuid=True), nullable=True),
        sa.Column('cancellation_reason', sa.Text(), nullable=True),
        sa.Column('completed_at', sa.DateTime(timezone=True), nullable=True),
        sa.Column('completion_notes', sa.Text(), nullable=True),
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

    # Create index on bookings for status
    op.create_index('ix_bookings_status', 'bookings', ['status'])

    # Create booking_events table
    op.create_table(
        'booking_events',
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
            index=True
        ),
        sa.Column(
            'triggered_by',
            postgresql.UUID(as_uuid=True),
            sa.ForeignKey('users.id', ondelete='SET NULL'),
            nullable=True,
            index=True
        ),
        sa.Column(
            'event_type',
            booking_event_type_enum,
            nullable=False
        ),
        sa.Column('old_status', sa.String(20), nullable=True),
        sa.Column('new_status', sa.String(20), nullable=True),
        sa.Column('notes', sa.Text(), nullable=True),
        sa.Column('event_metadata', sa.Text(), nullable=True),
        sa.Column(
            'created_at',
            sa.DateTime(timezone=True),
            server_default=sa.text('now()'),
            nullable=False
        ),
    )

    # Create index on booking_events for booking_id
    op.create_index('ix_booking_events_booking_id', 'booking_events', ['booking_id'])


def downgrade():
    """
    Drop bookings and booking_events tables and enum types
    """
    # Drop booking_events table
    op.drop_index('ix_booking_events_booking_id', table_name='booking_events')
    op.drop_table('booking_events')

    # Drop bookings table
    op.drop_index('ix_bookings_status', table_name='bookings')
    op.drop_table('bookings')

    # Drop enum types
    booking_event_type_enum = postgresql.ENUM(
        name='booking_event_type'
    )
    booking_event_type_enum.drop(op.get_bind())

    booking_status_enum = postgresql.ENUM(
        name='booking_status'
    )
    booking_status_enum.drop(op.get_bind())
