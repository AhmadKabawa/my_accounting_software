# CRUD list engine — repository analysis

## Scope and evidence

This analysis records the CRUD engine design and both catalog adoptions on `feat/crud-list-engine`. Brands and Colors now use the same engine with feature-specific configuration; their deliberate behavior differences remain in their adapters and Cubits. The source of truth is the code and CI configuration, not the names proposed in the task.

Reviewed: `AGENTS.md`, `CLAUDE.md`, both catalog list screens and action classes, paged-list state/cubit/query, list template and toolbar/add-action configuration, selection and bulk actions, row actions/status column, confirmations, filter/sort mapping, view-mode cubit/settings, effect mixin/base cubit/effect listener, relevant Brands/Colors widget tests, test helpers, architecture gates, `.github/workflows/flutter-ci.yml`, and `analysis_options.yaml`.

## Matched behavior and contracts

| Concern | Brands | Colors | Engine decision |
|---|---|---|---|
| List state | `BrandsListState` is an alias of `PagedListState<Brand, BrandListQuery>` | Uses `PagedListState<CatalogColor, ColorListQuery>` directly | Reuse `PagedListState<T,Q>`; do not add a parallel state type |
| List cubit | Extends `PagedListCubit<Brand, BrandListQuery, BrandsListEffect>` | Extends the same base with a color effect | Keep the concrete Cubit type in the screen/provider |
| Loading | `load()` is called at provider creation | Same | Create the configured concrete cubit and call `load()` once |
| View mode | `ViewModeCubit(settings, screenId)..restore()` | Same | Preserve this construction and clear selection before selecting a new mode |
| Search/filter | Feature-owned query setters and filter-bar controls | Same shape, feature-owned setters | Configuration supplies controls and active filters; core does not know feature query fields |
| Sorting | Multi-sort maps with `mapFilterBarSorts`; header uses `setSort` | Multi-sort maps similarly; header uses `setSorts` | Separate filter sort mapping and table sort callback in `CrudSortConfig` |
| Selection | `ListSelectionCubit<Object>`, selection mode and `CrudSelectionScope` | Same | Reuse the existing selection object and standard bulk actions |
| Stats/count | `BrandStatsCubit` and `BrandStatsBar`; template count disabled | `ColorStatsCubit` and `ColorStatsSection`; template count enabled | Keep stats in feature slots; count controlled by `capabilities.showCount` |
| Effects | Typed `BrandsListEffect`; mutation refreshes stats only for `BrandsMutatedEffect` | Typed `ColorsListEffect`; mutation refreshes stats only for `ColorsMutatedEffect` | Core can expose a broad mutation callback, but adapters must preserve any feature-specific effect filtering |

## Material differences to preserve

- Brands and Colors use different editor result handlers and save callbacks (`onBrandSaved` / `onColorSaved`).
- Delete confirmation differs: Brands passes `targetName` and uses its own delete/confirm keys; Colors additionally passes `messageArgs: {'name': color.name}`.
- Both confirm deactivation and activate directly, but their Cubit implementations differ in mutation options: Brands deactivation has feature-specific behavior (including no row id / no failure flash); Colors uses the color mutation path. Do not normalize these semantics.
- Brands deletion has `beforeDelete`/in-use protection and its row delete action can be disabled through `canDelete`; preserve that callback as a per-row policy.
- Table header sorting differs: Brands calls `setSort(field:, ascending:)`; Colors parses and calls `setSorts([...])`. Keep `applyTable` feature-configurable until the dedicated sort-equivalence check in task 6 (3/3) is completed.
- Stats widgets, state types and refresh behavior remain feature-owned. The list engine must not import either feature.
- Brands currently does not pass `count`; Colors does. This is an explicit capability, not an inferred universal behavior.

## Core API observations and decisions

