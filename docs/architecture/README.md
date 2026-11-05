# Architecture Documentation

This directory contains the current architecture guidance for the Flutter client. The documents have deliberately separate responsibilities so that policy, discovery, examples, coding style, and delivery checks do not drift through repeated copies.

## Start here

| Need | Document | Authority |
|---|---|---|
| Understand the architecture and decide where code belongs | [Architecture Rules](ARCHITECTURE_RULES.md) | **Normative policy** for Core boundaries and layer dependencies |
| Find an existing shared API and understand its actual status | [Core Map](CORE_MAP.md) | Discovery map; verify source code before use |
| See how to call shared APIs | [Core Usage](CORE_USAGE.md) | Usage examples; source signatures remain authoritative |
| Follow Dart/Flutter implementation conventions | [Coding Standards](CODING_STANDARDS.md) | Coding guidance, subordinate to architecture policy |
| Review a feature before completion | [Feature Checklist](FEATURE_CHECKLIST.md) | Delivery checklist |
| Understand recorded architecture decisions | [ADR index](ADR/README.md) | Decision history |
| Review the documentation rebuild's validation and limits | [Rebuild Validation](REBUILD_VALIDATION.md) | Static evidence and unrun checks |

## Agent entry points

- [AGENTS.md](../../AGENTS.md) contains repository-wide instructions and links to these references.
- [CLAUDE.md](../../CLAUDE.md) points Claude to the same authoritative guidance.
- [Core usage Skill](../../.claude/skills/core-usage/SKILL.md) applies only when editing Core, adding a shared capability, or consuming a relevant Core API.

Agent entry points should link to these documents rather than copy their detailed rules.

## Validation and evidence

- The implementation and tests are authoritative for what currently exists.
- A map entry does not mean the capability is complete, used, secure, or production-ready.
- Missing direct tests, incomplete contracts, and unverified analyzer concerns must be stated explicitly.
- Do not claim that a check passed unless it was actually run. Static inspection is not a substitute for `flutter analyze`, tests, or platform builds.

## Archived guidance

[archive/README.md](archive/README.md) explains superseded architecture documents retained for historical reference. Archived material is not current policy and must not override the documents listed above.
