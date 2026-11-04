---
name: core-usage
description: Use when implementing or changing any Flutter feature that may need shared infrastructure, responsive UI, theme, localization, widgets, networking, storage, errors, routing, permissions, state management, or dependency injection. Enforces discovery and reuse of the existing app Core before creating new code.
---

# Core Usage Workflow

1. Read `AGENTS.md`.
2. Read `docs/architecture/CORE_MAP.md` to discover the current shared APIs.
3. Read the relevant sections in `docs/architecture/CORE_USAGE.md` and `ARCHITECTURE_RULES.md`.
4. Search the actual source under `lib/app/core/`; documentation may be stale.
5. Inspect the implementation, imports/exports, call sites, and tests of the candidate API.
6. Prefer the existing API when it meets the requirement.
7. Extend an existing API only when the change preserves its responsibility and compatibility.
8. If no suitable API exists, decide:
   - Core: cross-cutting, feature-independent infrastructure or design-system capability.
   - Feature: business logic or UI behavior specific to one feature.
9. Add tests for new shared behavior and update CORE_MAP/CORE_USAGE.
10. In the final report, state which Core APIs were reused, which new shared APIs were added (if any), and what validation actually ran.

Never create a parallel helper/service/widget/network/error/theme/state-management system just because the existing Core API was not discovered.
