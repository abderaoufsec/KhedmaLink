"""
API endpoint tests
Tests health check endpoints and request ID middleware
"""

import pytest
from fastapi.testclient import TestClient
from app.main import app


@pytest.fixture
def client():
    """
    Create a test client for the FastAPI application
    """
    return TestClient(app)


def test_health_check(client):
    """
    Test the health check endpoint
    """
    response = client.get("/health")
    assert response.status_code == 200
    data = response.json()
    assert data["status"] == "healthy"
    assert data["app_name"] == "KhedmaLink"
    assert data["version"] == "0.1.0"
    assert data["environment"] == "development"


def test_api_v1_health_check(client):
    """
    Test the API v1 health check endpoint
    """
    response = client.get("/api/v1/health/")
    assert response.status_code == 200
    data = response.json()
    assert data["status"] == "healthy"
    assert data["service"] == "KhedmaLink"


def test_api_v1_status_check(client):
    """
    Test the API v1 detailed status check endpoint
    """
    response = client.get("/api/v1/health/status")
    assert response.status_code == 200
    data = response.json()
    assert data["status"] == "operational"
    assert data["service"] == "KhedmaLink"
    assert "features" in data


def test_request_id_header(client):
    """
    Test that request ID middleware adds X-Request-ID header
    """
    response = client.get("/health")
    assert response.status_code == 200
    assert "X-Request-ID" in response.headers
    assert len(response.headers["X-Request-ID"]) > 0


def test_custom_request_id(client):
    """
    Test that custom request ID is preserved
    """
    custom_id = "test-request-id-123"
    headers = {"X-Request-ID": custom_id}
    response = client.get("/health", headers=headers)
    assert response.status_code == 200
    assert response.headers["X-Request-ID"] == custom_id


def test_openapi_docs(client):
    """
    Test that OpenAPI documentation is available
    """
    response = client.get("/docs")
    assert response.status_code == 200


def test_openapi_json(client):
    """
    Test that OpenAPI JSON schema is available
    """
    response = client.get("/api/v1/openapi.json")
    assert response.status_code == 200
    data = response.json()
    assert "openapi" in data
    assert "info" in data
    assert data["info"]["title"] == "KhedmaLink"
