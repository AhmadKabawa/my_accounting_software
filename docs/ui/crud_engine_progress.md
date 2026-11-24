# CRUD list engine — progress tracker

This file is the hand-off record for task 6 (parts 1–3). Update it after each independently committed step. Do not begin the next step until the current step has a green Analyze and Test result on CI's formatted revision.

| Step | Scope | Status | Commit / CI |
|---|---|---|---|
| 0 | Read repository instructions and required source/tests/CI; record analysis | **Complete** | CI run 45303882331 — Auto-format, Analyze and Test, and catalog UI tests succeeded |
| 1 | Add default-empty `ListToolbarConfig.extraActions`; verify existing `CrudRowActions.extraOverflow`; add focused tests | **Complete** | Commit fe0d0e4; formatted head bf14606; CI run 45304680471 — Auto-format and Analyze and Test succeeded |
| 2 | Add `CrudListConfig`, `CrudListScreen`, data context and core engine tests | **Committed; CI pending** | CRUD composition, typed slots and focused config/sort tests |
| 3 | Add `CrudActionsConfig` and `CrudListActions`; preserve action flow | Not started | — |
| 4 | Complete engine tests: load/error/content/refresh failure, selection/view mode, effects, slots, actions | Not started | — |
| 5 | Responsive/RTL/280px/text scale coverage and final architecture checks | Not started | — |
| 6 | Review diff, constraints, docs and CI | Not started | — |
| 7 | Final report; stop before any screen migration | Not started | — |

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

## Verification discipline

- GitHub API only; no local Git, Flutter, Dart, or shell commands were run.
- Before each subsequent file update, re-read the current branch version and use its latest blob SHA.
- After every push, wait for `Auto-format Dart`, follow any bot commit, then inspect `Analyze and Test` on the formatted revision.
- Record exact workflow run/job names and conclusions. Do not claim local commands ran.
- The CI bot may create a format commit even when no Dart files were changed; do not treat it as an error.
