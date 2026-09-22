# KhedmaLink — Full Product, Technical & Execution Documentation

**Product:** KhedmaLink  
**Type:** Trusted local-services marketplace  
**Launch geography:** Blida, Algeria  
**Platforms:** Flutter Web + Flutter Android  
**Languages:** Arabic + French at launch  
**Engineering agent:** Devin AI  
**Development rule:** Devin works on exactly ONE milestone at a time.

---

# 1. Product Vision

KhedmaLink connects customers with trustworthy local service professionals.

Core workflow:

> Need a service → describe the job → find suitable verified providers → receive/compare quotes → book → complete → review.

KhedmaLink is not a classifieds website. The main product value is **trust + structured job requests + quote comparison + managed booking + reputation**.

## Customer value
- Find suitable providers quickly.
- Understand verification status.
- Send one structured job request.
- Receive comparable offers.
- Book a provider.
- Track job status.
- Keep service history.
- Review completed work.
- Report problems through a defined process.

## Provider value
- Qualified customer leads.
- Professional profile.
- Identity/professional verification.
- Portfolio and service history.
- Quote and job management.
- Durable reputation from real completed jobs.
- Reduced time wasted on unserious requests.

## Admin value
- Control verification.
- Control categories and provider eligibility.
- Manage jobs, reports, disputes and reviews.
- Audit important actions.
- Monitor marketplace health.

---

# 2. Product Principles

1. Trust before growth.
2. Structured service requests before free-form chat.
3. Server-side authorization for every sensitive action.
4. Real completed jobs create reputation.
5. Arabic and French are first-class languages.
6. One Flutter codebase serves Android and Web.
7. Avoid unnecessary custom infrastructure.
8. No premature financial custody or complex fintech.
9. No critical workflow depends on AI.
10. Devin must never silently expand scope.

---

# 3. Initial Operational Scope

The software supports a broad service taxonomy, but the initial operating focus should remain narrow.

Recommended initial categories:
- Appliance repair
- Air-conditioner service/diagnostics
- Cleaning
- Handyman/general maintenance
- Limited non-dangerous plumbing

Do not initially activate:
- Gas work
- Major electrical work
- Clinical/medical services
- High-risk construction
- Unlimited workmanship guarantees
- Services where required licensing cannot be reliably verified

Initial geography:
- Blida city
- nearby areas where adequate provider density exists

The system must support additional cities/wilayas later without redesign.

---

# 4. User Roles

## 4.1 Customer

- Register/login
- Manage profile
- Save addresses
- Browse categories
- Search providers
- View provider profiles
- Create service requests
- Upload photos
- Receive quotes
- Compare quotes
- Accept quote
- Schedule booking
- Message provider inside the booking context
- Track booking status
- Confirm completion
- Review provider
- Report/dispute a job
- View history
- Rebook previous provider

## 4.2 Provider

- Register/login
- Create provider profile
- Select services
- Define service area
- Define availability
- Upload portfolio
- Submit verification information
- Receive requests
- Accept/decline interest
- Submit quotes
- Propose time/price
- Message customer
- Update job status
- Mark completion
- Upload completion evidence
- View reviews
- View basic earnings/commission history where enabled

## 4.3 Admin

- Secure login
- Customer management
- Provider management
- Verification queue
- Category management
- Request management
- Quote/booking management
- Reviews/moderation
- Disputes
- Reports
- Suspensions
- Audit logs
- Analytics
- Notifications/settings

## 4.4 Super Admin

Includes Admin capabilities plus:
- Role administration
- Platform configuration
- Commission configuration
- Feature flags
- System settings
- Security/audit review

---

# 5. Core Workflows

## 5.1 Customer request

1. Select service category.
2. Enter job title.
3. Describe problem.
4. Upload photos.
5. Enter preferred date/time.
6. Select address.
7. Optional budget.
8. Submit.
9. System validates and creates request.
10. Eligible providers receive the request.

