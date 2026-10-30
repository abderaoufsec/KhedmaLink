"""Integration tests for payment/refund/manual-payment lifecycle."""


def _setup_completed_booking(client, customer_token, provider_token):
    """Helper to create a completed booking for payment tests."""
    cat_response = client.get("/api/v1/categories")
    category_id = cat_response.json()[0]["id"]

    req_response = client.post(
        "/api/v1/requests/me/requests",
        headers={"Authorization": f"Bearer {customer_token}"},
        json={
            "category_id": category_id,
            "title_ar": "إصلاح ثلاجة",
            "title_fr": "Réparation réfrigérateur",
            "description_ar": "ثلاجتي لا تعمل",
            "description_fr": "Mon réfrigérateur ne fonctionne pas",
            "city": "Blida",
            "wilaya": "Blida",
        },
    )
    request_id = req_response.json()["id"]

    quote_response = client.post(
        "/api/v1/quotes/me/quotes",
        headers={"Authorization": f"Bearer {provider_token}"},
        json={"request_id": request_id, "estimated_price": 3000},
    )
    quote_id = quote_response.json()["id"]

    client.put(
        f"/api/v1/quotes/me/quotes/{quote_id}",
        headers={"Authorization": f"Bearer {provider_token}"},
        json={"status": "submitted"},
    )
    accepted_quote_response = client.post(
        f"/api/v1/quotes/me/requests/{request_id}/quotes/{quote_id}/accept",
        headers={"Authorization": f"Bearer {customer_token}"},
    )
    assert accepted_quote_response.status_code == 200

    bookings_response = client.get(
        "/api/v1/bookings/me/bookings",
        headers={"Authorization": f"Bearer {customer_token}"},
    )
    assert bookings_response.status_code == 200
    booking = next(
        item for item in bookings_response.json() if item["quote_id"] == quote_id
    )
    booking_id = booking["id"]

    client.post(
        f"/api/v1/bookings/me/bookings/{booking_id}/start",
        headers={"Authorization": f"Bearer {provider_token}"},
    )
    client.post(
        f"/api/v1/bookings/me/bookings/{booking_id}/complete",
        headers={"Authorization": f"Bearer {provider_token}"},
        json={"completion_notes": "Done"},
    )

    return booking_id


class TestPaymentCreation:
    def test_create_payment_cash(self, client, customer_token, provider_token):
        booking_id = _setup_completed_booking(client, customer_token, provider_token)

        response = client.post(
            "/api/v1/payments",
            headers={"Authorization": f"Bearer {customer_token}"},
            json={
                "booking_id": booking_id,
                "payment_method": "cash",
            },
        )
        assert response.status_code == 201
        data = response.json()
        assert data["status"] == "pending"
        assert data["payment_method"] == "cash"
        assert float(data["amount"]) == 3000.0

    def test_create_payment_manual(self, client, customer_token, provider_token):
        booking_id = _setup_completed_booking(client, customer_token, provider_token)

        response = client.post(
            "/api/v1/payments",
            headers={"Authorization": f"Bearer {customer_token}"},
            json={
                "booking_id": booking_id,
                "payment_method": "manual",
                "external_payment_id": "BANK_TRANSFER_123",
            },
        )
        assert response.status_code == 201
        data = response.json()
        assert data["payment_method"] == "manual"

    def test_duplicate_payment_rejected(self, client, customer_token, provider_token):
        booking_id = _setup_completed_booking(client, customer_token, provider_token)

        client.post(
            "/api/v1/payments",
            headers={"Authorization": f"Bearer {customer_token}"},
            json={"booking_id": booking_id, "payment_method": "cash"},
        )

        dup_response = client.post(
            "/api/v1/payments",
            headers={"Authorization": f"Bearer {customer_token}"},
            json={"booking_id": booking_id, "payment_method": "cash"},
        )
        assert dup_response.status_code in [400, 409, 500]

    def test_payment_ownership(self, client, customer_token, provider_token):
        booking_id = _setup_completed_booking(client, customer_token, provider_token)

        response = client.post(
            "/api/v1/payments",
            headers={"Authorization": f"Bearer {provider_token}"},
            json={"booking_id": booking_id, "payment_method": "cash"},
        )
        assert response.status_code in [403, 404]


class TestPaymentRefund:
    def _create_payment(self, client, customer_token, provider_token):
        booking_id = _setup_completed_booking(client, customer_token, provider_token)
        response = client.post(
            "/api/v1/payments",
            headers={"Authorization": f"Bearer {customer_token}"},
            json={"booking_id": booking_id, "payment_method": "cash"},
        )
        assert response.status_code == 201
        payment_id = response.json()["id"]

        return payment_id

    def test_refund_requires_admin(self, client, customer_token, provider_token):
        booking_id = _setup_completed_booking(client, customer_token, provider_token)
        payment_response = client.post(
            "/api/v1/payments",
            headers={"Authorization": f"Bearer {customer_token}"},
            json={"booking_id": booking_id, "payment_method": "cash"},
        )
        payment_id = payment_response.json()["id"]

        # Customer cannot refund
        response = client.post(
            f"/api/v1/payments/{payment_id}/refund",
            headers={"Authorization": f"Bearer {customer_token}"},
            json={"amount": 1000, "reason": "Test refund"},
        )
        assert response.status_code in [401, 403]

    def test_refund_requires_completed_payment(
        self, client, customer_token, provider_token, admin_token
    ):
        booking_id = _setup_completed_booking(client, customer_token, provider_token)
        payment_response = client.post(
            "/api/v1/payments",
            headers={"Authorization": f"Bearer {customer_token}"},
            json={"booking_id": booking_id, "payment_method": "cash"},
        )
        payment_id = payment_response.json()["id"]

        # Refund on pending payment should fail
        response = client.post(
            f"/api/v1/payments/{payment_id}/refund",
            headers={"Authorization": f"Bearer {admin_token}"},
            json={"amount": 1000, "reason": "Test refund"},
        )
        assert response.status_code == 400

    def test_list_transactions(self, client, customer_token, provider_token):
        booking_id = _setup_completed_booking(client, customer_token, provider_token)
        payment_response = client.post(
            "/api/v1/payments",
            headers={"Authorization": f"Bearer {customer_token}"},
            json={"booking_id": booking_id, "payment_method": "cash"},
        )
        payment_id = payment_response.json()["id"]

        response = client.get(
            f"/api/v1/payments/{payment_id}/transactions",
            headers={"Authorization": f"Bearer {customer_token}"},
        )
        assert response.status_code == 200

    def test_list_payouts(self, client, customer_token, provider_token):
        booking_id = _setup_completed_booking(client, customer_token, provider_token)
        payment_response = client.post(
            "/api/v1/payments",
            headers={"Authorization": f"Bearer {customer_token}"},
            json={"booking_id": booking_id, "payment_method": "cash"},
        )
        payment_id = payment_response.json()["id"]

        response = client.get(
            f"/api/v1/payments/{payment_id}/payouts",
            headers={"Authorization": f"Bearer {customer_token}"},
        )
        assert response.status_code == 200

    def test_unauthorized_payment(self, client, customer_token, provider_token):
        booking_id = _setup_completed_booking(client, customer_token, provider_token)

        response = client.post(
            "/api/v1/payments",
            json={"booking_id": booking_id, "payment_method": "cash"},
        )
        assert response.status_code in [401, 403]