1. `PagedListState<T,Q>` already contains query, result, status, failure, selection mode and busy IDs. `PagedListCubit<T,Q,E>` already owns loading, refresh, selection, row/bulk mutations and typed effects.
2. `BlocEffectListener<Effects,CubitB>` is declared with effects first and `CubitB extends HasEffects<Effects>`. The engine keeps the concrete Cubit type for provider lookup and adds an explicit fourth generic `E` to `CrudListConfig` / `CrudListScreen`, constraining `C extends PagedListCubit<T,Q,E>`. This preserves the Cubit's concrete effect type without `dynamic` or weakening the Cubit provider type.
3. `CrudRowActions` already supports optional additional overflow actions through `extraOverflow = const []`. It does not need a new field; preserve the existing API. The shared `crudStatusColumn<T>` is declared in the same file.
4. `CrudConfirmations.delete` accepts title/message keys, optional message args, target name and an async Either-returning delete callback. `CrudConfirmations.status` activates directly and confirms deactivation. Do not change this helper.
5. `ListToolbarConfig` currently has no extra toolbar action list. `ListPageTemplate._toolbar` creates a search suffix only for refresh/selection controls; this is the narrow extension point for step 1.
6. `FilterBarSortOption`, `FilterBarSort`, and `mapFilterBarSorts<F,T>` are exported from the filter-bar API. Keep feature enum parsing/building in the config adapter.
7. `ViewModeCubit` persists a string by screen id and restores only recognized `AppViewMode` values.
8. `CrudSelectionScope.actionsBuilder` returns `List<BulkAction>`. The engine exposes a feature-owned `bulkActions` builder and appends `extraBulkActions` after it. A feature can use `CrudBulkActions.statusAndDelete` as its standard builder, but the engine does not invent localized labels or feature mutation callbacks.
9. `ListPageTemplate` supports `count`, `stats`, `toolbar`, `addAction`, error/refresh-error states and custom empty state. The list screen engine should compose these existing slots rather than replace the template.

## Discrepancies / cautions

- The task's shorthand paths for `CrudRowActions` and `crudStatusColumn` are not their repository paths. Both are in `lib/app/core/presentation/widgets/app_row_actions/crud_row_actions.dart`.
- `PagedListCubit`, `PagedListState`, and the compatibility export `paged_list/paged_query.dart` live under `presentation/state_management/paged_list/`; the base `PagedQuery` type itself is exported from `core/foundation/types/paged_query.dart`.
- The CI workflow is `.github/workflows/flutter-ci.yml`, not repository-root `flutter-ci.yml`.
- CI's dedicated catalog widget-test command explicitly includes `list_page_template_test.dart`, `colors_screen_test.dart`, `brands_screen_actions_test.dart`, and `brand_grid_tile_test.dart`. The workflow also runs the full `flutter test` suite.
- The actual generic contract of `BlocEffectListener` is effects-first. Keep this order in implementation.
- Both feature screens now delegate to `CrudListScreen`; feature-specific query, stats, editor, row, confirmation and mutation behavior remains in the feature-owned configs/Cubits.

## Architecture and test constraints

- Core must not import feature code; `feature_imports_test.dart` enforces this.
- Feature pages/widgets/sections are limited to 250 lines by `ui_quality_gate_test.dart`; implementation should target at most 220 lines before CI formatting.
- `no_raw_ui_in_features_test.dart` forbids raw Material UI constructors and numeric EdgeInsets in feature code; `no_magic_numbers_test.dart` checks visual numeric values in feature code and core widgets; use existing core widgets/tokens.
- `platform_isolation_test.dart` forbids platform-specific imports/checks outside the platform layer/allow-list.
- `ui_quality_gate_test.dart` also enforces localized text, no raw SnackBars, icon-only row actions and `ListPageTemplate` around list pages using AppDataView/AppDataTable.
- Test helpers provide real translations, RTL by default, memory storage, screen matrix (width/direction/brightness) and arbitrary test keys. Existing catalog tests cover permission-gated actions, selection, bulk operations, stats refresh, grid/table mode, responsive dimensions and error cases.
- CI formats Dart on push, pushes a bot commit only when formatting changes, then checks out `formatted_sha` for Analyze and Test. A format-only bot commit is not a quality failure.

## Decisions