## 5.2 Provider quote

Provider sees eligible request and can:
- decline;
- send a quote;
- propose a time;
- add notes.

Quote fields:
- price;
- currency;
- availability;
- estimated duration;
- note;
- proposed date/time.

## 5.3 Quote selection

1. Customer receives quotes.
2. Customer compares price, availability and provider trust information.
3. Customer accepts one quote.
4. Other open quotes close.
5. Booking is created.

## 5.4 Booking lifecycle

`DRAFT → PENDING → QUOTED → ACCEPTED → SCHEDULED → IN_PROGRESS → COMPLETED`

Terminal states:
- CANCELLED
- EXPIRED
- REJECTED
- DISPUTED

Every transition is validated server-side.

## 5.5 Completion

1. Provider marks work completed.
2. Provider may upload completion evidence.
3. Customer receives notification.
4. Customer confirms completion or opens dispute.
5. Booking closes.
6. Review becomes available.
7. Reputation metrics update.

## 5.6 Dispute

1. Customer/provider opens dispute.
2. Booking becomes `DISPUTED`.
3. Reason and evidence are submitted.
4. Other party may respond.
5. Admin reviews evidence.
6. Admin makes a resolution.
7. Decision and evidence remain auditable.

---

# 6. Trust & Verification

Trust is a core feature.

## Verification levels

### Phone Verified
Phone number verified.

### Identity Verified
Government identity document reviewed under the approved verification process.

### Professional Verified
Relevant qualification/license/document reviewed when applicable.

### Business Verified
Business registration details reviewed for business providers.

### Top Rated
Only after sufficient completed jobs and reviews.

Badge meanings must be visible in the UI. No vague trust claims.

## Reputation inputs

Track:
- average rating;
- review count;
- completed jobs;
- completion rate;
- response rate;
- response time;
- cancellation rate;
- dispute rate;
- verification level;
- recent activity.

V1 must use explainable metrics. Do not make the product dependent on an opaque AI trust score.

## Reviews

- Only completed bookings can create reviews.
- One review per completed booking.
- Review actions are audited.
- Suspended users do not gain the ability to erase historical booking integrity.

Recommended dimensions:
- Overall
- Punctuality
- Work quality
- Communication
- Value

---

# 7. Provider Matching

## V1 matching rules

Providers are eligible based on:
1. Correct category/subcategory.
2. Service area.
3. Active provider status.
4. Verification eligibility for the category.
5. Availability when applicable.
6. Not suspended.

Then rank by deterministic signals such as:
- response rate;
- completion rate;
- rating;
- distance;
- recent workload.

AI matching is future scope only.

---

# 8. Customer Search & Provider Profiles

Search/filter:
- category;
- subcategory;
- location;
- radius;
- availability;
- rating;
- verification;
- price range when meaningful.

Provider profile:
- name/business name;
- photo/logo;
- category;
- description;
- service area;
- verification badges;
- completed jobs;
- rating;
- reviews;
- response information;
- portfolio;
- availability;
- request/booking CTA.

Private documents must never be exposed.

---

# 9. Messaging & Notifications

## Messaging

- Booking/request scoped.
- Text.
- Images.
- Timestamp.
- Basic delivered/read state if supported.
- Report/block controls.
- Defined retention policy.

Do not build a general social chat system.

## Notifications

- Account/security events
- New request
- Quote received
- Quote accepted
- Booking confirmed
- Schedule reminder
- Job status
- New message
- Job completion
- Review request
- Dispute update
- Admin actions

Channels:
- in-app;
- push;
- email when required.

WhatsApp is optional and must not become a core technical dependency.

---

# 10. Payments & Monetization

## Business model

Primary:
- commission on completed jobs.

Later:
- provider subscription;
- premium provider tools;
- disclosed promoted placement;
- B2B/property manager plans;
- recurring service packages.

## Payment architecture

Do not hard-code a specific payment provider.

