# P0/P1 Verification Record

This document records the completion criteria for the P0/P1 implementation
baseline. Production hardening, third-party provider selection, and beta
operations remain planned work and are not implied by this record.

## Reproducible checks

Run backend checks from `backend/` using the project virtual environment:

```powershell
.venv\Scripts\python.exe -m pytest tests tests_pg -q
.venv\Scripts\python.exe -m ruff check .
.venv\Scripts\python.exe -m black --check app tests tests_pg
.venv\Scripts\python.exe -m bandit -r app
```

CI runs the PostgreSQL migration check and then `tests_pg/` with the GitHub
Actions PostgreSQL service. The PostgreSQL suite creates and destroys its own
schema and must not be pointed at a shared production database.

Flutter checks run from `frontend/`:

```powershell
dart format --set-exit-if-changed lib test
flutter analyze
flutter test --coverage
flutter build apk --debug
flutter build web --release
```

## Marketplace state machines

### Booking

| Current state | Allowed next state | Actor |
| --- | --- | --- |
| `draft` | `pending`, `cancelled` | System/customer |
| `pending` | `quoted`, `cancelled` | System/customer |
| `quoted` | `accepted`, `cancelled` | Customer/system |
| `accepted` | `scheduled`, `in_progress`, `cancelled` | Provider/customer as authorized |
| `scheduled` | `in_progress`, `cancelled` | Provider/customer as authorized |
| `in_progress` | `completed`, `disputed` | Provider/customer as authorized |
| `completed`, `cancelled`, `expired`, `rejected`, `disputed` | none | Terminal |

Each valid state change records a booking event. A review is eligible only for
a completed booking and is limited to one review per eligible party.

### Dispute

A booking participant creates an `open` dispute. The other booking participant
may respond, moving it to `investigating`. Both participants may add evidence;
an `admin` or `super_admin` resolves it. An active dispute cannot be duplicated
for the same booking. Resolution creates an audit entry.

### Manual payments

The currently implemented launch adapter supports `cash` and `manual` records.
A customer creates one payment record for a booking. Administrators control
payment status changes, transactions, payouts, and refunds. A provider payout
requires a completed payment. A real payment provider, commission policy,
refund authority, and reconciliation procedure are required before launch.

## Deferred quality work

- `mypy app --strict` still reports legacy SQLAlchemy typing errors. Converting
  models to SQLAlchemy 2 `Mapped[]` annotations is tracked as P3 hardening;
  this check remains non-blocking in CI until the migration is complete.
- Bandit findings require periodic review. Production configuration rejects a
  default or short JWT secret; security scanning becomes fully blocking in P3.
- Upload storage, retention, malware scanning, and public/private object
  policies are P3 production-storage work.
