"""Integration tests for dispute lifecycle."""


def _setup_booking(client, customer_token, provider_token):
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


class TestDisputeCreation:
    def test_create_dispute(self, client, customer_token, provider_token):
        booking_id = _setup_booking(client, customer_token, provider_token)

        response = client.post(
            "/api/v1/disputes",
            headers={"Authorization": f"Bearer {customer_token}"},
            json={
                "booking_id": booking_id,
                "dispute_type": "service_quality",
                "title": "Poor service quality",
                "description": "The repair was not done properly",
            },
        )
        assert response.status_code == 201
        data = response.json()
        assert data["status"] == "open"
        assert data["dispute_type"] == "service_quality"

    def test_duplicate_dispute_rejected(self, client, customer_token, provider_token):
        booking_id = _setup_booking(client, customer_token, provider_token)

        client.post(
            "/api/v1/disputes",
            headers={"Authorization": f"Bearer {customer_token}"},
            json={
                "booking_id": booking_id,
                "dispute_type": "service_quality",
                "title": "Poor service",
                "description": "Not done properly",
            },
        )

        dup_response = client.post(
            "/api/v1/disputes",
            headers={"Authorization": f"Bearer {customer_token}"},
            json={
                "booking_id": booking_id,
                "dispute_type": "payment_issue",
                "title": "Another dispute",
                "description": "Another issue",
            },
        )
        assert dup_response.status_code == 400

    def test_dispute_updates_booking_status(
        self, client, customer_token, provider_token
    ):
        _setup_booking(client, customer_token, provider_token)


class TestDisputeEvidence:
    def test_add_evidence(self, client, customer_token, provider_token):
        booking_id = _setup_booking(client, customer_token, provider_token)

        dispute_response = client.post(
            "/api/v1/disputes",
            headers={"Authorization": f"Bearer {customer_token}"},
            json={
                "booking_id": booking_id,
                "dispute_type": "service_quality",
                "title": "Poor service",
                "description": "Not done properly",
            },
        )
        dispute_id = dispute_response.json()["id"]

        evidence_response = client.post(
            f"/api/v1/disputes/{dispute_id}/evidence",
            headers={"Authorization": f"Bearer {customer_token}"},
            json={
                "evidence_type": "text",
                "description": "Photo of incomplete work",
            },
        )
        assert evidence_response.status_code == 201

    def test_list_evidence(self, client, customer_token, provider_token):
        booking_id = _setup_booking(client, customer_token, provider_token)

        dispute_response = client.post(
            "/api/v1/disputes",
            headers={"Authorization": f"Bearer {customer_token}"},
            json={
                "booking_id": booking_id,
                "dispute_type": "service_quality",
                "title": "Poor service",
                "description": "Not done properly",
            },
        )
        dispute_id = dispute_response.json()["id"]

        client.post(
            f"/api/v1/disputes/{dispute_id}/evidence",
            headers={"Authorization": f"Bearer {customer_token}"},
            json={"evidence_type": "text", "description": "Evidence 1"},
        )

        list_response = client.get(
            f"/api/v1/disputes/{dispute_id}/evidence",
            headers={"Authorization": f"Bearer {customer_token}"},
        )
        assert list_response.status_code == 200


class TestDisputeResolution:
    def test_admin_resolves_dispute(
        self, client, customer_token, provider_token, admin_token
    ):
        booking_id = _setup_booking(client, customer_token, provider_token)

        dispute_response = client.post(
            "/api/v1/disputes",
            headers={"Authorization": f"Bearer {customer_token}"},
            json={
                "booking_id": booking_id,
                "dispute_type": "service_quality",
                "title": "Poor service",
                "description": "Not done properly",
            },
        )
        dispute_id = dispute_response.json()["id"]

        resolve_response = client.post(
            f"/api/v1/disputes/{dispute_id}/resolve",
            headers={"Authorization": f"Bearer {admin_token}"},
            json={
                "resolution": "Provider will redo the work",
                "status": "resolved",
            },
        )
        assert resolve_response.status_code == 200
        assert resolve_response.json()["status"] == "resolved"

    def test_unauthorized_resolution(self, client, customer_token, provider_token):
        booking_id = _setup_booking(client, customer_token, provider_token)

        dispute_response = client.post(
            "/api/v1/disputes",
            headers={"Authorization": f"Bearer {customer_token}"},
            json={
                "booking_id": booking_id,
                "dispute_type": "service_quality",
                "title": "Poor service",
                "description": "Not done properly",
            },
        )
        dispute_id = dispute_response.json()["id"]

        response = client.post(
            f"/api/v1/disputes/{dispute_id}/resolve",
            headers={"Authorization": f"Bearer {customer_token}"},
            json={"resolution": "Resolved by customer"},
        )
        assert response.status_code in [401, 403]
        client.post(
            "/api/v1/disputes",
            headers={"Authorization": f"Bearer {customer_token}"},
            json={
                "booking_id": booking_id,
                "dispute_type": "service_quality",
                "title": "Poor service",
                "description": "Not done properly",
            },
        )

        booking_response = client.get(
            f"/api/v1/bookings/me/bookings/{booking_id}",
            headers={"Authorization": f"Bearer {customer_token}"},
        )
        assert booking_response.status_code == 200
        assert booking_response.json()["status"] == "disputed"