Use a provider abstraction such as:

`PaymentProvider`

Payment states:
- UNPAID
- PENDING
- PAID
- FAILED
- REFUNDED
- CANCELLED

Support a cash/manual operational mode while the payment provider decision is being finalized.

Commission data must include:
- gross amount;
- platform fee;
- provider net;
- currency;
- payment status;
- refund status.

The commission rate is configuration, not a constant.

## No V1 wallet

Do not build:
- stored-value wallet;
- crypto;
- money transfer between users;
- custodial escrow;
- financial products.

---

# 11. Admin & Operations

Admin sections:
- Dashboard
- Customers
- Providers
- Verification
- Categories
- Requests
- Quotes
- Bookings
- Disputes
- Reviews
- Reports
- Audit logs
- Settings
- Analytics

Provider verification must support:
- review;
- approve;
- reject with reason;
- request more information;
- suspend;
- view history.

Admin must be able to operate the marketplace without editing the database manually.

---

# 12. Data Model

Recommended PostgreSQL entities:

- users
- roles
- user_roles
- customer_profiles
- provider_profiles
- categories
- service_categories
- provider_services
- service_areas
- addresses
- availability_rules
- verification_cases
- verification_documents
- service_requests
- request_attachments
- request_matches
- quotes
- bookings
- booking_events
- messages
- message_attachments
- reviews
- disputes
- dispute_evidence
- payment_transactions
- payouts
- notifications
- notification_preferences
- reports
- audit_logs
- platform_settings
- feature_flags

Use UUIDs or another safe public identifier strategy.

Critical relationships:

`User → CustomerProfile / ProviderProfile`

`Provider → ProviderServices → ServiceArea → Availability → Verification`

`Customer → ServiceRequests → Quotes → Booking`

`Booking → Messages / Events / Review / optional Payment / optional Dispute`

---

# 13. API

Use versioned REST:

`/api/v1/...`

Suggested modules:

## Auth
- POST /auth/register
- POST /auth/login
- POST /auth/refresh
- POST /auth/logout
- POST /auth/verify-phone

## Me
- GET /me
- PATCH /me
- GET /me/addresses
- POST /me/addresses

## Categories
- GET /categories
- GET /categories/{id}

## Providers
- GET /providers
- GET /providers/{id}
- PATCH /providers/me
- POST /providers/me/services
- PATCH /providers/me/availability

## Verification
- POST /providers/me/verification
- POST /providers/me/verification/documents
- GET /providers/me/verification

## Requests
- POST /requests
- GET /requests
- GET /requests/{id}
- PATCH /requests/{id}
- POST /requests/{id}/attachments

## Quotes
- GET /requests/{id}/quotes
- POST /requests/{id}/quotes
- PATCH /quotes/{id}
- POST /quotes/{id}/accept

## Bookings
- GET /bookings
- GET /bookings/{id}
- POST /bookings/{id}/cancel
- POST /bookings/{id}/start
- POST /bookings/{id}/complete

## Messages
- GET /bookings/{id}/messages
- POST /bookings/{id}/messages

## Reviews
- POST /bookings/{id}/review
- GET /providers/{id}/reviews

## Disputes
- POST /bookings/{id}/disputes
- GET /disputes/{id}

All admin routes require server-side role authorization.

---

# 14. Technical Architecture

## Frontend

Flutter for:
- Android
- Web

One codebase.

Recommended structure:

```text
lib/
  core/
    config/
    routing/
    theme/
    localization/
    networking/
    errors/
    storage/
    analytics/
  features/
    auth/
    onboarding/
    home/
    categories/
    providers/
    requests/
    quotes/
    bookings/
    messaging/
    reviews/
    verification/
    disputes/
    notifications/
    profile/
    admin/
```

Every feature should separate:
- presentation;
- domain;
- data.

Do not place business logic directly in widgets.

## Backend

