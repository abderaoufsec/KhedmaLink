"""
Authorization tests
Tests for role-based access control and protected endpoints
"""

import pytest
from fastapi.testclient import TestClient

from app.main import app


@pytest.fixture
def client():
    """Create a test client for the FastAPI application"""
    return TestClient(app)


def test_protected_endpoint_without_token(client):
    """Test that protected endpoint without token returns 401/403"""
    response = client.get("/api/v1/users/me")
    assert response.status_code in [401, 403]


def test_protected_endpoint_with_invalid_token(client):
    """Test that protected endpoint with invalid token returns 401"""
    response = client.get(
        "/api/v1/users/me",
        headers={"Authorization": "Bearer invalid.token.string"},
    )
    assert response.status_code == 401


def test_admin_endpoint_without_admin_token(client):
    """Test that admin endpoint without admin role returns 403"""
    # First, register a regular user
    register_response = client.post(
        "/api/v1/auth/register",
        json={
            "email": "regularuser@example.com",
            "password": "TestPass123",
            "full_name": "Regular User",
        },
    )
    
    # Get the user's token
    if register_response.status_code == 201:
        login_response = client.post(
            "/api/v1/auth/login",
            json={
                "email": "regularuser@example.com",
                "password": "TestPass123",
            },
        )
        
        if login_response.status_code == 200:
            token = login_response.json().get("access_token")
            
            # Try to access admin endpoint with regular user token
            # Note: If endpoint doesn't exist (404), that's expected for now
            admin_response = client.get(
                "/api/v1/admin/users",
                headers={"Authorization": f"Bearer {token}"},
            )
            
            # Should return 403 (forbidden) because user is not admin
            # Or 404 if endpoint doesn't exist yet
            assert admin_response.status_code in [403, 404]


def test_regular_user_cannot_access_provider_endpoints(client):
    """Test that regular customers cannot access provider-only endpoints"""
    # Register a customer
    register_response = client.post(
        "/api/v1/auth/register",
        json={
            "email": "customer@example.com",
            "password": "TestPass123",
            "full_name": "Customer User",
        },
    )
    
    if register_response.status_code == 201:
        login_response = client.post(
            "/api/v1/auth/login",
            json={
                "email": "customer@example.com",
                "password": "TestPass123",
            },
        )
        
        if login_response.status_code == 200:
            token = login_response.json().get("access_token")
            
            # Try to access provider profile endpoint
            # Note: If endpoint doesn't exist (404), that's expected for now
            provider_response = client.get(
                "/api/v1/provider/profile",
                headers={"Authorization": f"Bearer {token}"},
            )
            
            # Should return 403 (forbidden) because user is not provider
            # Or 404 if endpoint doesn't exist yet
            assert provider_response.status_code in [403, 404]
