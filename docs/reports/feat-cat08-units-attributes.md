# CAT-08 Units, Option Sets and Attributes — implementation report


## Stage 0 — architecture audit and specification correction (2026-11-26)

### A. Pattern extracted from Categories and adopted for CAT-08

| Concern | Pattern observed in Categories / CAT-07 | CAT-08 decision |
|---|---|---|
| Screen composition | Thin `CrudListScreen` + feature-owned `CrudListConfig`; feature-specific data sections/widgets stay outside the config. | All three screens use the shared CRUD engine; each config stays below 250 lines. |
| List state | `PagedListCubit` with sealed/Equatable feature effects, query reset, 300 ms debounced search, latest-request-wins. | Server-backed paging/search/filter/sort; no client-only aggregate calculations. |
| Data access | Feature-owned endpoint and remote data source over `IApiClient`; Supabase pagination parser; escaped PostgREST search; stable `id` tie-break. | No sibling-feature imports; Attributes owns lightweight Units/Option Sets lookup reads. |
| Statistics | Dedicated lightweight count requests and `ListStatsBar`; stats failure must not block list loading. | Units and Option Sets: all/active/inactive. Attributes: all/active/inactive/filterable. Counts are server-derived. |
| Details | Categories has a desktop `AppDetailsPanel` and a narrow-screen bottom sheet. | Units: no details panel. Option Sets: details panel/bottom sheet owns lazy-loaded options. Attributes: no details panel. |
| Editor | `CrudEditorDialog` in `showAppFormDialog`; feature-owned validation through `AppValidator`; dirty guard compares normalized saved values. | Trimmed name/code/symbol values are compared exactly as submitted; create sends active=true, PATCH sends status only when changed. |
| Permissions | `CrudListConfig.manageAccess = Permissions.masterData.manage`; read access stays open; route does not add a role guard. | Same policy for all CAT-08 screens. |
| Usage/deletion | PostgREST relationship `count`; null means unknown, not zero; unknown blocks deletion. Database FK remains final authority. | Custom feature confirmation offers deactivate after a 23503 FK failure; duplicate 23505/409 and business codes map to translated feature failures. |
| Localization | Feature-owned `AppKey` enums with Arabic and English; domain failures live under `domain/failures`. | UnitsKeys, OptionSetsKeys, AttributesKeys and one failure-key enum per feature; no ARB or raw server messages. |
| Tests | Model/repository fake-client tests, Cubit race/debounce tests, widget tests through `pumpScreenMatrix`, architecture checks. | CAT-08 adds request/body/error assertions and responsive RTL/LTR light/dark coverage at 360/600/900/1200. |

### B. What changed in Categories after its specification, and what the CAT-08 drafts had omitted

| Categories implementation/spec evolution | Missing or under-specified in the original CAT-08 drafts | Correction made in the CAT-08-owned specs |
|---|---|---|
| Categories moved onto `CrudListScreen` + `CrudListConfig`, with a feature-owned data section. | The CAT-08 drafts described fields and actions but did not mandate the CRUD engine composition. | All three CAT-08 screens must use the CRUD engine; no hand-built list template. |
| Categories gained server-backed stats, clickable stats cards and independent stats failure handling. | Stats were not explicit enough, and did not state that counts must be server-derived. | Added exact stat sets and prohibited page-derived aggregates. |
| Categories gained a desktop details panel and mobile bottom sheet. | The drafts did not explicitly decide whether each CAT-08 screen has a details panel. | Units/Attributes: none; Option Sets: panel + bottom sheet for nested options. |
| Categories supports duplicate and bulk flows, but these are feature decisions, not defaults. | CAT-08 had no explicit bulk/duplicate matrix. | Units: both false; Option Sets: both false; Attributes: duplicate true, bulk false. |
| Categories explicitly sends `is_active` on create and only sends it in PATCH when changed. | CAT-08 drafts did not spell out the payload rule. | Added create/status/PATCH payload requirements to each spec. |
| Categories protects unsaved edits with a normalized dirty guard and feature-owned validators. | CAT-08 drafts lacked a precise trim-equivalent dirty rule and did not consistently mandate `AppValidator`. | Added `trim()`-equivalent dirty comparison and AppValidator-only field validation. |
| Categories has dedicated loading/empty/no-results/error states, translated failures, unknown-count handling and FK fallbacks. | CAT-08 drafts lacked a complete state/error contract. | Added state matrix, feature failure keys, unknown-count blocking and 23503/23505/ERP mappings. |

### C. Corrected feature decisions

- **Units:** server stats all/active/inactive; status and type filters; name + `id` sorting; updated-at column; no details panel, bulk or duplicate; no conversion fields in UI or payload; unknown usage blocks delete; status on create and only-if-changed PATCH.
- **Option Sets:** server stats all/active/inactive; no bulk or duplicate; lazy-load option rows only when the set opens; sort options by `sort_order`, then `name`, then `id`; never delete individual options; lock selection type for positive or unknown usage; hide group delete for any option/reference/unknown count.
- **Attributes:** server stats all/active/inactive/filterable; duplicate enabled with a unique `-copy` code seed; bulk and details panel disabled; option-set relation iff data_type is option; changing type clears incompatible IDs; current inactive lookup remains visible while editing; lock data_type and option_set_id for positive or unknown usage.
- No Categories, Brands, Colors, Core, backend schema, migration, RPC, view, dependency, or BACKEND_REQUESTS file is changed by the final CAT-08 tree.