Recommended open-source oriented stack:
- FastAPI
- PostgreSQL
- Redis only where it materially helps
- S3-compatible object storage
- background worker only when required
- Docker
- OpenAPI

A self-hosted Supabase deployment may be evaluated if it measurably reduces custom implementation without creating unacceptable vendor lock-in. This is an implementation decision, not a product requirement.

## Infrastructure

- Docker Compose local environment
- GitHub Actions CI
- staging environment
- production environment
- HTTPS
- backups
- monitoring

---

# 15. Responsive Web

The same Flutter project serves Web + Android.

Web must support:
- phone-width browsers;
- tablet;
- desktop.

Customer web:
- landing/discovery;
- request creation;
- quote comparison;
- bookings;
- provider profiles.

Provider web:
- dashboard;
- requests;
- quotes;
- booking management;
- availability;
- verification;
- profile.

Admin web:
- desktop-oriented data tables;
- filtering;
- pagination;
- audit visibility;
- keyboard-friendly workflows.

---

# 16. Localization

Launch:
- Arabic RTL
- French LTR

Rules:
- no hard-coded user-visible strings;
- translation keys for all text;
- localized dates;
- localized numbers/currency;
- RTL layouts tested;
- layouts must tolerate longer French/Arabic strings.

---

# 17. Security

Required:
- secure authentication;
- RBAC;
- object-level authorization;
- server-side validation;
- rate limiting;
- safe uploads;
- signed private document URLs;
- secure secrets;
- DB least privilege;
- audit logs;
- HTTPS outside local development.

Never trust client-supplied:
- role;
- verification status;
- price calculation;
- commission calculation;
- booking state.

Sensitive documents are private by default.

---

# 18. File & Media Rules

Media types:
- profile images;
- provider portfolio;
- job photos;
- verification documents;
- completion evidence.

Controls:
- MIME validation;
- size limits;
- image compression;
- private storage for verification documents;
- thumbnails for public portfolio images;
- retention policy.

---

# 19. Analytics

Track business events, not sensitive content.

Customer:
- signup_completed
- category_viewed
- provider_viewed
- request_started
- request_submitted
- quote_received
- quote_accepted
- booking_created
- booking_completed
- review_submitted

Provider:
- onboarding_completed
- verification_submitted
- verification_approved
- request_received
- quote_sent
- booking_accepted
- job_started
- job_completed

Trust:
- report_created
- dispute_created
- dispute_resolved
- provider_suspended

---

# 20. Testing

## Unit

Test:
- validation;
- booking states;
- quote acceptance;
- permissions;
- fee calculation;
- reputation metrics;
- notification rules.

## API

Test:
- authentication;
- authorization;
- ownership;
- request creation;
- quote creation;
- quote acceptance;
- booking transitions;
- disputes;
- admin controls.

## Flutter

- widget tests for critical components;
- integration tests for critical flows.

## Mandatory end-to-end flow

Customer register → provider register → provider verified → customer request → provider quotes → customer accepts → booking → completion → review.

Second mandatory flow:

Customer dispute → provider response → admin resolution.

---

# 21. CI/CD

Every PR:
- format;
- static analysis;
- tests;
- relevant build;
- migration check.

Protected main branch.

Release path:

`Development → Staging → Smoke Tests → Production`

No direct production changes without approval.

---

# 22. Environments

- local
- development
- staging
- production

No production secrets in source control.

Provide `.env.example`.

Never share production database/storage with local development.

---

# 23. Seed Data

Provide deterministic demo data for:
- categories;
- providers;
- customers;
- requests;
- quotes;
- bookings;
- reviews.

Never use real personal information in seed data.

---

# 24. Business Rules

1. Only eligible providers can receive a request.
2. Only providers can create provider quotes.
3. A customer cannot accept multiple quotes for one request.
4. Accepting a quote closes competing open quotes.
5. Only booking participants can access booking chat.
6. Only completed bookings can be reviewed.
7. Only trusted server/admin workflows can change verification status.
8. Only server-side logic calculates platform fees.
9. Suspended providers cannot receive new jobs.
10. Invalid booking transitions must fail.
11. Disputes cannot be silently closed.
12. Privileged actions must be auditable.

