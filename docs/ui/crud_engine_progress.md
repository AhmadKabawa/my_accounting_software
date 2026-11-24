# CRUD list engine — progress tracker

This file records the CRUD list engine implementation and verification, without migrating Brands or Colors. Each implementation/review step has an independent commit; do not begin the next step until the prior step is green on CI's formatted revision.

| Step | Scope | Status | Commit / CI |
|---|---|---|---|
| 0 | Read repository instructions and required source/tests/CI; record analysis | **Complete** | CI run 45303882331 — Auto-format, Analyze and Test, and catalog UI tests succeeded |
| 1 | Add default-empty `ListToolbarConfig.extraActions`; verify existing `CrudRowActions.extraOverflow`; add focused tests | **Complete** | Commit fe0d0e4; formatted head bf14606; CI run 45304680471 — Auto-format and Analyze and Test succeeded |
| 2 | Add `CrudListConfig`, `CrudListScreen`, data context and core engine tests | **Complete** | Commit c3e6c62; formatted head a8ea71a; CI run 45305814183 — Auto-format, Analyze, Run tests and catalog UI tests succeeded |
| 3 | Add `CrudActionsConfig` and `CrudListActions`; preserve action flow | **Complete** | Commits cc50021 / aba42fe / 95ce6f2; CI run 45307272754 green after corrections |
| 4 | Test loading/error/content/refresh-failure state projections and action/selection contracts | **Complete** | Commit 2857ce3; CI 45308115225 — Auto-format, Analyze, Run tests and catalog UI widget tests succeeded |
| 5 | Responsive/RTL/280px/text scale coverage | **Complete** | Commit be580e6; formatted head caeedbb; CI 45308555462 — Auto-format, Analyze, Run tests and catalog UI widget tests succeeded |
| 6 | Review diff, constraints, docs and CI | **Complete** | Commit 7db4213; CI 45309077863 — Auto-format, Analyze, Run tests and catalog UI widget tests succeeded |
| 7 | Final handoff; stop before any screen migration | **Complete** | Final handoff recorded in this commit; CI pending |

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

- Brands and Colors screens and their protected tests remain unchanged; no feature migration was performed.
- No package was added and no dependency manifest or lockfile changed.
- No local Flutter/Dart commands were run; validation was performed by GitHub Actions.
- Tests exercise the state projection, configuration/sort contracts, action dispatch, existing selection/template behavior and responsive data-view layout. A dedicated end-to-end widget harness for `CrudListScreen` itself is not included in this engine-only change.
- A future adoption task should first add that focused screen integration harness, then migrate one feature at a time while preserving its editor/confirmation/effect behavior.

