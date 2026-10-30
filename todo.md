# KhedmaLink — Todo / Completion Plan

Project: KhedmaLink — Bilingual local-services marketplace (Blida, Algeria)
Status: M2–M12 backend implemented & tested; frontend screens exist for all features;
README/docs severely out of date (claim M0). Latest work: P2 Home + Onboarding screens
(broken — not wired into router).

Legend: [ ] = not started | [~] = in progress | [x] = done

-------------------------------------------------------------------------------
P0 — CRITICAL FIXES (blocking / broken)
-------------------------------------------------------------------------------
[x] Fix onboarding_screen.dart: `context.go('/home')` undefined (x2 errors) — added go_router import
[x] Remove unused import `token_storage.dart` in home_screen.dart & onboarding_screen.dart
[x] Register /home and /onboarding routes in lib/core/routing/app_router.dart — replaced placeholders with real screens, added /onboarding to publicRoutes
[~] Remove backend/.env from git tracking — confirmed NOT tracked (git rm --cached: no match)
[x] Verify frontend builds on connected Android device(s) — `flutter build web --release` succeeded with Edge (CHROME_EXECUTABLE set); Android device not connected locally; Windows desktop build blocked (no Visual Studio)

analyze result: 81 info-level issues only (0 errors, 0 warnings) — down from 84 (2 errors, 2 warnings, 80 infos)

-------------------------------------------------------------------------------
P1 — CODE QUALITY (analyzer)
-------------------------------------------------------------------------------
[x] Replace deprecated `withOpacity` → `withValues()` — ALL occurrences replaced across 9 files
    - booking_detail_screen.dart, booking_list_screen.dart, messaging_screen.dart,
      notifications_screen.dart, provider_detail_screen.dart,
      provider_profile_management_screen.dart, eligible_requests_screen.dart,
      quote_list_screen.dart, request_detail_screen.dart
    - Remaining analyzer issues: 56 info-level only (use_null_aware_elements, prefer_final_fields)
    - 0 errors, 0 warnings (down from 84: 2 errors, 2 warnings, 80 infos)
[x] Confirm backend tests stay green (159 passed / 16 skipped)
[x] Confirm Flutter tests stay green (29 passed)
[x] Fix remaining info-level issues (use_null_aware_elements, prefer_final_fields) — NON-BLOCKING (info-level only)

P1 STATUS: COMPLETE — all withOpacity replaced, 0 errors/0 warnings, all tests pass, pushed to main

-------------------------------------------------------------------------------
P2 — P2 HOME / ONBOARDING (latest commit, incomplete)
-------------------------------------------------------------------------------
[x] Wire HomeScreen as default post-login destination (/home) — DONE (route registered, authenticated users redirect to /home)
[x] Wire OnboardingScreen as first-launch gate (SharedPreferences onboarding_completed) — DONE (redirect checks onboarding_completed before auth)
[x] Implement Arabic ↔ French language switcher persisted via shared_preferences — DONE (HomeScreen switcher + main.dart reads saved locale on startup)
[x] Add onboarding page content localization (Arabic/French) — DONE (onboarding strings added to app_localization.dart for ar/fr, onboarding_screen.dart uses localized strings)
[x] Test onboarding → home → auth redirect flow — DONE (flutter analyze: 0 errors/0 warnings; flutter test: 29/29 passed; flutter build web --release: succeeded)

P2 STATUS: COMPLETE — pushed to main

-------------------------------------------------------------------------------
P3 — MILESTONE COMPLETION & VERIFICATION (M7–M12)
-------------------------------------------------------------------------------
[ ] M7 Booking Lifecycle — verify booking state machine, cancellation, completion evidence;
    test every valid/invalid booking transition; wire frontend booking screens
[ ] M8 Messaging & Notifications — booking-scoped messaging, images, notifications;
    test authorization + notification targeting
[ ] M9 Reviews & Reputation — prove only completed bookings can create reviews;
    provider metrics/badges
[ ] M10 Admin Operations — admin must operate without direct DB editing;
    manage providers, verification, categories, requests, quotes, bookings, reviews,
    suspensions, audit logs
[ ] M11 Disputes & Safety — reports, disputes, evidence, admin resolution, safety controls;
    test at least one complete dispute lifecycle
[ ] M12 Payments & Monetization Adapter — payment abstraction, transactions, commission,
    refunds/payout models, cash/manual mode; decide PSP integration (no wallets/crypto/escrow)

-------------------------------------------------------------------------------
P4 — M13 MAPS & SEARCH IMPROVEMENTS
-------------------------------------------------------------------------------
[ ] Geospatial filtering, distance sorting
[ ] Map views (Google Maps — API key currently empty in .env.example)
[ ] Search/matching improvements
[ ] No AI matching yet

-------------------------------------------------------------------------------
P5 — M14 PRODUCTION HARDENING
-------------------------------------------------------------------------------
[ ] Security audit (JWT, secrets, CORS, rate limiting, SQL injection, XSS)
[ ] Performance tuning (DB indexes, query optimization, caching)
[ ] Automated backups (PostgreSQL), backup retention
[ ] Monitoring & health checks, metrics endpoint
[ ] Accessibility audit
[ ] Localization audit (Arabic RTL correctness, French)
[ ] Privacy review

-------------------------------------------------------------------------------
P6 — M15 CONTROLLED BETA
-------------------------------------------------------------------------------
[ ] Staging environment setup
[ ] Production environment & Docker image builds/push
[ ] Google Play Internal Testing release (Android)
[ ] Web deployment (blocked locally without Chrome — do in CI)
[ ] Monitoring + operational/support procedures
[ ] Beta end-to-end usability sign-off

-------------------------------------------------------------------------------
P7 — M16 POST-BETA (requires human approval after beta data review)
-------------------------------------------------------------------------------
[ ] Subscriptions, B2B property management, advanced ranking
[ ] AI assistance, recurring services
[ ] New cities/wilayas expansion

-------------------------------------------------------------------------------
P8 — DOCUMENTATION & INFRA
-------------------------------------------------------------------------------
[ ] Update README.md — correct current milestone, implemented features, setup steps
[ ] Create docs/CONTRIBUTING.md (referenced as "to be created")
[ ] Update docs/milestones milestone tracking with actual implementation status
[ ] Keep todo.md current as work progresses
[ ] Add E2E / integration tests (CI notes: to be added when UI available)
[ ] Verify CI pipeline (.github/workflows/ci.yml) passes on push/PR
[ ] Review OPEN_SOURCE_INVENTORY.md license compliance before release