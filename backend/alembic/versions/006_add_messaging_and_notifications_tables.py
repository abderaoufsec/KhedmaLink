"""Add messaging and notifications tables

Revision ID: 006_add_messaging_and_notifications_tables
Revises: 005_add_booking_tables
Create Date: 2026-09-22 23:00:00.000000

"""
from alembic import op
import sqlalchemy as sa
from sqlalchemy.dialects import postgresql

# revision identifiers, used by Alembic.
revision = '006'
down_revision = '005'
branch_labels = None
depends_on = None


def upgrade():
    """
    Create messages, message_attachments, and notifications tables with proper constraints and indexes
    """
    # Create message_type enum type
    message_type_enum = postgresql.ENUM(
        'text', 'image', 'system',
        name='message_type',
        create_type=True
    )
    message_type_enum.create(op.get_bind())

    # Create upload_status enum type
    upload_status_enum = postgresql.ENUM(
        'pending', 'uploaded', 'failed',
        name='upload_status',
        create_type=True
    )
    upload_status_enum.create(op.get_bind())

    # Create notification_type enum type
    notification_type_enum = postgresql.ENUM(
        'quote_received', 'quote_accepted', 'booking_created', 'booking_scheduled',
        'booking_started', 'booking_completed', 'booking_cancelled', 'message_received',
        name='notification_type',
        create_type=True
    )
    notification_type_enum.create(op.get_bind())

    # Create messages table
    op.create_table(
        'messages',
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
            'sender_id',
            postgresql.UUID(as_uuid=True),
            sa.ForeignKey('users.id', ondelete='CASCADE'),
            nullable=False,
            index=True
        ),
        sa.Column('content', sa.Text(), nullable=False),
        sa.Column(
            'message_type',
            message_type_enum,
            nullable=False,
            server_default='text'
        ),
        sa.Column('is_read', sa.Boolean(), nullable=False, server_default='false', index=True),
        sa.Column('read_at', sa.DateTime(timezone=True), nullable=True),
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

    # Create index on messages for booking_id
    op.create_index('ix_messages_booking_id', 'messages', ['booking_id'])

    # Create message_attachments table
    op.create_table(
        'message_attachments',
        sa.Column(
            'id',
            postgresql.UUID(as_uuid=True),
            primary_key=True,
            server_default=sa.text('gen_random_uuid()')
        ),
        sa.Column(
            'message_id',
            postgresql.UUID(as_uuid=True),
            sa.ForeignKey('messages.id', ondelete='CASCADE'),
            nullable=False,
            index=True
        ),
        sa.Column('file_name', sa.String(255), nullable=False),
        sa.Column('file_url', sa.Text(), nullable=False),
        sa.Column('file_size', sa.Integer(), nullable=False),
        sa.Column('file_type', sa.String(100), nullable=False),
        sa.Column(
            'upload_status',
            upload_status_enum,
            nullable=False,
            server_default='pending'
        ),
        sa.Column(
            'created_at',
            sa.DateTime(timezone=True),
            server_default=sa.text('now()'),
            nullable=False
        ),
    )

    # Create index on message_attachments for message_id
    op.create_index('ix_message_attachments_message_id', 'message_attachments', ['message_id'])

    # Create notifications table
    op.create_table(
        'notifications',
        sa.Column(
            'id',
            postgresql.UUID(as_uuid=True),
            primary_key=True,
            server_default=sa.text('gen_random_uuid()')
        ),
        sa.Column(
            'user_id',
            postgresql.UUID(as_uuid=True),
            sa.ForeignKey('users.id', ondelete='CASCADE'),
            nullable=False,
            index=True
        ),
        sa.Column(
            'notification_type',
            notification_type_enum,
            nullable=False
        ),
        sa.Column('title_ar', sa.String(255), nullable=False),
        sa.Column('title_fr', sa.String(255), nullable=False),
        sa.Column('body_ar', sa.Text(), nullable=True),
        sa.Column('body_fr', sa.Text(), nullable=True),
        sa.Column('entity_type', sa.String(50), nullable=True),
        sa.Column('entity_id', postgresql.UUID(as_uuid=True), nullable=True),
        sa.Column('is_read', sa.Boolean(), nullable=False, server_default='false', index=True),
        sa.Column('read_at', sa.DateTime(timezone=True), nullable=True),
        sa.Column(
            'created_at',
            sa.DateTime(timezone=True),
            server_default=sa.text('now()'),
            nullable=False
        ),
    )

    # Create index on notifications for user_id
    op.create_index('ix_notifications_user_id', 'notifications', ['user_id'])

    # Create index on notifications for is_read
    op.create_index('ix_notifications_is_read', 'notifications', ['is_read'])


def downgrade():
    """
    Drop messaging and notifications tables and enum types
    """
    # Drop notifications table
    op.drop_index('ix_notifications_is_read', table_name='notifications')
    op.drop_index('ix_notifications_user_id', table_name='notifications')
    op.drop_table('notifications')

    # Drop message_attachments table
    op.drop_index('ix_message_attachments_message_id', table_name='message_attachments')
    op.drop_table('message_attachments')

    # Drop messages table
    op.drop_index('ix_messages_booking_id', table_name='messages')
    op.drop_table('messages')

    # Drop enum types
    notification_type_enum = postgresql.ENUM(
        name='notification_type'
    )
    notification_type_enum.drop(op.get_bind())

    upload_status_enum = postgresql.ENUM(
        name='upload_status'
    )
    upload_status_enum.drop(op.get_bind())

    message_type_enum = postgresql.ENUM(
        name='message_type'
    )
    message_type_enum.drop(op.get_bind())
