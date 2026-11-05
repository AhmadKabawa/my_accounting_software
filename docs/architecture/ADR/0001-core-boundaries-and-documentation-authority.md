# ADR-0001: Core Boundaries and Architecture Documentation Authority

- **Status:** Accepted
- **Date:** 2026-11-04
- **Decision owners:** Project maintainers
- **Scope:** Flutter client architecture and shared Core capabilities

## Context

The repository has accumulated several documents describing Core reuse, feature structure, and coding expectations. Some older guidance treated every existing Core utility as mandatory for every matching use case, while the current architecture requires evidence of shared responsibility and real consumers before promoting feature code into Core. Repeated rules also drift when copied into agent instructions and feature guides.

The application uses a feature-first structure, a shared Core, GetIt for dependency injection, Cubit/Bloc for state management, Dio for HTTP, and a shared responsive/theme/localization design system. Documentation must describe the code that exists rather than promise unimplemented services or behavior.

## Decision

1. **Core is for stable cross-cutting capabilities**, not feature business logic or a general dumping ground.
2. A capability belongs in Core only when it is independent of Features, genuinely cross-cutting, has a real second consumer or a strong technical justification, and exposes a focused testable contract.
3. Before adding a shared helper, widget, service, extension, or abstraction, inspect the map and then verify the implementation, callers, imports, and tests. Reuse or extend a suitable API rather than creating a parallel system.
4. **`ARCHITECTURE_RULES.md` is the sole policy authority** for Core boundaries, layer dependencies, and architectural decisions.
5. **`CORE_MAP.md` is a discovery map**, not proof that an API is production-ready. It must distinguish implementations from contracts/stubs and disclose known limitations and test gaps.
6. **`CORE_USAGE.md` contains usage examples** and must match actual signatures.
7. **`CODING_STANDARDS.md` contains practical Dart/Flutter conventions**. `FEATURE_CHECKLIST.md` is the implementation/review checklist.
8. `AGENTS.md`, `CLAUDE.md`, and the Core usage Skill should point to the authoritative documents instead of duplicating their policy.
9. Historical plans and superseded guidance are archived without being treated as current instructions.
10. Documentation-only changes must not silently alter Dart behavior, package configuration, platform files, or backend/database behavior.

## Consequences

### Positive

- There is one clear place to change architecture policy.
- Discovery, policy, examples, coding style, and delivery checks have separate responsibilities.
- Existing APIs can be documented honestly, including incomplete contracts and missing tests.
- Agent instructions are shorter and less likely to drift.

### Trade-offs

- Contributors must open the relevant reference instead of relying on a duplicated summary.
- The Core map requires maintenance when shared APIs or their contracts change.
- Some existing Core widgets may have limitations or feature-specific details that prevent treating them as universally reusable.

## Validation

This ADR records a documentation and architecture-policy decision. It does not claim that architecture rules are enforced by CI or that Flutter analysis/tests have run. Those claims must be based on actual configured checks and executed commands.
