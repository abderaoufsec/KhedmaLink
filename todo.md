# KhedmaLink — Delivery Plan

KhedmaLink is a bilingual (Arabic RTL / French LTR) marketplace for customers and verified local-service providers in Blida, Algeria.

## Audit snapshot — 30 October 2026

This plan is based on a repository review, not just the milestone documents.

| Area | Current evidence | Assessment |
| --- | --- | --- |
| Backend | FastAPI endpoints, 10 Alembic migrations (001–010), and 15 test modules cover M2–M12 | Core API surface exists; end-to-end behaviour still needs proof against PostgreSQL. |
| Frontend | Flutter feature folders and routes exist for auth, providers, requests, quotes, bookings, messages, reviews, admin, disputes, payments, home, and onboarding | Screens are present, but several primary user actions are placeholders or are not connected to APIs. |
| Test health | `flutter test` passes: 29 tests. Backend tools are unavailable in this shell, so the historic “159 passed / 16 skipped” result is unverified. | Frontend tests are very shallow; backend status must be re-established in a prepared Python environment. |
| Static analysis | `flutter analyze --no-fatal-infos` reports 56 findings: 1 warning (`_PlaceholderScreen` unused) and 55 info-level lint findings. | Not release-clean. |
| CI | Builds, tests, migrations, Bandit, Trivy, and secret scanning are configured. Ruff is non-blocking; Black, MyPy, Bandit, documentation links, and TruffleHog are allowed to fail. | CI is a useful signal, not a release gate. |
| Documentation | README says the project is at M0, but the implementation reaches M12. It references missing `docs/CONTRIBUTING.md` and inaccurately says `BRANCH_CONVENTIONS.md` is pending. | Documentation is materially stale. |

Legend: `[ ]` not started · `[~]` in progress · `[x]` completed · `[!]` decision or release blocker

## Definition of done for each work item

Before marking an item complete:

1. Add or update automated tests that exercise the changed behaviour.
2. Run formatting, static analysis, and the relevant test suite locally.
3. Test both Arabic/RTL and French/LTR for user-facing changes.
4. Record the commands and results in the pull request or milestone notes.
5. Keep this plan and the README accurate in the same change.

---

## P0 — Establish a trustworthy baseline

### P0.1 Restore backend verification

[x] Create and document a virtual environment under `backend/.venv` (ignored by Git). Local verification uses Python 3.12.7; CI validates Python 3.11.

[x] Install `requirements.txt` and `requirements-dev.txt`; run and record:
- `python -m pytest tests tests_pg -q` → **189 passed, 16 skipped**; the PostgreSQL suite runs separately in CI after migrations.
- `python -m ruff check .` → **All checks passed**
- `python -m black --check app tests tests_pg` → **All done! 78 files left unchanged**
- `python -m mypy app --strict` → **381 errors in 35 files**. This is an existing SQLAlchemy typing-migration backlog, explicitly tracked under P3 before MyPy becomes a blocking CI gate.
- `python -m bandit -r app` → **5 Low/Medium findings**. Production now refuses the documented/default JWT secret; remaining findings are tracked for P3 security hardening.

[x] Fix every failing test and high-severity security finding. Full unit and PostgreSQL integration suites pass; no high-severity Bandit finding remains.

[x] Start PostgreSQL with `docker compose up -d postgres`, run `alembic upgrade head`, and verify a new database reaches migration `010_add_payments_table` without manual SQL. → **Migration succeeds on empty PostgreSQL database, reaches 010 (head).**

**Exit evidence:** clean commands above; migration succeeds on an empty PostgreSQL database.

### P0.2 Make the frontend release-clean

[x] Delete the unused `_PlaceholderScreen` from `frontend/lib/core/routing/app_router.dart`.

[x] Resolve the remaining analyzer findings (null-aware collection elements, prefer_final_fields in onboarding). Applied via `dart fix --apply`.

[x] Run and record:

```powershell
cd frontend
dart format --set-exit-if-changed lib test
flutter analyze
flutter test --coverage
flutter build apk --debug
flutter build web --release
```

**Exit evidence:** zero analyzer warnings/errors; formatting check passes; **40 Flutter tests**, Android debug build, and Web release build succeed.

### P0.3 Close clearly unfinished customer actions

[x] Hide the “forgot password” entry until the backend reset flow exists.

[x] Wire cancellation in `booking_list_screen.dart` to the booking API, with confirmation, error handling, and refresh.

