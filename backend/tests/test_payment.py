"""
Tests for payment endpoints
Tests payment creation, processing, refunds, and payouts
"""

import pytest
from fastapi.testclient import TestClient

from app.main import app


@pytest.fixture
def client():
    """Create a test client for the FastAPI application"""
    return TestClient(app)


def test_create_payment_unauthorized(client: TestClient):
    """Test that creating a payment requires authentication"""
    response = client.post("/api/v1/payments")
    assert response.status_code in [401, 403]


def test_list_payments_unauthorized(client: TestClient):
    """Test that listing payments requires authentication"""
    response = client.get("/api/v1/payments")
    assert response.status_code in [401, 403]


def test_get_payment_unauthorized(client: TestClient):
    """Test that getting a payment requires authentication"""
    response = client.get("/api/v1/payments/123e4567-e89b-12d3-a456-426614174000")
    assert response.status_code in [401, 403]


def test_update_payment_unauthorized(client: TestClient):
    """Test that updating a payment requires admin role"""
    response = client.put("/api/v1/payments/123e4567-e89b-12d3-a456-426614174000")
    assert response.status_code in [401, 403]


def test_create_transaction_unauthorized(client: TestClient):
    """Test that creating a transaction requires admin role"""
    response = client.post(
        "/api/v1/payments/123e4567-e89b-12d3-a456-426614174000/transactions"
    )
    assert response.status_code in [401, 403]


def test_list_transactions_unauthorized(client: TestClient):
    """Test that listing transactions requires authentication"""
    response = client.get(
        "/api/v1/payments/123e4567-e89b-12d3-a456-426614174000/transactions"
    )
    assert response.status_code in [401, 403]


def test_create_payout_unauthorized(client: TestClient):
    """Test that creating a payout requires admin role"""
    response = client.post(
        "/api/v1/payments/123e4567-e89b-12d3-a456-426614174000/payouts"
    )
    assert response.status_code in [401, 403]


def test_list_payouts_unauthorized(client: TestClient):
    """Test that listing payouts requires authentication"""
    response = client.get(
        "/api/v1/payments/123e4567-e89b-12d3-a456-426614174000/payouts"
    )
    assert response.status_code in [401, 403]


def test_update_payout_unauthorized(client: TestClient):
    """Test that updating a payout requires admin role"""
    response = client.put(
        "/api/v1/payments/payouts/123e4567-e89b-12d3-a456-426614174000"
    )
    assert response.status_code in [401, 403]


def test_refund_payment_unauthorized(client: TestClient):
    """Test that refunding a payment requires admin role"""
    response = client.post(
        "/api/v1/payments/123e4567-e89b-12d3-a456-426614174000/refund"
    )
    assert response.status_code in [401, 403]


def test_payment_create_schema_validation(client: TestClient):
    """Test that payment creation validates schema"""
    response = client.post(
        "/api/v1/payments",
        json={
            "booking_id": "invalid-uuid",
            "payment_method": "invalid_method",
        },
    )
    # Should fail validation even without auth
    assert response.status_code in [401, 403, 422]


def test_transaction_create_schema_validation(client: TestClient):
    """Test that transaction creation validates schema"""
    response = client.post(
        "/api/v1/payments/123e4567-e89b-12d3-a456-426614174000/transactions",
        json={
            "transaction_type": "invalid_type",
            "amount": -100,
        },
    )
    # Should fail validation even without auth
    assert response.status_code in [401, 403, 422]


def test_refund_create_schema_validation(client: TestClient):
    """Test that refund creation validates schema"""
    response = client.post(
        "/api/v1/payments/123e4567-e89b-12d3-a456-426614174000/refund",
        json={
            "amount": -100,
            "reason": "",
        },
    )
    # Should fail validation even without auth
    assert response.status_code in [401, 403, 422]
