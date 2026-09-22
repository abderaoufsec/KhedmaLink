# KhedmaLink Open-Source Inventory

This document tracks all open-source repositories, packages, and libraries referenced or used in the KhedmaLink project, along with their license information and usage status.

## Purpose

- Track all open-source dependencies and references
- Ensure license compliance
- Provide transparency about third-party code
- Support commercial reuse decisions
- Maintain required license notices

## Usage Categories

### Reference Only
Repositories inspected for learning architecture/patterns but not directly used in code.

### Direct Dependency
Libraries and packages directly used in the project code.

### Potential Future Use
Repositories that may be used in future milestones after license verification.

---

## Reference-Only Repositories

These repositories are referenced for architectural patterns and learning purposes only. No code is copied without explicit license verification.

| Repository | URL | License | License Verified | Usage Notes | Last Checked |
|------------|-----|---------|------------------|-------------|--------------|
| HomeHelp | https://github.com/example/homehelp | Unknown | ❌ No | Flutter home-services marketplace reference with customer/worker flows, quote negotiation, realtime chat and web/mobile support | 2025-01-22 |
| Freelacers Platform | https://github.com/example/freelacers | MIT | ✅ Yes | FastAPI + React local-services marketplace with requests, quotes and bookings | 2025-01-22 |
| Fix-It | https://github.com/example/fix-it | Unknown | ❌ No | Flutter home-maintenance marketplace reference with booking/payment/review flow | 2025-01-22 |
| ServeNow | https://github.com/example/serve-now | Unknown | ❌ No | Large Flutter/Firebase service-marketplace reference | 2025-01-22 |

### Reference Repository Details

#### HomeHelp
- **Purpose:** Flutter home-services marketplace reference
- **Key Features:** Customer/worker flows, quote negotiation, realtime chat, web/mobile support
- **License Status:** Unknown - requires verification before any code reuse
- **Architecture Patterns:** Feature-first structure, state management, realtime communication
- **Verification Required:** Check repository license, commercial reuse terms, attribution requirements

#### Freelacers Platform
- **Purpose:** FastAPI + React local-services marketplace reference
- **Key Features:** Service requests, quotes, bookings, provider management
- **License Status:** MIT - verified from GitHub page
- **Architecture Patterns:** API design, database schema, authentication flow
- **Reuse Potential:** High - MIT license permits commercial use with attribution

#### Fix-It
- **Purpose:** Flutter home-maintenance marketplace reference
- **Key Features:** Booking flow, payment integration, review system
- **License Status:** Unknown - requires verification before any code reuse
- **Architecture Patterns:** Booking state machine, payment integration, review system
- **Verification Required:** Check repository license, commercial reuse terms

#### ServeNow
- **Purpose:** Large Flutter/Firebase service-marketplace reference
- **Key Features:** Comprehensive marketplace features, Firebase integration
- **License Status:** Unknown - requires verification before any code reuse
- **Architecture Patterns:** Flutter/Firebase architecture, scalability patterns
- **Verification Required:** Check repository license, commercial reuse terms, Firebase licensing

---

## Direct Dependencies

These libraries and packages are directly used in the KhedmaLink project.

### Flutter Dependencies

| Package | Version | License | License Link | Usage | Last Updated |
|---------|---------|---------|--------------|-------|--------------|
| (To be added in M1) | - | - | - | - | - |

### Python/Backend Dependencies

| Package | Version | License | License Link | Usage | Last Updated |
|---------|---------|---------|--------------|-------|--------------|
| (To be added in M2) | - | - | - | - | - |

### Development Dependencies

| Package | Version | License | License Link | Usage | Last Updated |
|---------|---------|---------|--------------|-------|--------------|
| (To be added as needed) | - | - | - | - | - |

---

## Potential Future Use

These repositories may be used in future milestones after license verification and commercial reuse analysis.

| Repository | URL | License | License Verified | Potential Use | Priority |
|------------|-----|---------|------------------|---------------|----------|
| (To be added as needed) | - | - | - | - | - |

---

## License Compliance Matrix

### Permissive Licenses (Generally OK for Commercial Use)
- MIT License ✅
- Apache License 2.0 ✅
- BSD License (2-clause, 3-clause) ✅
- ISC License ✅

### Copyleft Licenses (Require Careful Review)
- GNU GPL v2/v3 ⚠️
- GNU AGPL v3 ⚠️
- Mozilla Public License ⚠️

### Proprietary/Commercial Licenses (Require Explicit Permission)
- Custom licenses ❌
- Commercial licenses ❌

---

## License Verification Process

1. **Initial Check**
   - Locate LICENSE file in repository
   - Check GitHub license badge
   - Review README for license information

2. **License Analysis**
   - Identify license type
   - Review requirements (attribution, modifications, distribution)
   - Check for commercial use restrictions

3. **Compliance Assessment**
   - Determine if license permits commercial use
   - Identify any attribution requirements
   - Check for patent clauses or other restrictions

4. **Documentation**
   - Record license details in this inventory
   - Note any special requirements
   - Update THIRDPARTY_NOTICES.md if needed

5. **Legal Review (if needed)**
   - For complex or ambiguous licenses
   - For copyleft licenses
   - For custom or unusual licenses

---

## Attribution Requirements

### MIT License Attribution
```
Copyright (c) [Year] [Copyright Holder]

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.
```

### Apache 2.0 License Attribution
```
Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
```

---

## Audit Procedure

### Monthly Audit
- Review all new dependencies added
- Verify license information
- Update this inventory
- Check for license changes

### Pre-Release Audit
- Comprehensive review of all dependencies
- License compliance verification
- Attribution requirements check
- Update THIRDPARTY_NOTICES.md

### Post-Third-Party Integration
- Document any third-party code integration
- Verify license compliance
- Add attribution if required
- Update inventory

---

## Risk Assessment

### High Risk
- Copyleft licenses (GPL, AGPL)
- Unclear or missing license information
- Custom licenses without clear terms
- Repositories with conflicting licenses

### Medium Risk
- Licenses with complex attribution requirements
- Licenses with patent clauses
- Licenses requiring source code distribution

### Low Risk
- Standard permissive licenses (MIT, Apache, BSD)
- Well-documented licenses
- Widely used libraries with clear licensing

---

## Emergency Contact

For license compliance issues or questions:
- **Legal Contact:** [To be added]
- **Technical Lead:** [To be added]
- **Project Manager:** [To be added]

---

## Changes Log

| Date | Change | Author |
|------|--------|--------|
| 2025-01-22 | Initial inventory created as part of M0 | Devin AI |

---

## Notes

- This inventory is a living document and must be kept current
- All license verification must be documented
- When in doubt about license terms, seek legal advice
- Never assume code is reusable without explicit license verification
- Preserve all required license notices and attributions
- Review this document before any third-party code integration

---

**Last Updated:** 2025-01-22  
**Next Review:** 2025-02-22  
**Milestone:** M0 - Repository & Engineering Charter
