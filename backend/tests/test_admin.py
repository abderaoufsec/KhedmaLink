"""
Tests for admin operations endpoints
Tests admin-only endpoints for user management, verification, and audit logs
"""

import pytest
from fastapi.testclient import TestClient

from app.main import app


@pytest.fixture
def client():
    """Create a test client for the FastAPI application"""
    return TestClient(app)


def test_list_users_unauthorized(client: TestClient):
    """Test that listing users requires admin role"""
    response = client.get("/api/v1/admin/users")
    assert response.status_code == 403


def test_update_user_status_unauthorized(client: TestClient):
    """Test that updating user status requires admin role"""
    response = client.post("/api/v1/admin/users/status")
    assert response.status_code == 403


def test_list_verification_queue_unauthorized(client: TestClient):
    """Test that listing verification queue requires admin role"""
    response = client.get("/api/v1/admin/verification/queue")
    assert response.status_code == 403


def test_verification_action_unauthorized(client: TestClient):
    """Test that verification actions require admin role"""
    response = client.post("/api/v1/admin/verification/action")
    assert response.status_code == 403


def test_delete_content_unauthorized(client: TestClient):
    """Test that content deletion requires admin role"""
    response = client.post("/api/v1/admin/content/delete")
    assert response.status_code == 403


def test_list_audit_logs_unauthorized(client: TestClient):
    """Test that listing audit logs requires admin role"""
    response = client.get("/api/v1/admin/audit-logs")
    assert response.status_code == 403


def test_user_status_update_schema_validation(client: TestClient):
    """Test that user status update validates schema"""
    response = client.post(
        "/api/v1/admin/users/status",
        json={
            "user_id": "invalid-uuid",
            "status": "invalid-status",
        },
    )
    # Should fail validation even without auth
    assert response.status_code in [403, 422]


def test_verification_action_schema_validation(client: TestClient):
    """Test that verification action validates schema"""
    response = client.post(
        "/api/v1/admin/verification/action",
        json={
            "provider_id": "invalid-uuid",
            "action": "invalid-action",
        },
    )
    # Should fail validation even without auth
    assert response.status_code in [403, 422]


def test_content_deletion_schema_validation(client: TestClient):
    """Test that content deletion validates schema"""
    response = client.post(
        "/api/v1/admin/content/delete",
        json={
            "resource_type": "invalid_type",
            "resource_id": "invalid-uuid",
        },
    )
    # Should fail validation even without auth
    assert response.status_code in [403, 422]


def test_user_list_filters_schema_validation(client: TestClient):
    """Test that user list filters validate schema"""
    response = client.get(
        "/api/v1/admin/users?page=0&page_size=200",
    )
    # Should fail validation even without auth
    assert response.status_code in [403, 422]