### D. CI baseline and branch policy

- Run `45889013226` (commit `a96f869e`): auto-format succeeded; Analyze succeeded; tests failed with 13 failures (12 pre-existing Categories widget/domain failures plus the CAT-08 OptionSets key-prefix registry failure).
- Run `45889825902` (temporary commit `977...`): auto-format failed while an out-of-scope Categories experiment was present. That experiment was reverted; no Categories changes remain in the final tree.
- Run `45889964780` (commit `20ba26ea`): auto-format succeeded; Analyze succeeded; tests still fail on the 12 Categories failures. The OptionSets key-prefix failure is resolved. The CAT-08 domain tests visible in this run pass.
- No local Flutter/Dart commands were run. The GitHub Actions runner is the only Flutter verification environment available.
- Branch updates use the latest fetched branch SHA and a non-forced compare-and-swap ref update; no other branch is merged, rebased into, or modified. No PR is opened.

## Branch and scope

- Branch: `feat/cat08-units-attributes`
- No merge, pull request, or changes to another branch were made.
- GitHub CI is used as the gate after each pushed phase. Local Flutter/Dart commands are not available in this workspace.
- No local Flutter/Dart SDK or project workspace was available. Formatting, analysis and tests have not been run locally.

## Implemented in this work

### Units
- Domain entity and draft, paged query and deletion guard based on known usage.
- PostgREST endpoint, model mapping, remote data source, repository contract and implementation.
- Use cases for list/create/update/status/delete.
- Dependency registration in the Catalog composition root.
- Domain tests for query reset/filter behavior and safe deletion.

### Option Sets
- Domain entities for sets and nested options, draft types and paged query.
- Endpoint constants and response model including option ordering fields and relationship usage counts.
- Remote data-source contract and implementation for group CRUD/status and option create/update/deactivate.
- No option deletion method is exposed.

### Attributes
- Domain entity, draft and paged filters.
- Endpoint constants and model mapping for unit/option-set lookup metadata and usage counts.
- Remote data-source contract and implementation for attribute list/create/update/status and independent read-only Unit and Option Set lookup sources.
- Domain test for conservative in-use behavior when counts are unknown.

## Not completed

This is a partial foundation, not a complete CAT-08 feature delivery. The following remain:
- Option Sets and Attributes repository implementations, use cases and DI registrations.
- Units/Option Sets/Attributes Cubits, states/effects, editor dialogs, list configs, screens, stats and filter widgets.
- Route registration and Catalog hub integration for all three screens.
- Arabic/English AppKey translations.
- Full unit, data-source, repository, Cubit and responsive UI test matrix.
- Full verification of PostgREST relationship names, constraints and response shapes against the deployed backend schema.

## Important verification notes

- No backend schema, migrations, RPCs, views, packages, or backend request documents were changed.
- The feature code is written against the existing REST client and shared paginated-list contracts.
- Relationship counts are treated as unknown when the response does not contain a parseable count; deletion/structural changes are conservatively blocked by domain getters.
- The project owner should run formatter, analyzer and the relevant test suite before considering this branch ready.

## Follow-up additions

After the initial report draft, the branch also gained:
- Option Sets and Attributes repository contracts and adapters.
- List/create/update use cases for Option Sets and Attributes.
- Dependency registrations for Units, Option Sets and Attributes in `initCatalogDI`.
- Arabic/English AppKey localization enums for all three features.
- Query and usage-guard tests for Option Sets and Attributes.
- Attribute draft serialization explicitly clears `unit_id` and `option_set_id` when the selected data type no longer supports them.

## Remaining blockers to a complete feature

The branch still does not contain the actual presentation implementation: no Cubits/states/effects, CRUD list configs, screens, editor dialogs, stats widgets, route registration, or Catalog hub cards. Option and Attribute mutation use cases for nested options/status/lookup choices also need to be completed and surfaced through presentation. The current localization enums are foundations and are not yet consumed by screens. Accordingly, do not treat this branch as ready to merge or as completion of CAT-08.

## Repository audit update — 2026-11-26

This section supersedes earlier progress statements where the branch has since gained files. The report above is retained as historical context.

### Current observed implementation

