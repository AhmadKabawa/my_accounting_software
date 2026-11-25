# New CRUD feature recipe

This recipe describes the shared structure for a new catalog CRUD feature. Follow the existing Brands and Colors implementations, and reuse the core components instead of rebuilding list behavior inside a feature.

## Recommended feature structure

```text
lib/app/features/catalog/<feature>/
  domain/
    entity/
      <feature>.dart
      <feature>_draft.dart
      <feature>_list_query.dart
    repository/
    usecase/
  data/
    datasource/
    repository/
  presentation/
    cubit/
      <feature>_list/
      <feature>_stats/
      <feature>_form/
    dialogs/
      <feature>_editor_dialog.dart
    localization/
      <feature>_keys.dart
    <feature>_list_config.dart   # CrudListConfig: the only per-screen wiring
    pages/
      <feature>_screen.dart      # thin CrudListScreen entry point
    sections/
      <feature>_stats_section.dart
    widgets/
      <feature>_card.dart
      <feature>_grid_tile.dart
      <feature>_status_badge.dart
      <feature>_filter_bar.dart
```

The exact folders depend on the feature. Keep feature-specific fields, labels, validation, data access and seed construction inside the feature. Shared list mechanics belong in `lib/app/core`.

## Reuse map

| Need | Main file / component to change | Can it truly be one file? |
|---|---|---|
| Change the number or meaning of statistics cards | `presentation/sections/<feature>_stats_section.dart` using `ListStatsBar` and `StatItem`, wired through `statsBuilder` | Usually yes, if the stats data already exists |
| Change add-button label, permission or destination | `<feature>_list_config.dart` (`addLabelKey`, `manageAccess`, `flows.showEditor`) | The key still lives in the feature localization file |
| Add or remove a table column | `<feature>_list_config.dart`, the `columns` of `CrudDataSection` | Usually yes when the domain field already exists |
| Change row actions or their labels | `<feature>_list_config.dart`: `CrudLabels` (labels and confirmation copy) and `CrudFlowsConfig` (editor, delete, status callbacks); one-off extras through `CrudDataSection.extraRowActions` | Callback behavior may also require the cubit |
| Add a bulk action | The standard three live in `CrudBulkConfig`; an extra one goes through `extraBulkActions` plus a cubit method | No: permission, confirmation, result reporting and use case may span files |
| Add duplicate behavior | `presentation/dialogs/<feature>_editor_dialog.dart` with a feature-specific seed function, `CrudLabels.duplicate` | No: the localized duplicate labels also change |
| Change sort fields | `domain/entity/<feature>_list_query.dart` and the `CrudSortConfig` in the config | No: remote query ordering must support the same fields |
| Change pagination behavior | `domain/entity/<feature>_list_query.dart` and the list cubit/data query | No: query, fetch and paging contract must agree |
| Enable or disable row selection | `capabilities.bulkSelection` in the config | Yes: the engine wires permission, mode and data-view callbacks |
| Change status display | `CrudStatusColumnConfig` (badge, sort key) in the config | Usually yes if status already exists |
| Entity without `is_active` | Leave `statusColumn`, the status callbacks and the status label group null | Yes (see "Optional operations") |
| Change filter controls | `presentation/widgets/<feature>_filter_bar.dart` or `ListToolbarConfig` | Query fields and localization keys may also change |

**Known weakness:** CRUD changes are not universally one-file changes. A new domain field, sort key, bulk mutation or duplicate mode often crosses the query/entity, data source/use case, cubit, screen, table section and localization. The table above identifies the primary feature file, not a promise that all related code is isolated there.

## Implementation checklist

