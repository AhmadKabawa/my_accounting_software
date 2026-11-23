# List page template

## Preferred slots

| Need | Preferred slot | Legacy alternative | Runtime precedence |
|---|---|---|---|
| Toolbar: search, filters, sorting, view modes, refresh | `toolbar: ListToolbarConfig` | `filterBar`, `activeFilters`, `viewModeSwitcher` | `filterBar` overrides `toolbar`; do not provide both |
| Statistics | `stats` (normally `ListStatsBar`) | `actions` | `stats` wins when both are supplied |
| Add/create action | `addAction: ListAddAction` | `primaryAction` | Mutually exclusive; the constructor asserts if both are supplied |
| Header item count | `count` | None | Rendered beside the page title |
| Page content | `dataTable` (normally `AppDataView`) | None | Rendered inside the list surface |

All legacy slots remain available for compatibility. Do not delete them or add `@Deprecated` annotations as part of a feature migration. New list screens must use the preferred slots.

## Statistics card behavior

A statistics card with a filter applies that filter to the list when selected. A card without a filter is informational only: it has no tap behavior, selected state, hover/ripple affordance, focus affordance, or button semantics. For example, a card showing the total inventory value is informational unless a corresponding list filter exists.

## Slot composition

- The header is first and may show `count` and `addAction`.
- The preferred statistics widget (`stats`) follows the header. The legacy `actions` widget is used only when `stats` is null.
- The list surface contains the toolbar, optional legacy active-filter/view-mode widgets, then the data area.
- `toolbar` owns active filters and view-mode selection through `ListToolbarConfig`. Do not also pass the legacy `activeFilters` or `viewModeSwitcher` slots, or the same controls can appear twice.
- `filterBar` is checked before `toolbar`; if both are passed, the legacy widget is what renders.

## Existing catalog list screens after migration

| Screen | Preferred slots | Legacy slots still used |
|---|---|---|
| `BrandsScreen` | `toolbar`, `stats`, `addAction`, `count` | None |
| `ColorsScreen` | `toolbar`, `stats`, `addAction`, `count` | None |

No catalog CRUD list screen in the migration scope still uses the legacy slots. This does not imply that unrelated non-CRUD pages use `ListPageTemplate`.

## Example

```dart
return ListPageTemplate(
  titleKey: FeatureKeys.title,
  toolbar: ListToolbarConfig(
    onSearchChanged: cubit.searchChanged,
    onClearAll: cubit.clearFilters,
    activeFilters: activeFilters,
    filterControls: filterControls,
    sortOptions: sortOptions,
    sorts: query.sorts,
    onSortsChanged: cubit.setSorts,
  ),
  stats: ListStatsBar<StatusFilter>(
    items: statsItems,
    selected: query.status,
    onSelected: cubit.setStatus,
    loading: statsLoading,
  ),
  addAction: ListAddAction(
    labelKey: FeatureKeys.add,
    permission: Permissions.catalog.manage,
    onPressed: onAdd,
  ),
  count: totalCount,
  dataTable: dataView,
);
```

## Selection mode and bulk CRUD actions

Selection is opt-in. The feature supplies its server-authoritative bulk permission through ListToolbarConfig: set selectionModeActive from PagedListCubit and provide onSelectionModeToggle only while the permission is granted. The template places the icon-only toggle beside refresh/view controls. The active state is exposed to semantics and uses a filled visual variant.

CrudSelectionScope<T> receives selectionModeActive and an exit callback. It passes selected IDs and the selection callback only when both permission and selection mode are active. It shows the compact BulkActionBar as soon as selection mode is active, including when zero records are selected. The page-level tri-state checkbox selects or clears the current page in every view. Exiting selection mode clears the selection; query/page changes and completed bulk actions clear IDs while preserving selection mode. If permission is revoked, the scope exits selection mode. Core must not contain feature permission constants.

CrudBulkActions.statusAndDelete<T> invokes the selected-items callback and opens BulkResultDialog once for partial or complete failure.

- Complete success: success flash only.
- Partial/complete failure: result dialog only; do not also emit an error flash for the same batch.
- The operation is sequential per selected record, not atomic. Keep the selection page-scoped. Recommend a maximum of 50 records for ordinary bulk operations; 100 is the configured page-size ceiling and is suitable only for light operations.
- On content narrower than compactContentBreakpoint (720 logical pixels), BulkActionBar shows icon-only actions with tooltips and semantics.

## Grid tile sizing

AppDataGrid uses the available content width and the shared minimum tile-width token to determine columns. Each row uses intrinsic height so its tiles match the tallest tile in that row. Do not set a fixed mainAxisExtent and do not wrap grid content in FittedBox/scaleDown. Keep selection and row actions overlaid in the tile corner so enabling selection does not change content height. Grid content must allow natural height, constrain long names with maxLines and ellipsis, and keep logo/swatch previews at a stable size.

## Form dialog dismissal

Every AppFormDialog caller must pass a truthful dirty value comparing the current editable values with the initial create defaults, edit record, or duplicate seed. Compare normalized values consistently with save (the catalog editors trim surrounding whitespace); changing a field and restoring its original value is clean. A clean form may dismiss through the barrier, Escape, back, or sheet drag and returns false/null. A dirty form must route dismissal through the existing unsaved-changes confirmation; a busy form cannot dismiss. Never reload the list or show a success message unless the dialog result is true.

Never use a screen BuildContext after await to show an operation result. Capture the root Navigator before awaiting and use its mounted state/context afterward.

## Sorting and loading

Multi-sort criteria are kept in priority order and all available fields may be used once. Selecting a field already used by another criterion is disabled; changing a criterion's field preserves its direction; move-up/move-down controls change the priority order. The feature query model and remote order builder must retain the entire list, not truncate after the second criterion. A zero maxSorts means no artificial cap beyond the available fields.

When no view mode has been selected, loading placeholders follow the available content width: cards below the shared compact breakpoint, table otherwise. An explicit saved view mode remains authoritative.
