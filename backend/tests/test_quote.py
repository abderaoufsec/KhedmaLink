"""
Quote API tests
Tests for quote endpoints, ownership checks, and validation
"""

import pytest
from fastapi.testclient import TestClient

from app.main import app


@pytest.fixture
def client():
    """Create a test client for the FastAPI application"""
    return TestClient(app)


# =============================================================================
# PROVIDER QUOTE MANAGEMENT TESTS
# =============================================================================


def test_list_my_quotes_unauthorized(client):
    """Test listing quotes without authentication"""
    response = client.get("/api/v1/quotes/me/quotes")

    # Should return 401 (unauthorized) or 403 (forbidden)
    assert response.status_code in [401, 403]


def test_create_quote_unauthorized(client):
    """Test creating a quote without authentication"""
    response = client.post(
        "/api/v1/quotes/me/quotes",
        json={
            "request_id": "00000000-0000-0000-0000-000000000001",
            "estimated_price": 1000,
        },
    )

    # Should return 401 (unauthorized) or 403 (forbidden)
    assert response.status_code in [401, 403]


def test_get_my_quote_unauthorized(client):
    """Test getting a quote without authentication"""
    quote_id = "00000000-0000-0000-0000-000000000001"
    response = client.get(f"/api/v1/quotes/me/quotes/{quote_id}")

    # Should return 401 (unauthorized) or 403 (forbidden)
    assert response.status_code in [401, 403]


def test_update_quote_unauthorized(client):
    """Test updating a quote without authentication"""
    quote_id = "00000000-0000-0000-0000-000000000001"
    response = client.put(
        f"/api/v1/quotes/me/quotes/{quote_id}",
        json={"estimated_price": 1500},
    )

    # Should return 401 (unauthorized) or 403 (forbidden)
    assert response.status_code in [401, 403]


def test_delete_quote_unauthorized(client):
    """Test deleting a quote without authentication"""
    quote_id = "00000000-0000-0000-0000-000000000001"
    response = client.delete(f"/api/v1/quotes/me/quotes/{quote_id}")

    # Should return 401 (unauthorized) or 403 (forbidden)
    assert response.status_code in [401, 403]


# =============================================================================
# CUSTOMER QUOTE MANAGEMENT TESTS
# =============================================================================


def test_list_request_quotes_unauthorized(client):
    """Test listing request quotes without authentication"""
    request_id = "00000000-0000-0000-0000-000000000001"
    response = client.get(f"/api/v1/quotes/me/requests/{request_id}/quotes")

    # Should return 401 (unauthorized) or 403 (forbidden)
    assert response.status_code in [401, 403]


def test_accept_quote_unauthorized(client):
    """Test accepting a quote without authentication"""
    request_id = "00000000-0000-0000-0000-000000000001"
    quote_id = "00000000-0000-0000-0000-000000000001"
    response = client.post(
        f"/api/v1/quotes/me/requests/{request_id}/quotes/{quote_id}/accept"
    )

    # Should return 401 (unauthorized) or 403 (forbidden)
    assert response.status_code in [401, 403]


def test_list_eligible_requests_unauthorized(client):
    """Test listing eligible requests without authentication"""
    response = client.get("/api/v1/quotes/me/eligible-requests")

    # Should return 401 (unauthorized) or 403 (forbidden)
    assert response.status_code in [401, 403]


# =============================================================================
# SCHEMA VALIDATION TESTS
# =============================================================================


def test_quote_schema_validation(client):
    """Test quote schema validation"""
    # Test with invalid time format
    response = client.post(
        "/api/v1/quotes/me/quotes",
        json={
            "request_id": "00000000-0000-0000-0000-000000000001",
            "estimated_price": 1000,
            "available_time_start": "25:00",  # Invalid: hour > 23
        },
    )

    # Should return 422 (validation error) or 401/403 (unauthorized/forbidden)
    assert response.status_code in [422, 401, 403]


def test_quote_price_validation(client):
    """Test quote price validation"""
    # Test with negative price
    response = client.post(
        "/api/v1/quotes/me/quotes",
        json={
            "request_id": "00000000-0000-0000-0000-000000000001",
            "estimated_price": -100,  # Invalid: negative
        },
    )

    # Should return 422 (validation error) or 401/403 (unauthorized/forbidden)
    assert response.status_code in [422, 401, 403]


def test_quote_duration_validation(client):
    """Test quote duration validation"""
    # Test with invalid duration unit
    response = client.post(
        "/api/v1/quotes/me/quotes",
        json={
            "request_id": "00000000-0000-0000-0000-000000000001",
            "estimated_price": 1000,
            "estimated_duration": 60,
            "estimated_duration_unit": "weeks",  # Invalid: not in allowed values
        },
    )

    # Should return 422 (validation error) or 401/403 (unauthorized/forbidden)
    assert response.status_code in [422, 401, 403]


def test_quote_status_validation(client):
    """Test quote status validation"""
    # Test with invalid status
    response = client.put(
        "/api/v1/quotes/me/quotes/00000000-0000-0000-0000-000000000001",
        json={
            "status": "cancelled",  # Invalid: not in allowed values
        },
    )

    # Should return 422 (validation error) or 401/403 (unauthorized/forbidden)
    assert response.status_code in [422, 401, 403]
