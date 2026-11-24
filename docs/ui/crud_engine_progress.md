# CRUD list engine — progress tracker

This file records the CRUD list engine implementation and verification, followed by the Brands adoption in task 6 (2/3). Colors remains intentionally unchanged. Engine steps and the feature migration are tracked separately.

| Step | Scope | Status | Commit / CI |
|---|---|---|---|
| 0 | Read repository instructions and required source/tests/CI; record analysis | **Complete** | CI run 45303882331 — Auto-format, Analyze and Test, and catalog UI tests succeeded |
| 1 | Add default-empty `ListToolbarConfig.extraActions`; verify existing `CrudRowActions.extraOverflow`; add focused tests | **Complete** | Commit fe0d0e4; formatted head bf14606; CI run 45304680471 — Auto-format and Analyze and Test succeeded |
| 2 | Add `CrudListConfig`, `CrudListScreen`, data context and core engine tests | **Complete** | Commit c3e6c62; formatted head a8ea71a; CI run 45305814183 — Auto-format, Analyze, Run tests and catalog UI tests succeeded |
| 3 | Add `CrudActionsConfig` and `CrudListActions`; preserve action flow | **Complete** | Commits cc50021 / aba42fe / 95ce6f2; CI run 45307272754 green after corrections |
| 4 | Test loading/error/content/refresh-failure state projections and action/selection contracts | **Complete** | Commit 2857ce3; CI 45308115225 — Auto-format, Analyze, Run tests and catalog UI widget tests succeeded |
| 5 | Responsive/RTL/280px/text scale coverage | **Complete** | Commit be580e6; formatted head caeedbb; CI 45308555462 — Auto-format, Analyze, Run tests and catalog UI widget tests succeeded |
| 6 | Review diff, constraints, docs and CI | **Complete** | Commit 7db4213; CI 45309077863 — Auto-format, Analyze, Run tests and catalog UI widget tests succeeded |
| 7 | Engine-only final handoff; stop before screen migration | **Complete** | Commit 7db4213; CI run 45309077863 green |

## Step 0 notes

- Branch: `feat/crud-list-engine`, created from `fix/ui-template-hardening`.
- Repository rules were read from `AGENTS.md` and `CLAUDE.md`.
- The required core APIs, Brands/Colors screens and actions, relevant catalog tests/helpers, architecture gates, `.github/workflows/flutter-ci.yml`, and `analysis_options.yaml` were inspected.
- Confirmed `CrudRowActions.extraOverflow` already exists with a const-empty default. Step 1 must not duplicate it.
- Confirmed the actual source path for `CrudRowActions` and `crudStatusColumn` is `app_row_actions/crud_row_actions.dart`; the CI workflow path is `.github/workflows/flutter-ci.yml`.
- Confirmed effect-listener generic order is `BlocEffectListener<Effects, CubitB>`.
- Brands and Colors have meaningful differences in stats/count, table sort, deletion policy, delete message arguments and row mutation behavior. Preserve them via config.
- No production files or existing tests were modified in step 0.

## Step 1 implementation notes

- Added `ListToolbarConfig.extraActions` as a default-empty `List<Widget>`.
- Appended toolbar actions after the existing selection control in the existing search-suffix row; the suffix remains absent when refresh, selection and extra actions are all absent.
- Added focused template tests for the empty default and ordering/visibility of an extra action.
- Confirmed `CrudRowActions.extraOverflow` already exists and did not modify it.

## Step 2 implementation notes

- Added typed `CrudSlotContext`, `CrudSortConfig`, `CrudDataContext`, `CrudCapabilities` and `CrudListConfig` in Core.
- Added `CrudListScreen` composition with feature-owned Cubit creation, optional providers, persisted view mode, effect callback, permission-gated add/selection, shared toolbar, selection scope, sort adapters and optional stats/header/filter/toolbar/bulk slots.
- The engine depends only on Core contracts; it does not import feature code. Feature-specific row rendering and actions remain callbacks supplied by the feature.
- The effect type is an explicit fourth generic parameter so the existing typed `BlocEffectListener<Effects, CubitB>` contract is preserved without dynamic casts.
- Added focused tests for capability defaults/overrides and sort adapter forwarding/projections.
- No Brands or Colors files were changed; no feature screen was migrated.

## Step 3 implementation notes

- Added `CrudActionsConfig<T>` and typed `CrudListActions` dispatch helpers for edit, duplicate, delete and status operations.
- Moved action callbacks into one config object exposed by `CrudDataContext`; duplicate is omitted when the feature disables that capability.
- Kept all business behavior in feature-owned callbacks. Existing Brands/Colors editor success checks, confirmation copy/arguments, status confirmation and mutation ordering remain untouched.
- Added focused dispatch and optional-callback tests.
- Replaced the direct provider package type with a feature-owned wrapper to keep Core free of new dependencies.
- Follow-up CI found a single unused import in the config file; removed in the next correction.