1. Read the repository's `AGENTS.md` and `CLAUDE.md`; follow the feature-first and Clean Architecture conventions already present.
2. Define the entity and draft in `domain/entity`. Keep validation and feature rules out of core.
3. Define the list query as a `PagedQuery`: search, page, page size, active-filter detection, clear behavior and sort criteria.
4. Implement repository/data-source access and use cases. Ensure server-side sort and paging match the query contract.
5. Implement the list Cubit by extending `PagedListCubit`. Use its shared load, search debounce, page, refresh, delete, mutation effects, selection reset and `runBulk` behavior.
6. Implement the stats Cubit and expose the feature's statistics as `StatItem` values. A card with a filter applies it; a card without a filter is informational only.
7. Implement the form Cubit and editor dialog. For duplicate mode, create a feature-specific seed: generate new unique values, copy safe non-unique fields, and do not save until the user confirms.
8. Implement the feature's filter/sort configuration using `FilterBar` and `ListToolbarConfig`. Keep every user-facing label in `AppKey` translations.
9. Describe the data section inside the config with `CrudDataSection`: columns, `CrudLabels`, an optional `CrudStatusColumnConfig`, and the card/grid renderers. It builds `AppDataView`, `CrudEmptyState`, `crudStatusColumn` and `CrudRowActions` for you and uses the same row ID for table, card and grid selection.
10. Delegate the page to `CrudListScreen(config: <feature>ListConfig)`. The engine composes `ListPageTemplate` (`toolbar`, `stats`, `addAction`, `count`) and `ViewModeCubit`; do not build `ListPageTemplate` in a page.
11. Keep selection mode off by default. Set ListToolbarConfig.selectionModeActive from the feature's PagedListCubit and provide onSelectionModeToggle only when the feature's bulk permission is granted. Pass selectionModeActive and an exit callback to CrudSelectionScope. Selection IDs and checkboxes are passed to AppDataView only while permission and selection mode are both active. Exiting mode clears IDs; query/page/view-mode changes and bulk completion clear IDs but keep mode active. The bulk bar is visible at zero selected items and its actions remain disabled until a selection exists.
12. Add `BulkActionBar` actions with feature permissions and count-aware confirmations. Keep the operation in the cubit/use-case layer, not in widget loops. Return a `BulkResult` with every failed row and its reason; do not report partial success as full success. When no server bulk endpoint exists, `BulkMutationUseCase` executes mutations sequentially; this is not one database transaction, so document the partial-completion behavior.
13. For bulk delete, reject or skip rows that cannot be deleted while continuing the remaining rows.
14. Add widget and unit tests for query behavior, sort synchronization, selection tri-state, permissions, bulk success/partial/full failure, duplicate seeds and editor dirty state.
15. Review all three view modes, phone/tablet/desktop widths, RTL/LTR, light/dark, empty/error/loading states and users without permissions.
16. Grid tiles must size to content: no fixed mainAxisExtent and no FittedBox/scaleDown. Determine columns from the available content width, keep each row's tiles equal height, overlay selection/actions so mode changes do not change tile height, and ellipsize long names.
17. Every editor opened with showAppFormDialog must pass an accurate dirty comparison against create defaults, edit values or duplicate seed. Match save normalization (trim surrounding whitespace in catalog editors); changing and restoring a value is clean. Clean forms dismiss directly, dirty forms require TemplateKeys.unsavedChanges confirmation, and busy forms cannot dismiss.
18. Never use the originating screen BuildContext after await to show a mutation result. Capture the root Navigator before awaiting and check that it remains mounted.

## Core components to reuse

- `ListPageTemplate`, `ListToolbarConfig`, `ListAddAction`
- `ListStatsBar`, `StatItem`, `CrudEmptyState`
- `PagedListCubit`, `PagedQuery`, `ListSelectionCubit`, `BulkMutationUseCase`, `BulkResult`
- `AppDataView`, `AppDataTable`, `AppRecordCard`, `AppDataGrid`
- `BulkActionBar`, `CrudBulkActions`, `BulkResultDialog`, `CrudRowActions`, `crudStatusColumn`
- `AppSwitch`, `AppStatCard`, `AppFilterBar`

Core must receive permissions from the feature; do not hardcode feature permissions such as `Permissions.masterData.manage` in `lib/app/core`.

## Shared list and editor rules

- Build grid cards at natural height. Do not apply a fixed height, `FittedBox`, or `IntrinsicHeight`; `LayoutBuilder` is valid inside tile content, and `EqualHeightRow` equalizes each row.
- Reuse `AppLogoThumb`: `small` for table/horizontal identity rows and `large` for grid previews. Do not create another feature-specific logo image widget.
- Configure multi-sort with one row per criterion. The field name opens the menu, the direction icon changes direction, later criteria expose move-up/remove, and the add action is icon-only. Used fields are disabled; there is no move-down action. Selecting an item from a nested field/add menu closes only that menu and keeps the sort panel open.
- Keep the sort panel within `AppComponentSize.filterControlWidth` on desktop and fill the phone sheet. Avoid `LayoutBuilder` inside the panel.
- Every create/edit dialog supplies its real `dirty` state. Desktop form dialogs keep Save/Cancel fixed while the center content scrolls. The mobile sheet disables drag dismissal because it bypasses the unsaved-changes guard.
- In width-matrix widget tests, use a distinct `ValueKey(width)` when pumping the same stateful widget repeatedly, or dispose it between iterations.