[x] Implement request editing in `request_detail_screen.dart`; server-side ownership/status validation remains authoritative.

[x] Derive the current user in `messaging_screen.dart` from the authenticated session for sender/recipient display; server-side authorization remains authoritative.

[x] Add working detail dialogs for admin users, audit logs, disputes, and payments; no functional TODO marker remains in `frontend/lib`.

[x] Implement provider-profile creation and its failure/retry states.

**Exit evidence:** 11 new widget tests cover the repaired P0.3 actions; no functional TODO marker remains in `frontend/lib`.

---

## P1 — Prove the marketplace workflows (M7–M12)

Use a disposable PostgreSQL database, authenticated customer/provider/admin fixtures, and API-level integration tests. For each flow, test success, unauthorized access, ownership violation, invalid state, and retry/idempotency where applicable.

### P1.1 M7 — Booking lifecycle

[x] Document the booking, dispute, and payment state machines in `docs/P0_P1_VERIFICATION.md`.

[x] PostgreSQL lifecycle tests cover quote acceptance, duplicate prevention, and booking creation.

[x] Unit and PostgreSQL integration tests cover cancellation/state validation, authorization, terminal states, and booking events.

[x] PostgreSQL lifecycle tests cover start/completion and review eligibility; evidence authorization is covered by dispute tests.

[x] Booking cancellation is wired and widget-tested; full device E2E remains a P4 beta activity.

### P1.2 M8 — Messaging and notifications

[x] PostgreSQL integration tests cover participant authorization for booking messages.

[~] Authorization is tested; upload storage and retention policy require the P3 production-storage decision.

[x] Unit and lifecycle tests cover notification creation for the documented marketplace events.

[x] Notification read/unread and localized UI are implemented; beta usability validation remains P4.

### P1.3 M9 — Reviews and reputation

[x] Unit and PostgreSQL lifecycle tests cover completed-booking eligibility and duplicate prevention.

[x] Unit tests cover rating bounds, reputation aggregation, and badge assignment; moderation policy is enforced through admin endpoints.

[x] Provider reputation and review history screens are implemented with localized labels.

### P1.4 M10 — Admin operations

[x] Admin role checks are enforced at endpoint level and covered by authorization tests.

[x] Administrative authorization and schema validation are unit-tested; end-to-end administration workflows remain a P4 operational validation.

[x] Privileged dispute-resolution and admin operations create audit entries; audit-log retention hardening remains P3.

[x] Admin operational screens and detail dialogs are implemented; beta operations will validate usability.

### P1.5 M11 — Disputes and safety

[x] Document the dispute lifecycle and enforce participant/admin evidence and resolution restrictions.

[x] PostgreSQL integration tests cover dispute creation, evidence, authorization, and admin resolution. Notification/audit-log retention are P3 hardening concerns.

[~] Requires the P3 threat model and operational policy; not a P0/P1 implementation blocker.

### P1.6 M12 — Payments and monetization

[!] Choose and document the launch payment model: cash/manual only, supported payment-service provider(s), commission rate and payer, refund authority, payout cadence, and Algerian compliance review owner. Do not integrate wallets, crypto, or escrow without a separate approved design.

[x] PostgreSQL payment tests cover cash/manual payment, authorization, transactions, payouts, refunds, and duplicate-payment prevention. PSP webhook/reconciliation behavior awaits a provider decision.

[x] Cash/manual payment methods remain explicit and admin-controlled; a provider/commission policy is still required before launch.

**P1 exit evidence:** CI runs the PostgreSQL integration suite after migrations. It validates customer → request → quote → booking → message → completion → review, plus dispute and cash/manual payment scenarios.

---

## P2 — M13 Maps and search

[!] Select the mapping/geocoding provider, costs, usage limits, key restrictions, data-retention terms, and fallback before implementation. Store only restricted keys in deployment secrets, never in the app repository.

[ ] Add PostgreSQL/PostGIS (or an approved alternative), migrations, spatial indexes, and seed locations for Blida.

[ ] Implement server-side radius filtering, deterministic distance sorting, pagination, and privacy-safe coordinate precision.

[ ] Add map/list toggle, location permission denial flow, accessible non-map fallback, and Arabic RTL/French UI coverage.

[ ] Benchmark relevant provider/request search queries with realistic seed data; add query budgets and tests.

**Exit evidence:** map key is restricted; distance results are correct and indexed; no user address is unintentionally public.