- Units: Domain, Data, DI, list/form Cubits, editor dialog, list config, screen, localization and route descriptor exist. The list config is still incomplete against the accepted specification: it supplies no filter controls, no active filters, no statistics cards and no functional sort mapping. The editor and data source do include the active-state field and omit conversion fields.
- Option Sets: Domain, Data, repository adapter, DI, localization and a route descriptor exist. The remote data source exposes group CRUD/status and option create/update/deactivate. There is no option-set screen, list config, Cubit, editor, nested options page, or UI wiring.
- Attributes: Domain, Data, repository adapter, DI, localization and a route descriptor exist. The remote data source exposes list/create/update/status and independent read-only unit/option-set lookups. There is no attributes screen, list config, Cubit, editor, or UI wiring.
- Shared registration: key registry, route registry, route guards and Catalog DI include CAT-08 types. The router and Catalog hub include Units only. The sidebar destinations do not include Units, Option Sets or Attributes. No screen route can be considered delivered for Option Sets or Attributes merely because a RouteItem descriptor is registered.
- Tests visible in the branch diff are primarily Domain/query tests. Required DataSource/Repository/Cubit/widget matrix coverage is not present in the compared file list.

### Branch ancestry and integration risk

- feat/cat08-units-attributes exists.
- Compared with the current feat/cat07-categories-ui, the branch is diverged: 37 commits ahead and 24 behind; merge base is b4b9d19a4500b52fa6abc5c3d8cc2bcaebab5f5a. The current Categories branch tip reported by GitHub is 7ccb243d02403dbd084d05c23566819da99fd2e5.
- vscode is not the newer integration base: it is 193 commits behind feat/cat07-categories-ui; CAT-08 is 206 commits ahead of vscode.
- The compare against feat/cat07-categories-ui includes edits to Categories files and shared route/access files. These must be reviewed and reconciled before merge. Do not merge this branch as-is or force-move its ref.

### Verification

- No Flutter/Dart SDK is available in this work environment. flutter analyze, flutter test, formatting and builds have not been run here.
- A branch-head SHA and associated CI run could not be established through the available GitHub connector response, so CI status for the existing branch is not verified.
- No live Supabase/PostgREST schema access was used. Relationship embedding/count behavior and deployed constraints remain unverified.
- The earlier report statement that no CI run was used is historical and is not evidence of a passing CI run.

### Remaining work before completion

1. Reconcile the branch with the current CAT-07 tip without losing CAT-08 work or overwriting CAT-07 changes.
2. Complete Units filters, statistics, sort behavior, sidebar registration and the required tests.
3. Implement Option Sets list/editor/Cubit and the nested options route/page with option create/update/deactivate.
4. Implement Attributes list/editor/Cubit, type-dependent selectors, in-use locks and duplicate behavior.
5. Add all required DataSource, Repository, Cubit, screen and responsive matrix tests, including request-body assertions and race/debounce behavior.
6. Complete the CAT-08 report sections for field coverage, acceptance criteria, integration blocks, CI runs and proposed backend requests only after the corresponding evidence exists.

Status: partial implementation; not merge-ready.

## Implementation progress update — 2026-11-26 (continued)

### Units follow-up
- Unit status/type filter changes now reset pagination to page 1.
- The list table now includes the localized last-updated column.
- Units is registered in the Catalog sidebar and appears immediately after Brands in the Catalog hub.
- Added a sidebar destination assertion and filter-query pagination coverage.

### Option Sets presentation now added
- Added the paged list Cubit, server-stats Cubit/state, create/update form Cubit/effects, editor dialog and launcher.
- Added status filtering, name sorting, server-derived all/active/inactive statistics, and the CRUD list screen/config.
- Registered the Option Sets screen in the Catalog router, sidebar and hub, and added its presentation Cubits to Catalog DI.
- Opening a set lazily fetches its options. The options dialog supports create, update and activate/deactivate; no option-delete action is exposed.
- The selection-type field is disabled when usage is positive or unknown. Group deletion remains blocked unless both option count and usage count are known to be zero.

### Latest verified CI baseline
- Run 45908018318 (tested commit 76962d9a00fc68920d7ae0426220e04466473c45): Auto-format succeeded and Analyze succeeded. The test job reported 1322 passed and 12 failed; all 12 failures were in Categories widget tests, outside CAT-08.
- The same run verified the Units sidebar test and passed the UI quality gate after replacing the hard-coded missing-value placeholder with the localized common key.
- The Option Sets presentation additions pushed after that tested commit have not yet been covered by a completed CI run.
- No local Flutter/Dart commands were run. No merge or pull request was created.

### Still outstanding
- Option Sets presentation tests, including list Cubit, editor, lazy options loading, option mutations, and responsive dialog behavior.
- Attributes presentation and its type-dependent unit/option-set selectors, usage locks and duplicate flow.
- Move Attribute lookup choice models out of the Data layer into Domain to restore the dependency direction.
- Full CAT-08 test matrix and a final CI run on the latest branch head.


### Follow-up verification note
- Run 45908472416: Auto-format succeeded, but Analyze found two implementation errors (the options dialog used an unsupported Wrap parameter and the shared CRUD data context made its new BuildContext field required for existing callers). It also reported two unused imports.
- Corrected the dialog layout, registered the options Cubit in DI, removed unused imports, and made the CRUD data context optional for existing callers while the CRUD screen supplies it. A fresh CI run is required to verify these corrections and the Option Sets additions.