- Reuse the existing paged list state/cubit and feature-specific concrete Cubit providers.
- Keep all feature-specific sorting, filter controls, stats, editor flows, permissions and row policy in configuration/feature widgets.
- Put global capabilities in one immutable `CrudCapabilities` value with conservative defaults.
- Keep extension slots optional and invoke them only when configured. The base screen contract still requires its feature filter builder, active-filter projection, breadcrumb and data-section builder.
- Keep the engine generic over the concrete Cubit and its actual effect type (`C extends PagedListCubit<T,Q,E>`); pass that effect type to `BlocEffectListener<E,C>`.
- At the engine-only stage, preserve Brands and Colors screens/tests unchanged; their later migrations are documented in task 6 (2/3) and task 6 (3/3) below.


## Final implementation review (step 6 — engine-only baseline before feature migrations)

- Compared recursive Git trees for the base branch `fix/ui-template-hardening` and `feat/crud-list-engine`: 8 added files, 4 modified files, and 0 removed files.
- The changed/added paths are limited to the two CRUD engine documentation files, Core's list toolbar/template and new CRUD list widgets, plus focused Core/widget tests. No Brands or Colors source or test path appears in the diff.
- No dependency manifest or lockfile changed; no package was added.
- The three new Core implementation files are 204 lines (`crud_list_config.dart`), 198 lines (`crud_list_screen.dart`), and 39 lines (`crud_actions_config.dart`) after CI formatting; all remain below the 220-line target.
- Core implementation imports only Flutter and Core. The engine retains typed Cubit/effect generics, contains no `dynamic`, and exposes optional feature-owned slots/callbacks.
- Standard bulk actions are intentionally supplied by each feature through `bulkActions` (for example, `CrudBulkActions.statusAndDelete`); `extraBulkActions` is appended after them. This keeps feature-specific localized keys and mutation policies out of Core.
- This historical engine-only review did not include screen migrations; Brands/Colors migrations were performed later and are documented in the task 6 sections below.
- Step 5's 280px / 360px / 700px / 1400px matrix passed at text scales 1.0 and 1.5 in both LTR and RTL. CI run 45308555462 completed successfully, including Auto-format, Analyze, full tests, and catalog UI widget tests.


## Brands adoption — task 6 (2/3), final review

- `BrandsScreen` is a thin stateless entry point to `CrudListScreen(config: brandsListConfig)`; its public `screenId` remains `catalog.brands`. The feature-owned config is 200 lines and owns the feature's query, localization, rendering and business-policy adapters.
- Search/status controls and active chips are reused from `BrandsFilterBar`. Multi-sort remains mapped through `mapFilterBarSorts<BrandSortField, BrandSort>`; the table header retains the feature's `setSort(field:, ascending:)` API.
- Stats remain feature-owned: `BrandStatsCubit` is provided around the engine, and refresh occurs only for `BrandsMutatedEffect`. At the time of the initial Brands migration the config disabled the template count; step D later changed the shared default to true and removed this override.
- `CrudFlowsConfig` calls `showBrandEditor(context, brand: item, duplicate: duplicate)` and returns its `bool?` result. The shared flow calls `onBrandSaved(isNew: ...)` after a successful result and a mounted-context check. This avoids the earlier adapter workaround that invoked the legacy action helper and returned false.
- Delete and status behavior remain in `BrandsListCubit`: delete retains `beforeDelete` usage checks; activation is direct; deactivation is confirmed. The per-row `canDelete` callback and bulk-delete rejection policy are both retained.
- Bulk callbacks are feature-owned through `CrudBulkConfig`; bulk activate/deactivate/delete use the existing Cubit methods and localized copy. No business logic moved into Core.
- The data section uses `CrudDataSection` / `CrudStatusColumnConfig`, existing `BrandIdentity`, `BrandCard`, `BrandGridTile`, `BrandStatusBadge`, and `AppIcons.brands`.
- The page file reduced from 226 to 15 lines; the separate config is 204 lines. Existing table/action/filter/renderer files were retained.
- At the historical Brands-adoption revision, the Colors screen and its screen widget test had identical Git blob SHAs to baseline commit `3854e616`; the later Colors migration is recorded in task 6 (3/3) below.
- Verification: workflow run `45320366371` passed Auto-format, Analyze (`No issues found`), the full suite (1,151 tests) and catalog UI widget tests (172 tests). The run also exercised the 32-case Brands responsive matrix (280/360/800/1280 × RTL/LTR × light/dark × 1.0/1.5 text scale).
- GitHub API only; no local Flutter/Dart commands were run. At that revision task 6 (2/3) was complete and task 6 (3/3) had not yet started; the latter was completed in the later section below.


