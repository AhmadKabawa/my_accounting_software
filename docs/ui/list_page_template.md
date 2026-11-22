# List page template

## Preferred slots

| Need | Preferred slot | Legacy alternative | Status |
|---|---|---|---|
| Toolbar, search, filters, sorting, view modes, refresh | `toolbar: ListToolbarConfig` | `filterBar`, `activeFilters`, `viewModeSwitcher` | Preferred / Legacy |
| Statistics | `stats: ListStatsBar` | `actions` | Preferred / Legacy |
| Add/create action | `addAction: ListAddAction` | `primaryAction` | Preferred / Legacy |
| Header item count | `count` | None | Supported |

All slots remain available for compatibility. New list screens must use only the preferred slots.

## Existing screens using legacy slots

| Screen | Legacy slots |
|---|---|
| `ColorsScreen` (`lib/app/features/catalog/colors/presentation/pages/colors_screen.dart`) | `filterBar`, `primaryAction` |

`BrandsScreen` now uses `toolbar`, `stats`, and `addAction`. Its `activeFilters` list is configured inside `ListToolbarConfig`; it does not use the legacy `ListPageTemplate.activeFilters` slot.

The `count` slot remains supported: `ColorsScreen` uses it for the total record count.

## Example

```dart
return ListPageTemplate(
  titleKey: FeatureKeys.title,
  toolbar: ListToolbarConfig(
    onSearchChanged: cubit.searchChanged,
    onClearAll: cubit.clearFilters,
    activeFilters: activeFilters,
    filterControls: filterControls,
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
  dataTable: table,
);
```

