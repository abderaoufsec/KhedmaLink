"""
Database initialization script
Creates all database tables and seeds default data
"""

import asyncio
from sqlalchemy import select
from app.core.database import engine, Base, AsyncSessionLocal
import app.core.models  # noqa: F401 - registers every model with Base.metadata
from app.core.models.user import Role
from app.core.logging import get_logger
import uuid
from datetime import datetime, timezone

logger = get_logger(__name__)


async def init_database():
    """Initialize database with all tables and seed data"""

    # Create all tables. Importing app.core.models above ensures every model,
    # including AuditLog and the provider tables, is registered on Base.metadata.
    async with engine.begin() as conn:
        await conn.run_sync(Base.metadata.create_all)
    
    logger.info("Database tables created successfully")
    
    # Seed roles
    await seed_roles()
    
    logger.info("Database initialization complete")


async def seed_roles():
    """Seed default roles into the database"""
    
    async with AsyncSessionLocal() as session:
        try:
            # Check if roles already exist
            result = await session.execute(select(Role))
            existing_roles = result.scalars().all()
            
            if existing_roles:
                logger.info(f"Roles already exist: {[role.name for role in existing_roles]}")
                return
            
            # Create default roles
            roles = [
                Role(
                    id=uuid.uuid4(),
                    name="customer",
                    description="Regular customer users",
                    updated_at=datetime.now(timezone.utc)
                ),
                Role(
                    id=uuid.uuid4(),
                    name="provider",
                    description="Service providers",
                    updated_at=datetime.now(timezone.utc)
                ),
                Role(
                    id=uuid.uuid4(),
                    name="admin",
                    description="Platform administrators",
                    updated_at=datetime.now(timezone.utc)
                ),
                Role(
                    id=uuid.uuid4(),
                    name="super_admin",
                    description="Super administrators",
                    updated_at=datetime.now(timezone.utc)
                ),
            ]
            
            for role in roles:
                session.add(role)
            
            await session.commit()
            logger.info(f"Created {len(roles)} default roles: {[role.name for role in roles]}")
            
        except Exception as e:
            await session.rollback()
            logger.error(f"Error seeding roles: {e}")
            raise


if __name__ == "__main__":
    asyncio.run(init_database())
