"""Add audit logs table

Revision ID: 008_add_audit_logs_table
Revises: 007_add_reviews_table
Create Date: 2026-09-22 23:45:00.000000

"""
from alembic import op
import sqlalchemy as sa
from sqlalchemy.dialects import postgresql

# revision identifiers, used by Alembic.
revision = '008'
down_revision = '007'
branch_labels = None
depends_on = None


def upgrade():
    """
    Create audit_logs table for tracking admin and privileged actions
    """
    # Create audit_logs table
    op.create_table(
        'audit_logs',
        sa.Column(
            'id',
            postgresql.UUID(as_uuid=True),
            primary_key=True,
            server_default=sa.text('gen_random_uuid()')
        ),
        sa.Column(
            'action_type',
            sa.Enum(
                'verification_approved',
                'verification_rejected',
                'verification_revoked',
                'user_suspended',
                'user_unsuspended',
                'review_deleted',
                'request_deleted',
                'category_created',
                'category_updated',
                'category_deleted',
                'platform_setting_changed',
                'feature_flag_changed',
                'dispute_resolved',
                name='auditactiontype'
            ),
            nullable=False,
            index=True
        ),
        sa.Column(
            'actor_id',
            postgresql.UUID(as_uuid=True),
            sa.ForeignKey('users.id', ondelete='SET NULL'),
            nullable=False,
            index=True
        ),
        sa.Column(
            'target_user_id',
            postgresql.UUID(as_uuid=True),
            sa.ForeignKey('users.id', ondelete='SET NULL'),
            nullable=True,
            index=True
        ),
        sa.Column('target_resource_type', sa.String(100), nullable=True),
        sa.Column('target_resource_id', postgresql.UUID(as_uuid=True), nullable=True),
        sa.Column('description', sa.Text(), nullable=False),
        sa.Column('reason', sa.Text(), nullable=True),
        sa.Column('changes', sa.Text(), nullable=True),
        sa.Column('ip_address', sa.String(45), nullable=True),
        sa.Column('user_agent', sa.String(500), nullable=True),
        sa.Column(
            'created_at',
            sa.DateTime(timezone=True),
            server_default=sa.text('now()'),
            nullable=False,
            index=True
        ),
    )

    # Create index on audit_logs for action_type
    op.create_index('ix_audit_logs_action_type', 'audit_logs', ['action_type'])

    # Create index on audit_logs for actor_id
    op.create_index('ix_audit_logs_actor_id', 'audit_logs', ['actor_id'])

    # Create index on audit_logs for target_user_id
    op.create_index('ix_audit_logs_target_user_id', 'audit_logs', ['target_user_id'])

    # Create index on audit_logs for created_at
    op.create_index('ix_audit_logs_created_at', 'audit_logs', ['created_at'])


def downgrade():
    """
    Drop audit_logs table
    """
    # Drop indexes
    op.drop_index('ix_audit_logs_created_at', table_name='audit_logs')
    op.drop_index('ix_audit_logs_target_user_id', table_name='audit_logs')
    op.drop_index('ix_audit_logs_actor_id', table_name='audit_logs')
    op.drop_index('ix_audit_logs_action_type', table_name='audit_logs')

    # Drop audit_logs table
    op.drop_table('audit_logs')