## Exact files and implementation order for a new feature

Create only the files the feature actually needs; this is the usual dependency order:

1. **Domain entity and query**
   - `domain/entity/<feature>.dart`, optional `<feature>_draft.dart`, and `<feature>_list_query.dart`.
   - The query implements `PagedQuery`: search, page/pageSize, active-filter detection, clear behavior and sort criteria.
2. **Domain repository contract and use cases**
   - `domain/repositories/<feature>_repository.dart`.
   - `domain/usecase/get_<feature>_use_case.dart`, plus the required create/update/delete/status/stats use cases. Keep one use case per business operation that has a real domain boundary.
3. **Data implementation**
   - `data/datasources/<feature>_remote_data_source.dart` and its implementation.
   - `data/repositories/<feature>_repository_impl.dart`. Use the shared `IApiClient`; do not create a feature-local Dio client.
4. **List Cubit**
   - `presentation/cubit/<feature>_list/<feature>_list_cubit.dart` extends `PagedListCubit<Entity, FeatureListQuery, FeatureListEffect>`.
   - Implement `fetch`, `deleteItem`, `deletedMessageKey`, and `buildMutationEffect`; override `beforeDelete` only when this feature has a real delete guard. Keep feature-specific filters, sort setters, row mutation policy and bulk callbacks here.
5. **Feature presentation**
   - `presentation/<feature>_list_config.dart`: the `CrudListConfig` adapter (the existing Brands/Colors convention).
   - `presentation/pages/<feature>_screen.dart`: a thin `CrudListScreen(config: featureListConfig)` entry point.
   - `presentation/widgets/<feature>_identity.dart`, `<feature>_card.dart`, `<feature>_grid_tile.dart`, `<feature>_status_badge.dart`, and `<feature>_filter_bar.dart` only when the feature needs those distinct renderers.
   - `presentation/dialogs/<feature>_editor_dialog.dart` plus form Cubit when create/edit/duplicate needs a form.
   - `presentation/localization/<feature>_keys.dart` for every visible label and message.
6. **Registration and routing**
   - Register the feature data source, repository, use cases, list/form/stats Cubits in `<feature>/di/<feature>_di.dart`.
   - Call `init<Feature>DI()` from `features/catalog/di/catalog_di.dart` (or the owning feature composition root).
   - Add `presentation/routing/<feature>_routes.dart`; include its route list in `lib/app/routing/route_registry.dart`, and add the matching GoRoute/screen builder in `lib/app/routing/app_go_router.dart`.
7. **Tests**
   - Test query/use-case/Cubit behavior, the feature config, the three data representations, permissions, row/bulk mutations, editor dirty/duplicate behavior and responsive RTL/LTR layouts.

### Minimal engine adapter — 20 lines

After the entity, query, Cubit, sort adapter and reusable renderers exist, the feature-facing screen configuration can stay at 20 lines:

```dart
final demoConfig = CrudListConfig<DemoItem, DemoQuery, DemoCubit, DemoEffect>(
  screenId: 'catalog.demo',
  titleKey: DemoKeys.title,
  manageAccess: DemoPermissions.manage,
  searchHintKey: DemoKeys.search,
  addLabelKey: DemoKeys.add,
  createCubit: () => sl<DemoCubit>(),
  rowId: (item) => item.id,
  itemLabel: (item) => item.name,
  sort: demoSortConfig, breadcrumb: demoBreadcrumb,
  filterControls: (_) => const [], activeFilters: (_) => const [],
  dataSection: (data) => CrudDataSection(
    data: data, columns: demoColumns, statusColumn: demoStatus,
    cardBuilder: demoCard, gridBuilder: demoGridTile, icon: AppIcons.catalog,
    emptyTitleKey: DemoKeys.empty, emptyDescriptionKey: DemoKeys.emptyHint,
    noResultsTitleKey: DemoKeys.noResults, noResultsDescriptionKey: DemoKeys.noResultsHint,
    labels: demoLabels,
  ),
);
```

The working engine integration fixture is `test/core/presentation/widgets/crud_list/crud_list_screen_test.dart`: its simple `String` row and `_TestCubit extends PagedListCubit<String, _Query, _Effect>` are pumped through a real `CrudListScreen` and `CrudDataSection`; the test asserts the fetched rows and absence of framework exceptions. The example above is the **20-line screen adapter**, not a claim that repository/data-source/domain boilerplate is also 20 lines.