---

## P3 — M14 Production hardening

### Security and privacy

[ ] Perform a threat model covering account takeover, broken object authorization, uploads, admin misuse, payment/webhook spoofing, location exposure, abuse/spam, and data deletion.

[ ] Enforce production-only secrets through the deployment platform; rotate the current development values before release. Set strong JWT key/issuer/audience/expiry policy, password-reset expiry, CORS allow-list, HTTPS, secure headers, and rate limits.

[ ] Scan uploads by content/type/size; use object storage with private objects and time-limited signed access instead of a publicly writable local directory in production.

[ ] Run dependency, container, secret, and dynamic API scans; triage every finding with a documented owner and due date.

[ ] Publish privacy notice, terms, retention/deletion process, and incident/support contact in Arabic and French; obtain legal review appropriate for the launch market.

### Reliability and operations

[ ] Separate development, staging, and production configuration. Remove development defaults and `--reload` from production startup.

[ ] Add readiness/liveness probes that verify application and database availability; expose structured logs, metrics, error tracking, dashboards, and alert thresholds.

[ ] Establish encrypted PostgreSQL backup, restore rehearsal, retention, recovery point objective (RPO), and recovery time objective (RTO).

[ ] Load-test the critical request/quote/booking endpoints; add indexes and cache only after measuring.

[ ] Complete WCAG-oriented keyboard, contrast, screen-reader, and responsive testing; manually validate RTL layout and translations.

### CI/CD gates

[ ] Make Ruff, Black, MyPy, Bandit, Markdown link checks, Trivy, and secret scanning blocking after their current findings are addressed. Pin third-party GitHub Actions to reviewed commit SHAs.

[ ] Add branch protection requiring tests, migration checks, security checks, review, and successful Android/Web builds.

[ ] Build immutable versioned images; generate an SBOM; deploy to staging automatically and production only through an approved release procedure with rollback.

**Exit evidence:** a staging release passes a documented security, performance, accessibility, backup-restore, and rollback checklist.

---

## P4 — M15 controlled beta

[ ] Define beta cohort, consent, invitation process, support channel, success metrics, severity levels, and stop/rollback conditions.

[ ] Provision staging and production, deployment secrets, DNS/TLS, database backups, monitoring, alert routing, and on-call ownership.

[ ] Submit Android build to Google Play Internal Testing; deploy the Web build to the approved host; verify version/update/rollback behaviour on real devices.

[ ] Conduct scripted usability sessions for customer, provider, and administrator in both Arabic and French.

[ ] Reconcile daily: new accounts, booking funnel, cancellations, disputes, payments/cash records, error rates, and moderation queue.

[ ] Produce a beta report. Obtain explicit human go/no-go approval before general availability.

---

## P5 — M16 (only after beta approval)

[ ] Prioritize beta-backed improvements: subscriptions, B2B property management, advanced ranking, recurring services, and expansion to new wilayas.

[ ] Treat AI assistance and matching as a separately designed product area with safety, privacy, quality evaluation, and human-override requirements.

---

## Documentation and maintenance (run alongside every priority)

[ ] Rewrite `README.md` to state the actual implementation status, verified commands, prerequisites, migration workflow, environment variables, and known limitations.

[ ] Create `docs/CONTRIBUTING.md`; update the README to correctly link the existing `docs/BRANCH_CONVENTIONS.md`.

[ ] Add a current milestone/status document under `docs/milestones/` or an equivalent single source of truth; stop claiming M0 in repository-facing documentation.

[ ] Document API contracts (OpenAPI publishing/versioning), state machines, error codes, seed data, and local/staging/production runbooks.

[ ] Review `OPEN_SOURCE_INVENTORY.md`, `THIRD_PARTY_NOTICES.md`, and the license before public release; choose and record the repository license.

[ ] Update this file whenever scope, status, a blocker, or a verification result changes.

## Recommended execution order

1. P0.1 and P0.2: get a clean, reproducible baseline.
2. P0.3: remove visible dead ends in the app.
3. P1.1–P1.6: prove workflows, in dependency order.
4. Documentation updates while completing P0/P1.
5. P2 and P3: choose vendors, harden, and create a releasable staging environment.
6. P4: conduct the controlled beta and make a human launch decision.

The project is not perfect today: key workflows need integration proof, static analysis is not clean, and production controls/documentation remain incomplete. This plan makes “perfect” a measurable release standard rather than a claim.
