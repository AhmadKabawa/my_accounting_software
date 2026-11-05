# Architecture Documentation Rebuild — Validation Record

- **Date:** 2026-11-04
- **Base branch:** `vscode`
- **Working branch:** `docs/architecture-rebuild`
- **Scope:** Documentation and Markdown only

## Scope integrity

- No Dart source files were changed.
- No `pubspec.yaml`, platform, build-configuration, backend, or database files were changed.
- The branch was created from `vscode`; its merge base remains the `vscode` head used at branch creation.
- The branch contains documentation commits only and has not been merged into `vscode` or `main`.

## Static checks performed

- Checked relative Markdown links across the architecture documentation, root README, and agent entry-point documents: **26 links checked across 16 Markdown files; no broken targets found** at the time of the check.
- Checked the test names listed in `CORE_MAP.md` against the repository tree: every listed test file exists.
- Inspected the six reported naming mismatches against source files and updated the map to use the actual names:
  - `AppAppBar`
  - `MyNavObserver`
  - `AppValidator` / `ValidationRule`
  - `AppPathImage` / `AppPathImages`
  - `DirectionExtension`
  - `MyDartLoader`
- Confirmed the old `CORE_CONTRACT.md` and `FEATURE_GUIDE.md` are retained in `archive/` with the same Git blob SHAs as the originals; the superseded paths were removed after archival.
- Confirmed the current repository tree has no `.github/workflows/` files. `analysis_options.yaml` includes `flutter_lints` and no architecture-import lint configuration was found.

## Not run / not verified

- `dart format`, `flutter analyze`, `flutter test`, and platform builds were **not run** as part of this GitHub documentation-only operation.
- Architecture boundaries are therefore documented policy, not automatically enforced CI checks.
- `BlocEffectListener` remains **`NOT_VERIFIED`** for analyzer/lifecycle concerns until `flutter analyze` and a focused widget test are run in a Flutter SDK environment.
- The presence of test files is not evidence that those tests pass.

## Outcome

The active documentation now has distinct responsibilities: architecture policy, Core discovery, usage examples, coding standards, feature completion checklist, and ADR history. Superseded architecture guides remain available in the archive and are no longer presented as current policy.
