# Accounting Software

Flutter client application for the accounting system. The repository is organized around feature modules and shared application infrastructure under `lib/app/core`.

> The repository is under active development. A documented capability or planned platform is not evidence that the complete feature has shipped or been validated.

## Project structure

- `lib/app/core/` — shared infrastructure, design system, localization, routing, state-management foundations, networking, storage, and access utilities.
- `lib/app/features/` — feature-specific application modules.
- `config/` — build-time client configuration examples.
- `docs/architecture/` — current architecture policy, Core map, usage examples, coding standards, feature checklist, and ADRs.

## Architecture documentation

Start with the [Architecture Documentation Index](docs/architecture/README.md).

Key references:

- [Architecture Rules](docs/architecture/ARCHITECTURE_RULES.md) — authoritative Core boundaries and layer dependency rules.
- [Core Map](docs/architecture/CORE_MAP.md) — shared API discovery and known limitations.
- [Core Usage](docs/architecture/CORE_USAGE.md) — examples for existing Core APIs.
- [Coding Standards](docs/architecture/CODING_STANDARDS.md) — Dart and Flutter conventions.
- [Feature Checklist](docs/architecture/FEATURE_CHECKLIST.md) — implementation and completion review.
- [Architecture Decision Records](docs/architecture/ADR/README.md) — recorded decisions.

## Requirements

Install a Flutter SDK compatible with the project's declared SDK constraints, then resolve packages:

```sh
flutter pub get
```

Check the Flutter and Dart versions expected by the project in `pubspec.yaml` before selecting a toolchain.

## Configuration

Client settings are injected at build time and are **not committed**:

1. Copy the example file:
   `cp config/dart_defines.example.json config/dart_defines.json`
2. Fill in the values:
   - `SUPABASE_URL` and `SUPABASE_ANON_KEY` — required by the application configuration.
   - `GOOGLE_CLIENT_ID` — the OAuth Web client ID; required for Web authentication, while Android/iOS use their platform configuration.
3. Run with the file:

```sh
flutter run --dart-define-from-file=config/dart_defines.json
```

`config/dart_defines.json` is git-ignored. Only the public Supabase anon key belongs in the client configuration. Never place a Supabase `service_role` key or another server secret in Flutter code, build defines, or the repository.

For a release build, provide the same configuration through the corresponding build command and protect the configuration values in your build environment.

## Quality checks

Run the checks available in your local Flutter environment before submitting changes:

```sh
dart format .
flutter analyze
flutter test
```

Run platform builds separately for each target you intend to support. Report which commands actually ran; do not infer successful analysis, tests, or platform support from static inspection.

## Contribution workflow

1. Read `AGENTS.md` and the relevant architecture references.
2. Work on a dedicated branch.
3. Keep each change focused and reviewable.
4. Add or update tests for behavior changes.
5. Update architecture documentation when shared APIs or their contracts change.
6. Summarize changed files, checks run, and known limitations in the commit or pull request.