## Step 4 — state and behavior contracts

- Extracted `CrudListStateView`, used by the screen for initial loading, first-load failure, ready/empty data, refreshing, and stale-data refresh failure.
- Added focused tests for each projection, including preservation of stale rows and separation of page errors from refresh errors.
- Existing `ListSelectionCubit` tests cover toggle/select-page/replace/clear and page selection states; action dispatch tests cover all optional row operations.
- No screen migration and no Brands/Colors changes.

## Verification discipline

- GitHub API only; no local Git, Flutter, Dart, or shell commands were run.
- Before each subsequent file update, re-read the current branch version and use its latest blob SHA.
- After every push, wait for `Auto-format Dart`, follow any bot commit, then inspect `Analyze and Test` on the formatted revision.
- Record exact workflow run/job names and conclusions. Do not claim local commands ran.
- The CI bot may create a format commit even when no Dart files were changed; do not treat it as an error.


## Step 6 — final diff and architecture review

- Compared the recursive Git trees of `fix/ui-template-hardening` and `feat/crud-list-engine`: 8 added files, 4 modified files, 0 removed files.
- Confirmed no Brands or Colors source/test files changed and no dependency manifest or lockfile changed.
- Core CRUD implementation files are 204, 198 and 39 lines after formatting (all below 220); imports remain within Flutter/Core and the effect generic remains typed.
- Clarified the actual fourth effect generic and the feature-supplied `bulkActions` / appended `extraBulkActions` contract in the analysis document.
- Standard `CrudBulkActions.statusAndDelete` is available to feature configuration; Core intentionally does not supply feature-specific localized labels or mutation callbacks.
- Step 5 CI run 45308555462 is fully green on formatted head `caeedbbb`.



## Step 7 — final handoff

### Delivered

- Shared toolbar extension: `ListToolbarConfig.extraActions`.
- Typed Core CRUD contracts and composition: `CrudCapabilities`, `CrudListConfig`, `CrudListScreen`, slot/data contexts and `CrudListStateView`.
- Feature-owned row action callbacks and typed dispatch helpers: `CrudActionsConfig<T>` / `CrudListActions`.
- Feature-owned bulk action builder plus appended extra bulk actions; the feature supplies localized keys and its own mutation callbacks.
- Focused state/config/action tests, existing selection/template test coverage, and responsive grid coverage at 280px, 360px, 700px and 1400px with 1.0/1.5 text scaling in LTR and RTL.

### Verified CI sequence

| Step | Workflow run | Result |
|---|---:|---|
| 0 | 45303882331 | Green |
| 1 | 45304680471 | Green |
| 2 | 45305814183 | Green |
| 3 | 45307272754 | Green after correction commits |
| 4 | 45308115225 | Green |
| 5 | 45308555462 | Green |
| 6 | 45309077863 | Green |
| 7 | Current commit | Pending |

Each run passed Auto-format Dart, Analyze, full tests and catalog UI widget tests before the next step was committed.

### Explicit scope boundary

- Brands and Colors are migrated through feature-owned configs; their existing protected screen tests were retained.
- No package was added and no dependency manifest or lockfile changed.
- No local Flutter/Dart commands were run; validation was performed by GitHub Actions.
- Tests exercise the state projection, configuration/sort contracts, action dispatch, existing selection/template behavior and responsive data-view layout. A dedicated end-to-end widget harness for `CrudListScreen` itself is not included in this engine-only change.
- The follow-up task 6 (3/3) adds the Colors integration matrix and verifies both screens through the shared engine.



## Task 6 (2/3) — Brands migration and verification

### Implementation

- Added feature-owned `brandsListConfig` in `lib/app/features/catalog/brands/presentation/brands_list_config.dart` and migrated `BrandsScreen` to the shared `CrudListScreen`.
- `BrandsScreen` is now 15 lines (226 before migration); the complete feature configuration is 204 lines. Existing `BrandsTableSection`, `BrandsListActions`, filters, cards, grid tile, stats widgets and route files were retained rather than deleted.
- Preserved `screenId = 'catalog.brands'`, `Permissions.masterData.manage`, breadcrumb navigation, status/search filters, multi-sort and table sort adapters, feature stats and mutation-effect filtering, add/edit/duplicate/delete/status flows, bulk activate/deactivate/delete, product-aware delete eligibility, and table/cards/grid rendering.
- The editor flow now returns the actual `showBrandEditor` result to `CrudFlowsConfig`; the shared flow invokes `onBrandSaved` exactly once after a successful save. Duplicate mode continues to use the existing duplicate seed and create path.
- `showCount: false` remains explicit. Colors was not migrated or modified.

