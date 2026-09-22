"""
Alembic Environment Configuration
Defines the database connection and migration context for Alembic
"""

from logging.config import fileConfig
from sqlalchemy import engine_from_config
from sqlalchemy import pool
from sqlalchemy.ext.asyncio import async_engine_from_config
from sqlalchemy.orm import sessionmaker
from sqlalchemy.orm import declarative_base

from alembic import context

# Import database configuration
import sys
import os
sys.path.append(os.path.dirname(os.path.dirname(__file__)))

from app.core.config import settings
from app.core.database import Base

# Alembic Config object
config = context.config

# Interpret the config file for Python logging
if config.config_file_name is not None:
    fileConfig(config.config_file_name)

# Add your model's MetaData object here for 'autogenerate' support
target_metadata = Base.metadata

# =============================================================================
# DATABASE CONNECTION SETUP
# =============================================================================

def get_database_url():
    """
    Get the database URL from settings
    This is used by Alembic to connect to the database
    """
    return settings.get_database_url()


def run_migrations_offline() -> None:
    """
    Run migrations in 'offline' mode
    This configures the context with just a URL and not an Engine.
    """
    url = get_database_url()
    context.configure(
        url=url,
        target_metadata=target_metadata,
        literal_binds=True,
        dialect_opts={"paramstyle": "named"},
    )

    with context.begin_transaction():
        context.run_migrations()


def do_run_migrations(connection):
    """
    Run migrations in online mode
    This is called when the migration environment is activated
    """
    context.configure(connection=connection, target_metadata=target_metadata)

    with context.begin_transaction():
        context.run_migrations()


async def run_async_migrations():
    """
    Run migrations in async mode
    This is used when the database connection is async
    """
    connectable = async_engine_from_config(
        {"sqlalchemy.url": get_database_url()},
        prefix="sqlalchemy.",
        poolclass=pool.NullPool,
    )

    async with connectable.connect() as connection:
        await connection.run_sync(do_run_migrations)

    await connectable.dispose()


def run_migrations_online() -> None:
    """
    Run migrations in 'online' mode
    In this scenario we need to create an Engine and associate a connection
    with the context.
    """
    # For async support, we need to use async migrations
    import asyncio
    
    asyncio.run(run_async_migrations())


if context.is_offline_mode():
    run_migrations_offline()
else:
    run_migrations_online()
