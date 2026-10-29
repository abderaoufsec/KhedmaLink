"""Shared pytest fixtures.

The suite must be hermetic: it should never touch a developer's PostgreSQL
instance. Point the application at a throwaway SQLite database before any app
module is imported, create the schema from the ORM metadata, and seed roles.
"""

import asyncio
import os
import tempfile
import uuid
from datetime import datetime, timezone
from pathlib import Path

TEST_DB_PATH = Path(tempfile.gettempdir()) / "khedmalink_pytest.db"
if TEST_DB_PATH.exists():
    TEST_DB_PATH.unlink()

os.environ["DATABASE_URL"] = f"sqlite+aiosqlite:///{TEST_DB_PATH.as_posix()}"

import pytest  # noqa: E402

from app.core.database import AsyncSessionLocal, Base, engine  # noqa: E402
import app.core.models  # noqa: E402,F401
from app.core.models.user import Role  # noqa: E402

ROLE_NAMES = ("customer", "provider", "admin", "super_admin")


async def _create_schema() -> None:
    async with engine.begin() as conn:
        await conn.run_sync(Base.metadata.create_all)

    async with AsyncSessionLocal() as session:
        session.add_all(
            [
                Role(
                    id=uuid.uuid4(),
                    name=name,
                    description=name.replace("_", " ").title(),
                    updated_at=datetime.now(timezone.utc),
                )
                for name in ROLE_NAMES
            ]
        )
        await session.commit()


async def _drop_schema() -> None:
    async with engine.begin() as conn:
        await conn.run_sync(Base.metadata.drop_all)
    await engine.dispose()


@pytest.fixture(scope="session", autouse=True)
def database():
    """Create the test schema and seed data once per test session."""
    asyncio.run(_create_schema())
    yield
    asyncio.run(_drop_schema())
    if TEST_DB_PATH.exists():
        TEST_DB_PATH.unlink()
