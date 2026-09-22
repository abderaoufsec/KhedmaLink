# KhedmaLink — Devin Milestone Prompts

Use exactly one prompt at a time.

## M0 — Repository & Engineering Charter

You are working on KhedmaLink.

Read `KhedmaLink_Full_Project_Documentation.md`.

Implement ONLY M0.

Create the Git repository structure, README, documentation folders, `.gitignore`, `.editorconfig`, `.env.example`, branch/PR conventions, CI skeleton, architecture decision record and open-source inventory template.

Do not implement customer, provider, booking, messaging, payment or AI features.

Run repository/CI validation and report all results.

STOP.

## M1 — Flutter Foundation

Implement ONLY M1.

Create the shared Flutter application for Android + Web with feature-first structure, routing, design system, Arabic RTL, French LTR, responsive layout primitives, configuration, logging and standard loading/error/empty states.

Do not implement authentication, provider marketplace, requests, quotes, bookings, chat, payments or AI.

Run Flutter formatting, analysis, unit tests, Android build and Web release build.

STOP after reporting results.

## M2 — Backend Foundation

Implement ONLY M2.

Create FastAPI backend, PostgreSQL connection, migrations, configuration, health endpoint, OpenAPI, structured logging, request IDs, Docker local environment and initial tables defined by M2.

Do not implement booking, quote, payment, chat or AI workflows.

Run backend tests and migration tests.

STOP.

## M3 — Authentication & Roles

Implement ONLY M3.

Implement customer/provider/admin authentication, sessions, role-based authorization, object ownership checks, frontend auth routing and protected backend routes.

Do not implement provider marketplace, requests, quotes, bookings, payments or AI.

Prove role isolation with automated tests.

STOP.

## M4 — Categories & Provider Profiles

Implement ONLY M4.

Implement categories, provider services, service areas, availability, provider profiles, basic verification states, provider discovery and filters.

Do not implement quote, booking, payment, chat or AI.

Run API, widget and relevant integration tests.

STOP.

## M5 — Customer Service Requests

Implement ONLY M5.

Implement customer request creation with category, description, photos, address, preferred date/time and optional budget, plus request list/detail.

Do not implement quotes, booking acceptance, payments, chat or AI.

Test ownership and validation.

STOP.

## M6 — Quotes & Matching

Implement ONLY M6.

Implement deterministic provider eligibility, provider request view, quote creation, quote modification, customer quote comparison and acceptance of one quote with server-side closing of competing quotes.

Do not implement bookings, messaging, payments, AI matching or advanced reputation.

Test the full request → quote → acceptance flow.

STOP.

## M7 — Booking Lifecycle

Implement ONLY M7.

Implement scheduling, booking state machine, cancellation and completion evidence.

Do not implement payments or disputes beyond the minimum state needed to represent a booking.

Test every valid and invalid booking transition.

STOP.

## M8 — Messaging & Notifications

Implement ONLY M8.

Implement booking-scoped messaging, images and required notifications.

Do not implement general social chat, payment, AI or future features.

Test authorization and notification targeting.

STOP.

## M9 — Reviews & Reputation

Implement ONLY M9.

Implement verified reviews and explainable provider metrics/badges.

Do not implement AI trust scoring or background checks.

Prove that only completed bookings can create reviews.

STOP.

## M10 — Admin Operations

Implement ONLY M10.

Implement admin management for providers, verification, categories, requests, quotes, bookings, reviews, suspensions and audit logs.

Admin must be able to operate without direct DB editing.

STOP.

## M11 — Disputes & Safety

Implement ONLY M11.

Implement reports, disputes, evidence, admin resolution and safety/moderation controls.

Do not implement insurance or financial products.

Test at least one complete dispute lifecycle.

STOP.

## M12 — Payments & Monetization Adapter

Implement ONLY M12.

Implement provider-independent payment abstraction, transactions, commission calculation, refunds/payout models and cash/manual mode. Integrate a PSP only if explicitly approved.

Do not implement wallets, crypto or custodial escrow.

STOP.

## M13 — Maps & Search Improvements

Implement ONLY M13.

Add geospatial filtering, map views, distance sorting and search/matching improvements.

Do not add AI matching yet.

STOP.

## M14 — Production Hardening

Implement ONLY M14.

Perform security, performance, backup, monitoring, accessibility and localization hardening.

Do not add new product functionality unless required to close a security/reliability issue.

STOP.

## M15 — Controlled Beta

Implement ONLY M15.

Prepare staging and production, Play internal testing release, Web deployment, monitoring and operational/support procedures.

Do not expand product scope.

STOP.

## M16 — Post-Beta

Do NOT start automatically.

This milestone requires human approval after beta data review.

Possible additions include subscriptions, B2B/property managers, advanced ranking, AI assistance, recurring services and geographic expansion.