## How to add a capability or extension

### A. A capability shared by every CRUD screen

Add a field to `CrudCapabilities` or a general engine contract only when it describes a universal CRUD behavior. Give it a conservative default (`false`, `null`, or an empty collection) so existing configurations keep their current behavior. The screen reads the capability in one place; old feature configs need no edits.

The only exception is `showCount`, which defaults to `true`: every CRUD list shows its record count, so hiding it is the opt-out (`CrudCapabilities(showCount: false)`). It was made the default after both catalog screens needed it; the CRUD lists should look the same unless a screen asks otherwise. A new capability does not get this exception.

### B. A one-screen extension

Use an existing `CrudListConfig` slot first: `statsBuilder`, `headerExtras`, `extraToolbarActions`, `extraFilterControls`, `extraBulkActions`, `CrudDataSection.extraRowActions`, `emptyStateBuilder`, or a feature-owned `dataSection`. Keep the callback and business behavior in the feature. Do not add a global capability for a single screen.

### C. When to add a new CrudListConfig slot

Add a new slot when at least two CRUD screens need the same *kind* of extension and the existing slots cannot express it cleanly. Keep it typed, feature-owned, and default-empty/null. Do not make Core inspect feature types or import a feature.

Use a dedicated feature widget instead when the addition changes the internal structure or visual semantics of one section (for example, a unique multi-part identity card or stats layout). Pass that widget through the existing builder slot rather than teaching Core the feature's structure.

Use `dataSection` instead of `CrudDataSection` only when the screen's data presentation genuinely differs from the standard table/cards/grid + status + row-actions composition. If the standard composition fits, prefer `CrudDataSection` and provide columns, status policy, card/grid renderers and optional `canDelete`/extra row actions. Do not fork the shared section just to change a cell or card's appearance.


## Architecture gate for CRUD screens

`test/architecture/crud_screens_use_engine_test.dart` scans every Dart file under `lib/app/features/**/pages/`. A page that directly constructs `ListPageTemplate(` must also delegate through `CrudListScreen(` or appear in the explicit legacy exception set in that test. The exception set is intentionally empty for the current migration. The test has self-checks proving that direct `ListPageTemplate` construction is rejected and a `CrudListScreen` page is accepted. The full `flutter test` CI job runs this gate; do not move, rename or delete protected tests to bypass it.

Every `*_list_config.dart` under `lib/app/features` must also stay within 250 lines (same test file). When a config approaches the limit, move cell/card/tile widgets into `widgets/` (as Brands and Colors do with `brand_card.dart`, `color_grid_tile.dart`, `color_hex_cell.dart`) and shared behavior into the engine. The failure message points back to this recipe.

## One mechanism per purpose

Row operations go through `CrudFlowsConfig` (with `CrudLabels`) and the standard bulk operations through `CrudBulkConfig`; there is no separate "actions" configuration. Use the `extra*` slots only for additions that exist on one screen.

## Optional operations

Only `CrudLabels.edit` and the editor flow are mandatory. Delete, duplicate and status are optional, so an entity without `is_active` (or that cannot be deleted) reuses the same engine:

```dart
const _labels = CrudLabels(
  edit: UnitsKeys.edit,
  delete: UnitsKeys.delete,
  deleteConfirmationTitle: UnitsKeys.deleteTitle,
  deleteConfirmationMessage: UnitsKeys.deleteMessage,
); // no duplicate, no activate/deactivate

flows: CrudFlowsConfig<Unit, UnitsCubit>(
  showEditor: ..., onSaved: ..., itemLabel: (u) => u.name,
  labels: _labels, delete: (cubit, unit) => cubit.delete(unit), // no status callbacks
),
bulk: CrudBulkConfig<Unit, UnitsCubit>(
  deleteLabelKey: ..., deleteTitleKey: ..., deleteMessageKey: ...,
  delete: (cubit, units) => cubit.bulkDelete(units), // no bulk activate/deactivate
),
dataSection: (data) => CrudDataSection<Unit, UnitsQuery, UnitsCubit>(
  data: data, labels: _labels, /* statusColumn omitted: no status column */ ...
),
capabilities: const CrudCapabilities(duplicate: false),
```

