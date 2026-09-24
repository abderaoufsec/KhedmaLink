"""Add disputes and dispute evidence tables

Revision ID: 009_add_disputes_table
Revises: 008_add_audit_logs_table
Create Date: 2026-09-22 23:55:00.000000

"""
from alembic import op
import sqlalchemy as sa
from sqlalchemy.dialects import postgresql

# revision identifiers, used by Alembic.
revision = '009'
down_revision = '008'
branch_labels = None
depends_on = None


def upgrade():
    """
    Create disputes and dispute_evidence tables for dispute resolution
    """
    # Create disputes table
    op.create_table(
        'disputes',
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
            'raised_by',
            postgresql.UUID(as_uuid=True),
            sa.ForeignKey('users.id', ondelete='SET NULL'),
            nullable=False,
            index=True
        ),
        sa.Column(
            'dispute_type',
            sa.Enum(
                'service_quality',
                'payment_issue',
                'communication',
                'damage',
                'safety',
                'other',
                name='disputetype'
            ),
            nullable=False
        ),
        sa.Column(
            'status',
            sa.Enum('open', 'investigating', 'resolved', 'closed', name='disputestatus'),
            nullable=False,
            server_default='open',
            index=True
        ),
        sa.Column('title', sa.String(255), nullable=False),
        sa.Column('description', sa.Text(), nullable=False),
        sa.Column('resolution', sa.Text(), nullable=True),
        sa.Column(
            'resolved_by',
            postgresql.UUID(as_uuid=True),
            sa.ForeignKey('users.id', ondelete='SET NULL'),
            nullable=True
        ),
        sa.Column('resolved_at', sa.DateTime(timezone=True), nullable=True),
        sa.Column(
            'created_at',
            sa.DateTime(timezone=True),
            server_default=sa.text('now()'),
            nullable=False,
            index=True
        ),
        sa.Column(
            'updated_at',
            sa.DateTime(timezone=True),
            server_default=sa.text('now()'),
            onupdate=sa.text('now()'),
            nullable=False
        ),
    )

    # Create index on disputes for status
    op.create_index('ix_disputes_status', 'disputes', ['status'])

    # Create index on disputes for created_at
    op.create_index('ix_disputes_created_at', 'disputes', ['created_at'])

    # Create dispute_evidence table
    op.create_table(
        'dispute_evidence',
        sa.Column(
            'id',
            postgresql.UUID(as_uuid=True),
            primary_key=True,
            server_default=sa.text('gen_random_uuid()')
        ),
        sa.Column(
            'dispute_id',
            postgresql.UUID(as_uuid=True),
            sa.ForeignKey('disputes.id', ondelete='CASCADE'),
            nullable=False,
            index=True
        ),
        sa.Column(
            'submitted_by',
            postgresql.UUID(as_uuid=True),
            sa.ForeignKey('users.id', ondelete='SET NULL'),
            nullable=False,
            index=True
        ),
        sa.Column('evidence_type', sa.String(50), nullable=False),
        sa.Column('file_url', sa.String(500), nullable=True),
        sa.Column('file_name', sa.String(255), nullable=True),
        sa.Column('file_size', sa.String(50), nullable=True),
        sa.Column('mime_type', sa.String(100), nullable=True),
        sa.Column('description', sa.Text(), nullable=True),
        sa.Column(
            'created_at',
            sa.DateTime(timezone=True),
            server_default=sa.text('now()'),
            nullable=False
        ),
    )

    # Create index on dispute_evidence for dispute_id
    op.create_index('ix_dispute_evidence_dispute_id', 'dispute_evidence', ['dispute_id'])


def downgrade():
    """
    Drop disputes and dispute_evidence tables
    """
    # Drop indexes
    op.drop_index('ix_dispute_evidence_dispute_id', table_name='dispute_evidence')
    op.drop_index('ix_disputes_created_at', table_name='disputes')
    op.drop_index('ix_disputes_status', table_name='disputes')

    # Drop tables
    op.drop_table('dispute_evidence')
    op.drop_table('disputes')
