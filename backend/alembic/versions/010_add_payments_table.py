"""Add payments, transactions, and payouts tables

Revision ID: 010_add_payments_table
Revises: 009_add_disputes_table
Create Date: 2026-09-22 23:55:00.000000

"""
from alembic import op
import sqlalchemy as sa
from sqlalchemy.dialects import postgresql

# revision identifiers, used by Alembic.
revision = '010_add_payments_table'
down_revision = '009_add_disputes_table'
branch_labels = None
depends_on = None


def upgrade():
    """
    Create payments, transactions, and payouts tables for payment abstraction
    """
    # Create payment_method enum
    payment_method_enum = postgresql.ENUM(
        'cash', 'manual', 'card',
        name='paymentmethod',
        create_type=True
    )
    payment_method_enum.create(op.get_bind())

    # Create payment_status enum
    payment_status_enum = postgresql.ENUM(
        'pending', 'processing', 'completed', 'failed', 'refunded', 'partially_refunded',
        name='paymentstatus',
        create_type=True
    )
    payment_status_enum.create(op.get_bind())

    # Create transaction_type enum
    transaction_type_enum = postgresql.ENUM(
        'capture', 'refund', 'payout',
        name='transactiontype',
        create_type=True
    )
    transaction_type_enum.create(op.get_bind())

    # Create payout_status enum
    payout_status_enum = postgresql.ENUM(
        'pending', 'processing', 'completed', 'failed',
        name='payoutstatus',
        create_type=True
    )
    payout_status_enum.create(op.get_bind())

    # Create payments table
    op.create_table(
        'payments',
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
        sa.Column('amount', sa.Numeric(precision=10, scale=2), nullable=False),
        sa.Column('currency', sa.String(3), nullable=False, server_default='DZD'),
        sa.Column('commission_rate', sa.Numeric(precision=5, scale=4), nullable=False),
        sa.Column('commission_amount', sa.Numeric(precision=10, scale=2), nullable=False),
        sa.Column('provider_amount', sa.Numeric(precision=10, scale=2), nullable=False),
        sa.Column(
            'payment_method',
            payment_method_enum,
            nullable=False,
            server_default='cash'
        ),
        sa.Column(
            'status',
            payment_status_enum,
            nullable=False,
            server_default='pending',
            index=True
        ),
        sa.Column('external_payment_id', sa.String(255), nullable=True),
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
        sa.Column('completed_at', sa.DateTime(timezone=True), nullable=True),
    )

    # Create index on payments for status
    op.create_index('ix_payments_status', 'payments', ['status'])

    # Create index on payments for created_at
    op.create_index('ix_payments_created_at', 'payments', ['created_at'])

    # Create transactions table
    op.create_table(
        'transactions',
        sa.Column(
            'id',
            postgresql.UUID(as_uuid=True),
            primary_key=True,
            server_default=sa.text('gen_random_uuid()')
        ),
        sa.Column(
            'payment_id',
            postgresql.UUID(as_uuid=True),
            sa.ForeignKey('payments.id', ondelete='CASCADE'),
            nullable=False,
            index=True
        ),
        sa.Column(
            'transaction_type',
            transaction_type_enum,
            nullable=False
        ),
        sa.Column('amount', sa.Numeric(precision=10, scale=2), nullable=False),
        sa.Column('currency', sa.String(3), nullable=False, server_default='DZD'),
        sa.Column('external_transaction_id', sa.String(255), nullable=True),
        sa.Column('metadata', sa.Text(), nullable=True),
        sa.Column(
            'created_at',
            sa.DateTime(timezone=True),
            server_default=sa.text('now()'),
            nullable=False
        ),
    )

    # Create index on transactions for payment_id
    op.create_index('ix_transactions_payment_id', 'transactions', ['payment_id'])

    # Create payouts table
    op.create_table(
        'payouts',
        sa.Column(
            'id',
            postgresql.UUID(as_uuid=True),
            primary_key=True,
            server_default=sa.text('gen_random_uuid()')
        ),
        sa.Column(
            'payment_id',
            postgresql.UUID(as_uuid=True),
            sa.ForeignKey('payments.id', ondelete='CASCADE'),
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
        sa.Column('amount', sa.Numeric(precision=10, scale=2), nullable=False),
        sa.Column('currency', sa.String(3), nullable=False, server_default='DZD'),
        sa.Column('payout_method', sa.String(50), nullable=False, server_default='cash'),
        sa.Column(
            'status',
            payout_status_enum,
            nullable=False,
            server_default='pending',
            index=True
        ),
        sa.Column('external_payout_id', sa.String(255), nullable=True),
        sa.Column('notes', sa.Text(), nullable=True),
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
        sa.Column('completed_at', sa.DateTime(timezone=True), nullable=True),
    )

    # Create index on payouts for status
    op.create_index('ix_payouts_status', 'payouts', ['status'])

    # Create index on payouts for created_at
    op.create_index('ix_payouts_created_at', 'payouts', ['created_at'])


def downgrade():
    """
    Drop payments, transactions, and payouts tables
    """
    # Drop indexes
    op.drop_index('ix_payouts_created_at', table_name='payouts')
    op.drop_index('ix_payouts_status', table_name='payouts')
    op.drop_index('ix_transactions_payment_id', table_name='transactions')
    op.drop_index('ix_payments_created_at', table_name='payments')
    op.drop_index('ix_payments_status', table_name='payments')

    # Drop tables
    op.drop_table('payouts')
    op.drop_table('transactions')
    op.drop_table('payments')

    # Drop enums
    postgresql.ENUM(name='payoutstatus').drop(op.get_bind())
    postgresql.ENUM(name='transactiontype').drop(op.get_bind())
    postgresql.ENUM(name='paymentstatus').drop(op.get_bind())
    postgresql.ENUM(name='paymentmethod').drop(op.get_bind())
