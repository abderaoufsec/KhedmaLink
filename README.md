# KhedmaLink

A trusted local-services marketplace connecting customers with verified service professionals in Blida, Algeria.

## Overview

KhedmaLink is a bilingual (Arabic + French) marketplace that enables customers to request services, receive quotes from verified providers, book appointments, and track completion through a trusted platform.

**Core Workflow:** Customer request → verified providers → quotes → booking → completion → review

## Tech Stack

### Frontend
- **Flutter** - Single codebase for Android and Web
- **State Management** - Provider/Riverpod (to be determined in M1)
- **Localization** - Arabic (RTL) + French (LTR)

### Backend
- **FastAPI** - High-performance Python web framework
- **PostgreSQL** - Primary database
- **Redis** - Caching and background jobs (where needed)
- **Docker** - Containerization

### Infrastructure
- **GitHub Actions** - CI/CD
- **Docker Compose** - Local development
- **S3-compatible storage** - File storage

## Project Structure

```
khedmalink/
├── frontend/              # Flutter application (Android + Web)
│   ├── lib/
│   │   ├── core/         # Core utilities (config, routing, theme, etc.)
│   │   └── features/     # Feature modules (auth, providers, bookings, etc.)
│   └── test/
├── backend/              # FastAPI backend
│   ├── app/
│   │   ├── api/          # API endpoints
│   │   ├── core/         # Core configuration
│   │   ├── models/       # Database models
│   │   ├── schemas/      # Pydantic schemas
│   │   └── services/     # Business logic
│   └── tests/
├── docs/                 # Documentation
│   ├── adr/             # Architecture Decision Records
│   ├── milestones/      # Milestone documentation
│   ├── KhedmaLink_Full_Project_Documentation.md
│   └── KhedmaLink_Devin_Milestone_Prompts.md
├── scripts/              # Utility scripts
└── .github/              # GitHub Actions workflows
```

## Development Setup

### Prerequisites
- Flutter SDK (3.0+)
- Python 3.11+
- PostgreSQL 14+
- Docker and Docker Compose
- Git

### Local Development

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd khedmalink
   ```

2. **Set up environment variables**
   ```bash
   cp .env.example .env
   # Edit .env with your local configuration
   ```

3. **Start backend services**
   ```bash
   cd backend
   docker-compose up -d
   # Run migrations
   python -m alembic upgrade head
   ```

4. **Start Flutter application**
   ```bash
   cd frontend
   flutter pub get
   flutter run -d chrome  # For web
   flutter run           # For Android
   ```

## Milestone-Based Development

This project follows a strict milestone-based development approach. Each milestone must be completed and verified before starting the next one.

**Current Milestone:** M0 - Repository & Engineering Charter

**Planned Milestones:**
- M0: Repository & Engineering Charter
- M1: Flutter Foundation
- M2: Backend Foundation
- M3: Authentication & Roles
- M4: Categories & Provider Profiles
- M5: Customer Service Requests
- M6: Quotes & Matching
- M7: Booking Lifecycle
- M8: Messaging & Notifications
- M9: Reviews & Reputation
- M10: Admin Operations
- M11: Disputes & Safety
- M12: Payments & Monetization Adapter
- M13: Maps & Search Improvements
- M14: Production Hardening
- M15: Controlled Beta
- M16: Post-Beta

See `docs/KhedmaLink_Full_Project_Documentation.md` for detailed milestone specifications.

## Documentation

- **Full Documentation:** `docs/KhedmaLink_Full_Project_Documentation.md`
- **Milestone Prompts:** `docs/KhedmaLink_Devin_Milestone_Prompts.md`
- **Architecture Decisions:** `docs/adr/`
- **Milestone Tracking:** `docs/milestones/`

## Code Quality

- **Formatting:** Prettier (Flutter), Black (Python)
- **Linting:** Flutter analyze, Ruff/Flake8 (Python)
- **Testing:** Unit tests, integration tests, E2E tests
- **CI:** GitHub Actions for all PRs

## Branch Strategy

- `main` - Production-ready code
- `develop` - Integration branch for features
- `feature/milestone-*` - Feature branches for each milestone
- `hotfix/*` - Emergency fixes

## Contributing

This project is built following strict engineering principles. See:
- `docs/CONTRIBUTING.md` (to be created)
- `docs/BRANCH_CONVENTIONS.md` (to be created)

## License

[License to be determined]

## Launch Strategy

**Initial Launch:**
- Geography: Blida, Algeria
- Languages: Arabic + French
- Platforms: Android + Web
- Categories: Appliance repair, AC service, cleaning, handyman, limited plumbing

**Future Expansion:** Additional cities/wilayas, more categories, advanced features

## Contact

[Contact information to be added]

---

**Note:** This repository is currently in M0 (Repository & Engineering Charter). The core application code will be implemented in subsequent milestones following the documented plan.
