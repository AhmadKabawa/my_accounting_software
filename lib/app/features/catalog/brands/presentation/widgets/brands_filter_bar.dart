import 'package:flutter/material.dart';
import 'package:accounting_software/app/core/localization/translations/app_key.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_filter_bar/filter_bar.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_searchable_dropdown/searchable_dropdown.dart';
import 'package:accounting_software/app/features/catalog/brands/domain/entity/brand_list_query.dart';
import 'package:accounting_software/app/features/catalog/brands/presentation/localization/brands_keys.dart';

/// Search + status filter for brands.
///
/// The parent owns the Cubit; this widget only renders values and callbacks.
class BrandsFilterBar extends StatelessWidget {
  const BrandsFilterBar({
    super.key,
    required this.query,
    required this.onSearchChanged,
    required this.onStatusChanged,
    required this.onClearAll,
    required this.onSort,
    this.leading,
    this.trailing,
    this.resultCount,
  });

  final BrandListQuery query;
  final ValueChanged<String> onSearchChanged;
  final ValueChanged<BrandStatusFilter> onStatusChanged;
  final VoidCallback onClearAll;
  final void Function(BrandSortField field, bool ascending) onSort;
  final Widget? leading;
  final Widget? trailing;
  final int? resultCount;

  static AppKey statusLabel(BrandStatusFilter value) => switch (value) {
    BrandStatusFilter.all => BrandsKeys.allStatuses,
    BrandStatusFilter.active => BrandsKeys.active,
    BrandStatusFilter.inactive => BrandsKeys.inactive,
  };

  static const sortOptions = [
    FilterBarSortOption(key: 'name', label: BrandsKeys.sortByName),
    FilterBarSortOption(key: 'created', label: BrandsKeys.sortByCreated),
    FilterBarSortOption(key: 'status', label: BrandsKeys.sortByStatus),
  ];

  /// The applied filters as chips (shared by the widget and the page toolbar).
  static List<FilterBarFilter> activeFilters(
    BuildContext context,
    BrandListQuery query, {
    required ValueChanged<String> onSearchChanged,
    required ValueChanged<BrandStatusFilter> onStatusChanged,
  }) => [
    if (query.search.isNotEmpty)
      FilterBarFilter(
        id: FilterBar.searchFilterId,
        label: BrandsKeys.searchHint,
        value: query.search,
        onRemove: () => onSearchChanged(''),
      ),
    if (query.status != BrandStatusFilter.all)
      FilterBarFilter(
        id: 'status',
        label: BrandsKeys.status,
        value: statusLabel(query.status).tr(context: context),
        onRemove: () => onStatusChanged(BrandStatusFilter.all),
      ),
  ];

  /// The filter controls opened by the "Filters" button.
  static List<Widget> controls(
    BuildContext context,
    BrandListQuery query, {
    required ValueChanged<BrandStatusFilter> onStatusChanged,
  }) => [
    SearchableDropdown<BrandStatusFilter>(
      options: const [BrandStatusFilter.active, BrandStatusFilter.inactive],
      labelKey: BrandsKeys.status,
      optionLabel: (value) => statusLabel(value).tr(context: context),
      value: query.status == BrandStatusFilter.all ? null : query.status,
      allOptionLabel: BrandsKeys.allStatuses,
      mode: SearchableDropdownMode.panel,
      onChanged: (value) => onStatusChanged(value ?? BrandStatusFilter.all),
    ),
  ];

  @override
  Widget build(BuildContext context) => FilterBar(
    searchHintKey: BrandsKeys.searchHint,
    debounce: Duration.zero,
    onSearchChanged: onSearchChanged,
    onClearAll: onClearAll,
    leading: leading,
    trailing: trailing,
    resultCount: resultCount,
    sortOptions: sortOptions,
    sortKey: query.sortField.name,
    sortAscending: query.sortAscending,
    onSort: (key, ascending) {
      final field = BrandSortField.tryParse(key);
      if (field != null) onSort(field, ascending);
    },
    activeFilters: activeFilters(
      context,
      query,
      onSearchChanged: onSearchChanged,
      onStatusChanged: onStatusChanged,
    ),
    filterControls: controls(context, query, onStatusChanged: onStatusChanged),
  );
}
