---
name: core-usage
description: Use only when (1) editing files under lib/app/core directly, (2) creating a new shared capability that may belong in Core, or (3) a feature genuinely needs an existing shared Core capability (shared UI/responsive/theme, network, storage, errors, localization, access, DI). Do NOT use for ordinary feature work that needs no shared Core capability.
---

# Core Usage Workflow

1. Read `docs/architecture/CORE_MAP.md` first to find the existing shared API.
2. Inspect the actual code under `lib/app/core/`: definition, signature, call sites, and tests. The map may be stale.
3. Reuse the existing API when it fits; extend it only if its responsibility and compatibility are preserved.
4. Read `docs/architecture/ARCHITECTURE_RULES.md` only when deciding to add or change Core (or to keep code in a Feature).
5. Read `docs/architecture/CORE_USAGE.md` only when you need a usage example.
6. When a shared capability is added or changed, update its tests, `CORE_MAP.md`, and `CORE_USAGE.md` if the pattern changed.
7. In the final report state which Core APIs were reused, which shared APIs were added (if any), and what validation actually ran.

Do not read all three docs in full for every task. Never create a parallel helper/service/widget/network/error/theme system because an existing Core API was not discovered.