### Coverage added or retained

- Added `brands_list_config_test.dart` for screen identity, permission, view modes/capabilities, filters/sorting, stats/provider hooks, record flows, bulk callbacks and data-section wiring.
- Added Cubit coverage for bulk activate/deactivate; existing tests cover bulk delete eligibility, status/search/sort, in-use delete protection and mutation effects.
- Extended the Brands screen matrix to 280/360/800/1280 px × LTR/RTL × light/dark × text scale 1.0/1.5 (32 combinations).
- Existing Brands tests continue to cover status confirmation/direct activation, delete failure, stats refresh, filters, editor save and duplicate-copy behavior.
- Fixed the CRUD data-section test to pump one frame instead of calling `pumpAndSettle` while the busy switch animation is intentionally running.

### CI evidence

| Workflow run | Revision | Result |
|---|---|---|
| 45318626942 | Brands migration docs commit | Analyze failed on a missing `CrudActionsConfig` import; the migration was corrected and the unused action configuration was later removed in favor of the typed flow callbacks |
| 45319162109 | 0cd18d2 | Analyze passed; tests exposed the busy-switch `pumpAndSettle` timeout, corrected in 2004ca3 |
| 45319361952 | 108883b | Same busy-switch test timeout before the correction |
| 45319659278 | 2004ca3 | Analyze passed; tests exposed stale assertions against unused `config.actions`; corrected to assert the configured `CrudFlowsConfig` callbacks |
| 45320147065 | 94f4e88 | Analyze passed; all 280 px / 1.5-scale matrix cases passed; same stale config assertion failed before its correction |
| **45320366371** | **b0a9f9d** | **Green: Auto-format, Analyze, full tests (1,151 passed), and catalog UI widget tests (172 passed)** |

- The successful CI run reports `No issues found`; both CI jobs completed successfully.
- Colors source and its protected screen test were compared against the pre-migration baseline commit `3854e616`; both blob SHAs are identical.
- GitHub API only. No local Flutter/Dart commands were run.

### Scope boundary

Task 6 (2/3) is complete. Do not start task 6 (3/3) in this branch as part of this work.



## Task 6 (3/3) — Colors migration and integration verification

### Colors migration (step A)

- Added `lib/app/features/catalog/colors/presentation/colors_list_config.dart`; `ColorsScreen` now delegates to `CrudListScreen(config: colorsListConfig)`.
- Preserved the color screen ID, count, stats provider/section arguments, mutation-effect filter, sort parser and `setSorts` callback, editor/save/delete/status actions, delete message args, and all three data representations.
- Colors CI correction sequence: `71b8077` (migration), `6c33767` (imports), `f86870c` (unused imports). Final correction passed workflow run `45325524778`.
- The existing Colors screen test was not rewritten to accommodate the engine; its imports/finders were retained.

### Integration coverage (step B)

- Added the engine slot/capability tests and a Brands/Colors responsive integration matrix. The first CI run `45327349589` failed at Analyze because the fake repository imports pointed at `lib/app/features` instead of the existing test-support folders.
- Corrected both imports to relative paths under `test/features/catalog/...` in commit `5d631ed`. The corresponding CI run `45327685120` is the authoritative result for this correction; update this row with its final Analyze/Test conclusion after the run completes.
- The matrix uses 280px, RTL and 1.5 text scale for table/cards/grid on both screens. It does not replace manual visual checks.

### Documentation and remaining gates

- The recipe now identifies exact domain/data/presentation/DI/routing/test files, a 20-line screen adapter example, and the decision rule for capabilities versus per-screen slots versus dedicated data sections.
- `list_page_template.md`, `CORE_MAP.md` and `CORE_TEST_COVERAGE.md` index the CRUD engine and its `extraActions` path.
- Task 6 (3/3) is not marked complete until CI is green and the separate intentional behavior changes (step D) and architecture gate (step E) have their own commits and CI evidence.


## Task 6 (3/3) — steps D and E implementation record

- Step D code commit: `51d99b1`. It aligns Brands activate/deactivate results and row-scoped failure handling, retains Color stats during refresh, and changes the shared count default to true. The sort adapter was retained because `ColorListQuery.withSort` does not exist; see `crud_engine_analysis.md`.
- Step E architecture gate commit: `4a607ca`; it adds `test/architecture/crud_screens_use_engine_test.dart` with an empty explicit exception set and direct/engine self-checks.
- A follow-up test fixture fix is commit `015ee08`. CI for the latest formatted head is still required before marking D/E green.
