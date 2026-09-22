"""Initial migration

Create initial database tables for users, roles, and user-role relationships

Revision ID: 001
Revises: 
Create Date: 2025-01-22 22:00:00.000000

"""
from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa
from sqlalchemy.dialects import postgresql

# revision identifiers, used by Alembic.
revision: '001'
down_revision = None
branch_labels = None
depends_on = None


def upgrade() -> None:
    """
    Upgrade database schema
    Creates the initial tables for users, roles, and user-role relationships
    """
    # Create roles table
    op.create_table(
        'roles',
        sa.Column('id', postgresql.UUID(as_uuid=True), nullable=False),
        sa.Column('name', sa.String(length=50), nullable=False),
        sa.Column('description', sa.String(length=255), nullable=True),
        sa.Column('created_at', sa.DateTime(timezone=True), server_default=sa.text('now()'), nullable=False),
        sa.Column('updated_at', sa.DateTime(timezone=True), nullable=True),
        sa.PrimaryKeyConstraint('pk_roles'),
        sa.UniqueConstraint('uq_roles_name')
    )
    op.create_index('ix_roles_id', 'roles', ['id'])
    op.create_index('ix_roles_name', 'roles', ['name'])

    # Create users table
    op.create_table(
        'users',
        sa.Column('id', postgresql.UUID(as_uuid=True), nullable=False),
        sa.Column('email', sa.String(length=255), nullable=False),
        sa.Column('full_name', sa.String(length=255), nullable=True),
        sa.Column('phone', sa.String(length=20), nullable=True),
        sa.Column('hashed_password', sa.String(length=255), nullable=False),
        sa.Column('is_active', sa.Boolean(), nullable=False),
        sa.Column('is_verified', sa.Boolean(), nullable=False),
        sa.Column('status', sa.String(length=20), nullable=False),
        sa.Column('created_at', sa.DateTime(timezone=True), server_default=sa.text('now()'), nullable=False),
        sa.Column('updated_at', sa.DateTime(timezone=True), nullable=True),
        sa.Column('last_login', sa.DateTime(timezone=True), nullable=True),
        sa.PrimaryKeyConstraint('pk_users'),
        sa.UniqueConstraint('uq_users_email'),
        sa.UniqueConstraint('uq_users_phone')
    )
    op.create_index('ix_users_id', 'users', ['id'])
    op.create_index('ix_users_email', 'users', ['email'])
    op.create_index('ix_users_phone', 'users', ['phone'])

    # Create user_roles association table
    op.create_table(
        'user_roles',
        sa.Column('user_id', postgresql.UUID(as_uuid=True), nullable=False),
        sa.Column('role_id', postgresql.UUID(as_uuid=True), nullable=False),
        sa.ForeignKeyConstraint(['user_id'], 'users', ondelete='CASCADE'),
        sa.ForeignKeyConstraint(['role_id'], 'roles', ondelete='CASCADE'),
        sa.PrimaryKeyConstraint('pk_user_roles', 'user_id', 'role_id')
    )

    # Create user_role_history table for audit trail
    op.create_table(
        'user_role_history',
        sa.Column('id', postgresql.UUID(as_uuid=True), nullable=False),
        sa.Column('user_id', postgresql.UUID(as_uuid=True), nullable=False),
        sa.Column('role_id', postgresql.UUID(as_uuid=True), nullable=False),
        sa.Column('action', sa.String(length=20), nullable=False),
        sa.Column('performed_by', postgresql.UUID(as_uuid=True), nullable=True),
        sa.Column('created_at', sa.DateTime(timezone=True), server_default=sa.text('now()'), nullable=False),
        sa.PrimaryKeyConstraint('pk_user_role_history'),
        sa.ForeignKeyConstraint(['user_id'], 'users', ondelete='CASCADE'),
        sa.ForeignKeyConstraint(['role_id'], 'roles', ondelete='CASCADE'),
        sa.ForeignKeyConstraint(['performed_by'], 'users')
    )
    op.create_index('ix_user_role_history_id', 'user_role_history', ['id'])

    # Insert default roles
    op.execute(
        sa.insert(
            sa.table('roles')
        ).values(
            [
                {'name': 'customer', 'description': 'Regular customer role'},
                {'name': 'provider', 'description': 'Service provider role'},
                {'name': 'admin', 'description': 'Administrator role'},
                {'name': 'super_admin', 'description': 'Super administrator role'},
            ]
        )
    )


def downgrade() -> None:
    """
    Downgrade database schema
    Drops all tables created in the upgrade
    """
    # Drop tables in reverse order of creation
    op.drop_table('user_role_history')
    op.drop_table('user_roles')
    op.drop_table('users')
    op.drop_table('roles')
