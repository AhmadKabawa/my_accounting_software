# CRUD list engine — repository analysis

## Scope and evidence

This analysis compares the accepted design with the implementation on `feat/crud-list-engine`, without migrating either catalog screen. The source of truth is the code and CI configuration, not the names proposed in the task.

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
2. `BlocEffectListener<Effects,CubitB>` is declared with effects first and `CubitB extends HasEffects<Effects>`. The requested `BlocEffectListener<Object?, C>` is valid only when `C` is constrained to `PagedListCubit<T,Q,Object?>`; retain the concrete Cubit type for provider lookup. No fourth generic is indicated by the inspected signatures.
3. `CrudRowActions` already supports optional additional overflow actions through `extraOverflow = const []`. It does not need a new field; preserve the existing API. The shared `crudStatusColumn<T>` is declared in the same file.
4. `CrudConfirmations.delete` accepts title/message keys, optional message args, target name and an async Either-returning delete callback. `CrudConfirmations.status` activates directly and confirms deactivation. Do not change this helper.
5. `ListToolbarConfig` currently has no extra toolbar action list. `ListPageTemplate._toolbar` creates a search suffix only for refresh/selection controls; this is the narrow extension point for step 1.
6. `FilterBarSortOption`, `FilterBarSort`, and `mapFilterBarSorts<F,T>` are exported from the filter-bar API. Keep feature enum parsing/building in the config adapter.
7. `ViewModeCubit` persists a string by screen id and restores only recognized `AppViewMode` values.
8. `CrudSelectionScope.actionsBuilder` returns `List<BulkAction>`; extra bulk actions can be appended after `CrudBulkActions.statusAndDelete` without changing the existing bar.
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
- Treat all slots as optional and call them only when supplied.
- Keep the engine generic over the concrete Cubit type, with effect type `Object?` only if the implementation confirms the requested broad listener constraint compiles.
- Leave Brands and Colors screens/tests behavior unchanged during this engine work.
