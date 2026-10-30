"""PostgreSQL integration test fixtures.

Uses a real PostgreSQL database (via Docker) for marketplace workflow tests.
"""

import asyncio
import os
import uuid
from datetime import datetime, timezone

import pytest
from fastapi.testclient import TestClient
from sqlalchemy import select, insert

# Point to PostgreSQL before importing app
os.environ["DATABASE_URL"] = os.environ.get(
    "DATABASE_URL",
    "postgresql+asyncpg://khedmalink_user@localhost:5432/khedmalink",
)

# Enable testing mode for NullPool
os.environ["TESTING"] = "1"

from app.core.database import AsyncSessionLocal, Base, engine  # noqa: E402
import app.core.models  # noqa: E402,F401
from app.core.models.user import Role, User, user_roles  # noqa: E402
from app.core.models.provider import Category  # noqa: E402
from app.core.security import get_password_hash  # noqa: E402

ROLE_NAMES = ("customer", "provider", "admin", "super_admin")


async def _create_schema() -> None:
    async with engine.begin() as conn:
        await conn.run_sync(Base.metadata.drop_all)
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

        # Seed a test category
        category = Category(
            id=uuid.uuid4(),
            name_ar="إصلاح الأجهزة",
            name_fr="Réparation d'appareils",
            description_ar="خدمات إصلاح الأجهزة",
            description_fr="Services de réparation d'appareils",
            is_active=True,
            sort_order=1,
        )
        session.add(category)
        await session.commit()


async def _drop_schema() -> None:
    async with engine.begin() as conn:
        await conn.run_sync(Base.metadata.drop_all)
    await engine.dispose()


async def _create_user(email, password, role_name, full_name=None):
    """Create a user with a specific role."""
    async with AsyncSessionLocal() as db:
        user = User(
            email=email,
            full_name=full_name or email.split("@")[0],
            hashed_password=get_password_hash(password),
            is_active=True,
            is_verified=True,
            status="active",
        )
        db.add(user)
        await db.commit()
        await db.refresh(user)

        role_result = await db.execute(select(Role).where(Role.name == role_name))
        role = role_result.scalar_one()
        await db.execute(insert(user_roles).values(user_id=user.id, role_id=role.id))
        await db.commit()
        return user


@pytest.fixture(scope="session", autouse=True)
def database():
    """Create the test schema and seed data once per test session."""
    asyncio.run(_create_schema())
    asyncio.run(
        _create_user("customer@test.com", "TestPass123", "customer", "Test Customer")
    )
    asyncio.run(
        _create_user("provider@test.com", "TestPass123", "provider", "Test Provider")
    )
    asyncio.run(_create_user("admin@test.com", "TestPass123", "admin", "Test Admin"))
    yield
    asyncio.run(_drop_schema())


@pytest.fixture
def client():
    """Create a test client for the FastAPI application."""
    from app.main import app

    return TestClient(app)


def _get_token(client, email, password):
    """Login and get access token."""
    response = client.post(
        "/api/v1/auth/login",
        json={"email": email, "password": password},
    )
    assert response.status_code == 200, f"Login failed: {response.text}"
    return response.json()["access_token"]


@pytest.fixture
def customer_token(client):
    return _get_token(client, "customer@test.com", "TestPass123")


@pytest.fixture
def provider_token(client):
    return _get_token(client, "provider@test.com", "TestPass123")


@pytest.fixture
def admin_token(client):
    return _get_token(client, "admin@test.com", "TestPass123")
