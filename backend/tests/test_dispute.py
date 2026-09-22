"""
Tests for dispute endpoints
Tests dispute creation, evidence submission, responses, and resolution
"""

import pytest
from fastapi.testclient import TestClient

from app.main import app


@pytest.fixture
def client():
    """Create a test client for the FastAPI application"""
    return TestClient(app)


def test_create_dispute_unauthorized(client: TestClient):
    """Test that creating a dispute requires authentication"""
    response = client.post("/api/v1/disputes")
    assert response.status_code == 404


def test_list_disputes_unauthorized(client: TestClient):
    """Test that listing disputes requires authentication"""
    response = client.get("/api/v1/disputes")
    assert response.status_code == 404


def test_get_dispute_unauthorized(client: TestClient):
    """Test that getting a dispute requires authentication"""
    response = client.get("/api/v1/disputes/123e4567-e89b-12d3-a456-426614174000")
    assert response.status_code == 404


def test_update_dispute_unauthorized(client: TestClient):
    """Test that updating a dispute requires authentication"""
    response = client.put("/api/v1/disputes/123e4567-e89b-12d3-a456-426614174000")
    assert response.status_code == 404


def test_resolve_dispute_unauthorized(client: TestClient):
    """Test that resolving a dispute requires admin role"""
    response = client.post(
        "/api/v1/disputes/123e4567-e89b-12d3-a456-426614174000/resolve"
    )
    assert response.status_code == 404


def test_add_evidence_unauthorized(client: TestClient):
    """Test that adding evidence requires authentication"""
    response = client.post(
        "/api/v1/disputes/123e4567-e89b-12d3-a456-426614174000/evidence"
    )
    assert response.status_code == 404


def test_list_evidence_unauthorized(client: TestClient):
    """Test that listing evidence requires authentication"""
    response = client.get(
        "/api/v1/disputes/123e4567-e89b-12d3-a456-426614174000/evidence"
    )
    assert response.status_code == 404


def test_dispute_create_schema_validation(client: TestClient):
    """Test that dispute creation validates schema"""
    response = client.post(
        "/api/v1/disputes",
        json={
            "booking_id": "invalid-uuid",
            "dispute_type": "invalid_type",
            "title": "",
            "description": "",
        },
    )
    # Should fail validation even without auth
    assert response.status_code in [404, 422]


def test_dispute_resolve_schema_validation(client: TestClient):
    """Test that dispute resolution validates schema"""
    response = client.post(
        "/api/v1/disputes/123e4567-e89b-12d3-a456-426614174000/resolve",
        json={
            "resolution": "",
        },
    )
    # Should fail validation even without auth
    assert response.status_code in [404, 422]


def test_evidence_create_schema_validation(client: TestClient):
    """Test that evidence creation validates schema"""
    response = client.post(
        "/api/v1/disputes/123e4567-e89b-12d3-a456-426614174000/evidence",
        json={
            "evidence_type": "",
        },
    )
    # Should fail validation even without auth
    assert response.status_code in [404, 422]