`statusColumn: null` removes the status column, the row activate/deactivate action and bulk activation. A missing delete label or callback removes the Delete item (a per-row `flows.canDelete` that returns false keeps it visible but disabled). `test/core/presentation/widgets/crud_list/crud_data_section_test.dart` and `crud_list_screen_test.dart` cover an entity without status and delete-only bulk.

## فحص يدوي مطلوب

- Brands وColors في table/cards/grid على متصفح أو جهاز حقيقي.
- التحديد الجماعي، تحديد الصفحة، مسح التحديد، وإعادة ضبط التحديد بعد تغيير نمط العرض.
- تحديث الإحصاءات بعد الإنشاء والتعديل والنسخ والتفعيل وإلغاء التفعيل والحذف والعمليات الجماعية.
- المحاذاة المرئية في RTL واتجاه حقل hex في LTR وإجراء النسخ.
- عروض الهاتف 280–360px وعروض سطح المكتب؛ تحقق من عدم وجود overflow أو قوائم مقصوصة.
- مصفوفة CI تغطي 280px وRTL ومقياس نص 1.5 لأنماط العرض الثلاثة على الشاشتين، لكنها لا تستبدل الفحص المرئي اليدوي.


## Shared CRUD editor dialog

Use CrudEditorDialog<C, S, E> for catalog create/edit/duplicate forms when the feature already owns its Cubit and effects. The shared component owns the common dialog lifecycle; the feature continues to own its fields, validation rules, draft construction, and save operation.

- Create named controllers with CrudEditorFields; the editor owns and disposes them.
- Supply CrudEditorLabels with the feature's localized AppKey values for add/edit/duplicate titles, subtitle, save and cancel.
- Map the feature's success/failure effects to CrudEditorSuccess and CrudEditorFailure; do not move feature business rules into Core.
- isSaving maps the feature state to the common busy state. Use extraBusy for independent work such as logo upload and extraDirty for non-text values such as an active switch.
- The builder receives CrudEditorScope: use formKey for the form, fields for the controllers, busy for disabled actions, clearFailure after edits, and changed when non-controller state changes.
- onSave runs only after the shared form validation succeeds. Keep normalization and draft creation in the feature.
- Keep duplicate seed generation in the feature. Reuse the shared dialog shell without sharing entity-specific duplicate rules.
- Continue opening the dialog through a feature launcher that creates the feature Cubit providers and calls showAppFormDialog; do not create feature Cubits inside Core.

The current reference implementations are Brands and Colors. They share save/dirty/busy/effect handling while retaining their own slug, logo-upload, HEX-name suggestion, status and duplicate-seed behavior.


## Adding an image to a feature

Keep the image rules in the feature and the picker, validation flow, field UI and Storage transport in Core.

1. Define one feature policy with the accepted MIME types and byte limit.
2. In the feature remote data source, pass a `StorageTarget(bucket, folder)` and `ImageUpload` to the shared `StorageImageUploader`; map its `ApiResult` through the feature repository/use case.
3. Use `AppImageUploadField` in the editor and pass the use-case function as its uploader.
4. Feed `onBusyChanged` into `CrudEditorDialog.extraBusy` so the editor cannot close while the upload is running.
5. Keep feature labels as feature `AppKey` values; use Core's `ImageKeys.dropHint` for the shared drop hint.

Example (the policy and upload use case are feature-owned):

```dart
AppImageUploadField(
  value: logo.text,
  onChanged: (url) => logo.text = url ?? '',
  label: name.text,
  policy: featureLogoPolicy,
  uploader: uploadLogoUseCase.call,
  labels: const AppImageUploadFieldLabels(
    sectionTitle: FeatureKeys.logoSection,
    upload: FeatureKeys.uploadLogo,
    replace: FeatureKeys.replaceLogo,
    remove: FeatureKeys.removeLogo,
    dropHint: ImageKeys.dropHint,
  ),
  previewSize: AppLogoSize.small,
  onBusyChanged: (busy) => onExtraBusyChanged(busy),
)
```

On Android/iOS, `FileType.image` opens the system image gallery and the drop target is hidden (`supportsFileDrop == false`). On Web and desktop, the same field also accepts the first dropped file; it still validates the actual bytes before upload.

Known limitations intentionally left out:
- No image compression: a phone photo larger than the feature's limit (Brands: 5 MB) is rejected with a clear size message.
- No camera capture: this requires a separate `image_picker` integration and camera permission declarations.
- No cleanup of orphaned Storage files when an image is replaced or a record is deleted.