---

# 25. AI Policy

AI is optional assistance, not the authority for critical state.

Allowed later:
- category classification;
- search assistance;
- provider recommendations;
- moderation suggestions;
- support drafting.

Never let AI alone decide:
- authentication;
- permissions;
- verification;
- booking state;
- payments;
- refunds;
- final dispute decisions.

Every AI-assisted workflow must have deterministic fallback.

---

# 26. Open-Source Strategy

Useful current references to inspect:

- **HomeHelp** — Flutter home-services marketplace with customer/worker flows, quote negotiation, realtime chat and web/mobile support. Treat as a reference until its repository licensing terms are explicitly verified.
- **Freelacers Platform** — FastAPI + React local-services marketplace with requests, quotes and bookings; its GitHub page currently identifies an MIT license.
- **Fix-It** — Flutter home-maintenance marketplace reference with booking/payment/review flow; verify license before reuse.
- **ServeNow** — large Flutter/Firebase service-marketplace reference; verify exact license and commercial reuse terms before using code.

Rules:
1. Public GitHub code is not automatically reusable.
2. Verify license before copying code.
3. Record reused repositories and packages.
4. Preserve required notices.
5. Prefer architecture/pattern learning when licensing is unclear.
6. Create `OPEN_SOURCE_INVENTORY.md` and `THIRD_PARTY_NOTICES.md`.

---

# 27. Documentation Required in Repository

- README.md
- ARCHITECTURE.md
- API.md
- DATABASE.md
- SECURITY.md
- LOCALIZATION.md
- DEPLOYMENT.md
- TESTING.md
- OPEN_SOURCE_INVENTORY.md
- THIRD_PARTY_NOTICES.md
- CHANGELOG.md
- docs/milestones/

---

# 28. Definition of Done

A feature is done only when:
- implementation exists;
- required tests exist;
- tests pass;
- authorization exists;
- loading/empty/error states exist;
- localization exists for user-visible text;
- documentation is updated;
- build succeeds;
- acceptance criteria are satisfied.

---

# 29. Explicit V1 Non-Goals

Do not implement in V1:
- AI trust score;
- insurance;
- provider micro-loans;
- AR service preview;
- IoT integrations;
- social feed;
- crypto;
- stored-value wallet;
- custodial escrow;
- advanced ML ranking;
- nationwide launch infrastructure;
- multi-country infrastructure.

---

# 30. Master Milestone Plan

## M0 — Repository & Engineering Charter

Create repository, docs, branch/PR standards, CI skeleton, environment example and architecture decision record.

**Exit:** clean repo, CI works, documentation structure exists.

## M1 — Flutter Foundation

Shared Flutter Android + Web app, routing, design system, localization, responsive primitives, error/loading/empty states.

**Exit:** Flutter analyze/tests/Android build/Web build pass; Arabic RTL and French LTR work.

## M2 — Backend Foundation

FastAPI, PostgreSQL, migrations, configuration, health endpoint, OpenAPI, Docker local environment, logging.

**Exit:** local backend starts reproducibly; migrations/tests pass.

## M3 — Authentication & Roles

Customer/provider/admin authentication, sessions, RBAC, ownership checks.

**Exit:** role boundaries tested and enforced.

## M4 — Categories & Provider Profiles

Categories, services, service area, availability, provider profiles, basic verification status, search/discovery.

**Exit:** customer can discover provider; provider can manage profile.

## M5 — Customer Service Requests

Structured request form, photos, address, date, validation, request history.

**Exit:** customer can create and view a real request end-to-end.

## M6 — Quotes & Provider Matching

Deterministic matching, provider requests, provider quotes, quote comparison, quote acceptance.

**Exit:** request → 2+ quotes → customer accepts one.

