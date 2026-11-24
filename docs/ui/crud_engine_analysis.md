# CRUD list engine — repository analysis

## Scope and evidence

This analysis records the baseline CRUD engine design and implementation on `feat/crud-list-engine`. The later Brands adoption is documented in the task 6 section below; Colors remains unchanged. The source of truth is the code and CI configuration, not the names proposed in the task.

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
| Stats/count | Stats widget/cubit are feature-specific; no template count passed | Stats widget/cubit are feature-specific; template count passed | Keep stats in feature slots; count controlled by `capabilities.showCount` |
| Effects | Typed `BrandsListEffect`; mutation refreshes stats only for `BrandsMutatedEffect` | Typed `ColorsListEffect`; mutation refreshes stats only for `ColorsMutatedEffect` | Core can expose a broad mutation callback, but adapters must preserve any feature-specific effect filtering |

## Material differences to preserve

- Brands and Colors use different editor result handlers and save callbacks (`onBrandSaved` / `onColorSaved`).
- Delete confirmation differs: Brands passes `targetName` and uses its own delete/confirm keys; Colors additionally passes `messageArgs: {'name': color.name}`.
- Both confirm deactivation and activate directly, but their Cubit implementations differ in mutation options: Brands deactivation has feature-specific behavior (including no row id / no failure flash); Colors uses the color mutation path. Do not normalize these semantics.
- Brands deletion has `beforeDelete`/in-use protection and its row delete action can be disabled through `canDelete`; preserve that callback as a per-row policy.
- Table header sorting differs: Brands calls `setSort(field:, ascending:)`; Colors parses and calls `setSorts([...])`. Keep `applyTable` feature-configurable.
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
- The existing feature screen implementations remain unchanged in this step. This analysis records their different behavior rather than trying to unify it prematurely.

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
- Leave Brands and Colors screens/tests behavior unchanged during this engine work.


## Final implementation review (step 6)

- Compared recursive Git trees for the base branch `fix/ui-template-hardening` and `feat/crud-list-engine`: 8 added files, 4 modified files, and 0 removed files.
- The changed/added paths are limited to the two CRUD engine documentation files, Core's list toolbar/template and new CRUD list widgets, plus focused Core/widget tests. No Brands or Colors source or test path appears in the diff.
- No dependency manifest or lockfile changed; no package was added.
- The three new Core implementation files are 204 lines (`crud_list_config.dart`), 198 lines (`crud_list_screen.dart`), and 39 lines (`crud_actions_config.dart`) after CI formatting; all remain below the 220-line target.
- Core implementation imports only Flutter and Core. The engine retains typed Cubit/effect generics, contains no `dynamic`, and exposes optional feature-owned slots/callbacks.
- Standard bulk actions are intentionally supplied by each feature through `bulkActions` (for example, `CrudBulkActions.statusAndDelete`); `extraBulkActions` is appended after them. This keeps feature-specific localized keys and mutation policies out of Core.
- The review does not claim a screen migration: Brands and Colors remain unchanged, as required.
- Step 5's 280px / 360px / 700px / 1400px matrix passed at text scales 1.0 and 1.5 in both LTR and RTL. CI run 45308555462 completed successfully, including Auto-format, Analyze, full tests, and catalog UI widget tests.


## Brands adoption — task 6 (2/3), final review

- `BrandsScreen` is a thin stateless entry point to `CrudListScreen(config: brandsListConfig)`; its public `screenId` remains `catalog.brands`. The feature-owned config is 204 lines and owns the feature's query, localization, rendering and business-policy adapters.
- Search/status controls and active chips are reused from `BrandsFilterBar`. Multi-sort remains mapped through `mapFilterBarSorts<BrandSortField, BrandSort>`; the table header retains the feature's `setSort(field:, ascending:)` API.
- Stats remain feature-owned: `BrandStatsCubit` is provided around the engine, and refresh occurs only for `BrandsMutatedEffect`. The config explicitly disables the template count.
- `CrudFlowsConfig` calls `showBrandEditor(context, brand: item, duplicate: duplicate)` and returns its `bool?` result. The shared flow calls `onBrandSaved(isNew: ...)` after a successful result and a mounted-context check. This avoids the earlier adapter workaround that invoked the legacy action helper and returned false.
- Delete and status behavior remain in `BrandsListCubit`: delete retains `beforeDelete` usage checks; activation is direct; deactivation is confirmed. The per-row `canDelete` callback and bulk-delete rejection policy are both retained.
- Bulk callbacks are feature-owned through `CrudBulkConfig`; bulk activate/deactivate/delete use the existing Cubit methods and localized copy. No business logic moved into Core.
- The data section uses `CrudDataSection` / `CrudStatusColumnConfig`, existing `BrandIdentity`, `BrandCard`, `BrandGridTile`, `BrandStatusBadge`, and `AppIcons.brands`.
- The page file reduced from 226 to 15 lines; the separate config is 204 lines. Existing table/action/filter/renderer files were retained.
- Colors screen and its screen widget test have identical Git blob SHAs to baseline commit `3854e616`; no Colors migration occurred.
- Verification: workflow run `45320366371` passed Auto-format, Analyze (`No issues found`), the full suite (1,151 tests) and catalog UI widget tests (172 tests). The run also exercised the 32-case Brands responsive matrix (280/360/800/1280 × RTL/LTR × light/dark × 1.0/1.5 text scale).
- GitHub API only; no local Flutter/Dart commands were run. This completes task 6 (2/3) only; task 6 (3/3) was not started.