## Task 6 (3/3) — Colors migration and verification record

- `ColorsScreen` is a thin entry point to `CrudListScreen(config: colorsListConfig)`; its public identity remains `catalog.colors`.
- `colorsListConfig` keeps `showCount: true`, the `ColorStatsCubit` provider and `ColorStatsSection` arguments (failure message key and retry), refreshing stats only for `ColorsMutatedEffect`.
- Table sort remains feature-owned: parse the header key and call `setSorts([ColorSort(field, ascending)])` only for a recognized field. The status column has no sort key.
- Color identity/code/hex, clipboard action, LTR hex direction, card and grid tile remain in the feature presentation. Delete message arguments retain `{'name': color.name}`; activate/deactivate retain their Color Cubit row-id/failure-flash behavior.
- No engine special-case for Colors was added. The only shared API is the typed configuration and data-section composition.
- The Colors migration commits were `71b8077`, `6c33767`, and `f86870c`; the final Colors correction passed CI run `45325524778` (Auto-format and Analyze and Test).
- The follow-up integration test suite is recorded in the test coverage document; its current run must be checked before calling task 6 (3/3) fully verified.


## Task 6 (3/3) — intentional unification decisions (step D)

- Brands single-row `activate` and `deactivate` now both return `Future<Either<Failure, Unit>>`; both pass `rowId` and `flashFailure: true` to `runMutation`. The shared `CrudFlowsConfig.activate` and `CrudConfirmations.status.onActivate` contracts were aligned to the same result type.
- `ColorStatsCubit.load` emits the initial loading state only when no previous stats exist. Refresh with prior stats does not replace the displayed state with loading; a refresh failure retains those stats and records `failed` plus the failure for `ColorStatsSection`.
- `CrudCapabilities.showCount` now defaults to `true`; Brands inherits that default and shows its count. A feature can still opt out with `showCount: false`.
- Sort consolidation was deliberately **not** performed. `BrandListQuery.withSort(field, ascending)` is equivalent to `withSorts([BrandSort(field, ascending)])`, including reset of secondary sorts/page. However, `ColorListQuery` has no `withSort(field, ascending)` method at all; it exposes only `withSorts`. Therefore the required cross-feature equivalence is not established, and `CrudSortConfig.applyTable` remains.
- Delete confirmation copy and `beforeDelete` policy were not unified or changed.
- Behavior tests added/updated: `brands_cubit_test.dart` (typed results, row busy and failure flash), `colors_cubits_test.dart` (stats refresh retention/failure), `brand_list_query_test.dart` (single-sort equivalence), `brands_list_config_test.dart` and `crud_list_config_test.dart` (count default). The intentional expectation changes are named here rather than hidden.


## Final verification — task 6 (3/3)

- Brands page: 226 lines before migration → 15 lines after; its feature config is 200 lines.
- Colors page: 232 lines before migration → 15 lines after; its feature config is 290 lines. The page is a thin `CrudListScreen(config: colorsListConfig)` wrapper.
- Colors migration final correction passed CI run `45325524778`.
- Full code verification, including B tests, D behavior tests and the E architecture gate, passed CI run `45329074594`: Analyze succeeded, 1,163 tests passed, and 172 catalog UI widget tests passed.
- The final documentation revision `ee038c4` also passed Auto-format, Analyze, full tests and catalog UI widget tests in CI run `45329255557`.
- The 20-line adapter example in `new_crud_feature_recipe.md` is exactly 20 lines. The working engine fixture uses a simple `String` row and a test Cubit extending `PagedListCubit`, and renders through `CrudDataSection`.
- The architecture gate has an empty exception set and passed in the full suite.
- No local Flutter/Dart commands were run. No new package or lockfile change was made.
- Manual visual QA is still required for both screens on a real phone/browser: table/cards/grid, selection and clearing selection on view changes, stats refresh after every mutation, RTL, 280–360px phones and desktop widths.