## M7 — Booking Lifecycle

Scheduling, booking state machine, completion evidence, cancellation.

**Exit:** full booking lifecycle works and invalid transitions fail.

## M8 — Messaging & Notifications

Booking-scoped chat, images, push/in-app notifications.

**Exit:** authorized parties can communicate and receive correct events.

## M9 — Reviews & Reputation

Reviews, provider metrics, badges, report flow.

**Exit:** only completed bookings can review; metrics are correct.

## M10 — Admin Operations

Provider verification queue, users, categories, requests, bookings, reviews, suspensions, audit logs.

**Exit:** admin can operate the marketplace without DB edits.

## M11 — Disputes & Safety

Dispute lifecycle, evidence, moderation, suspension, abuse controls.

**Exit:** end-to-end dispute flow tested.

## M12 — Payments & Monetization Adapter

Provider abstraction, transactions, commission calculation, refund/payout models, cash/manual mode and approved sandbox PSP integration if ready.

**Exit:** server-controlled payment states and correct commission calculations.

## M13 — Maps & Search Improvements

Geospatial filtering, maps, distance sorting, improved matching/search indexing.

**Exit:** realistic search volume performs acceptably.

## M14 — Production Hardening

Security, performance, backups, monitoring, privacy, accessibility, localization audit.

**Exit:** no critical/high defects and production builds succeed.

## M15 — Controlled Beta

Staging, production, Play internal testing, web deployment, monitoring and support process.

**Exit:** beta environment is usable end-to-end.

## M16 — Post-Beta

Only after actual usage: subscriptions, B2B property management, advanced ranking, AI assistance, recurring services, new cities/wilayas.

---

# 31. Absolute Devin Rule

**Devin works on ONE milestone at a time.**

For a current milestone, Devin may:
- implement that milestone;
- fix bugs blocking that milestone;
- add tests required for that milestone;
- update documentation required by that milestone.

Devin may NOT:
- implement future milestones;
- introduce future payment systems early;
- build AI because it might help later;
- perform broad refactors unrelated to the milestone;
- add unnecessary dependencies;
- change architecture without approval.

At the end of every milestone Devin must report:
- summary;
- exact files changed;
- DB migrations;
- API changes;
- Flutter changes;
- tests run/results;
- Android build result where applicable;
- Web build result where applicable;
- known issues;
- explicit confirmation: **No future milestone work was implemented.**

Then Devin must STOP.

---

# 32. Standard Devin Prompt

Use this for every milestone:

> You are working on KhedmaLink.
>
> Read `KhedmaLink_Full_Project_Documentation.md`.
>
> Work ONLY on Milestone [NUMBER — NAME].
>
> First inspect the repository and verify the previous milestone exit criteria.
>
> If the previous milestone is incomplete, stop and report the blocker.
>
> Implement only the current milestone requirements.
>
> Do not implement future milestones.
>
> Preserve existing working behavior.
>
> Add tests for every new business rule.
>
> Run the required checks and builds.
>
> Update documentation required by this milestone.
>
> Report:
> - summary;
> - files changed;
> - database changes;
> - API changes;
> - Flutter changes;
> - tests and results;
> - Android build result;
> - Web build result;
> - known issues;
> - explicit scope confirmation.
>
> STOP after the milestone is complete.

---

# 33. Final Product Definition

KhedmaLink V1 is a bilingual, trusted local-services marketplace for Blida where:

**Customer**
→ requests a service
→ receives comparable provider quotes
→ selects a provider
→ books
→ tracks/completes
→ reviews.

**Provider**
→ verifies profile
→ receives qualified request
→ sends quote
→ completes job
→ builds reputation.

**Admin**
→ verifies providers
→ manages marketplace
→ handles disputes/reports
→ controls operations.

The objective is not to produce the maximum amount of code.

The objective is to produce a stable, testable, maintainable marketplace that Devin can build one controlled milestone at a time.
