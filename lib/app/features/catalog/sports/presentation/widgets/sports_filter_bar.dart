import 'package:flutter/material.dart';
import 'package:accounting_software/app/core/localization/translations/app_key.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_filter_bar/filter_bar.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_searchable_dropdown/searchable_dropdown.dart';
import 'package:accounting_software/app/features/catalog/sports/domain/entity/sport_list_query.dart';
import 'package:accounting_software/app/features/catalog/sports/presentation/localization/sports_keys.dart';

class SportsFilterBar extends StatelessWidget {
  const SportsFilterBar({
    super.key,
    required this.query,
    required this.onSearchChanged,
    required this.onStatusChanged,
    required this.onClearAll,
    this.onSort,
  });

  final SportListQuery query;
  final ValueChanged<String> onSearchChanged;
  final ValueChanged<SportStatusFilter> onStatusChanged;
  final VoidCallback onClearAll;
  final void Function(SportSortField field, bool ascending)? onSort;

  static AppKey statusLabel(SportStatusFilter value) => switch (value) {
    SportStatusFilter.all => SportsKeys.allStatuses,
    SportStatusFilter.active => SportsKeys.active,
    SportStatusFilter.inactive => SportsKeys.inactive,
  };

  static const sortOptions = [
    FilterBarSortOption(key: 'order', label: SportsKeys.sortByOrder),
    FilterBarSortOption(key: 'name', label: SportsKeys.sortByName),
    FilterBarSortOption(key: 'code', label: SportsKeys.sortByCode),
  ];

  static List<FilterBarFilter> activeFilters(
    BuildContext context,
    SportListQuery query, {
    required ValueChanged<String> onSearchChanged,
    required ValueChanged<SportStatusFilter> onStatusChanged,
  }) => [
    if (query.search.isNotEmpty)
      FilterBarFilter(
        id: FilterBar.searchFilterId,
        label: SportsKeys.searchHint,
        value: query.search,
        onRemove: () => onSearchChanged(''),
      ),
    if (query.status != SportStatusFilter.all)
      FilterBarFilter(
        id: 'status',
        label: SportsKeys.status,
        value: statusLabel(query.status).tr(context: context),
        onRemove: () => onStatusChanged(SportStatusFilter.all),
      ),
  ];

  static List<Widget> controls(
    BuildContext context,
    SportListQuery query, {
    required ValueChanged<SportStatusFilter> onStatusChanged,
  }) => [
    SearchableDropdown<SportStatusFilter>(
      options: const [SportStatusFilter.active, SportStatusFilter.inactive],
      labelKey: SportsKeys.status,
      optionLabel: (value) => statusLabel(value).tr(context: context),
      value: query.status == SportStatusFilter.all ? null : query.status,
      clearable: false,
      mode: SearchableDropdownMode.panel,
      allOptionLabel: SportsKeys.allStatuses,
      onChanged: (value) => onStatusChanged(value ?? SportStatusFilter.all),
    ),
  ];

  @override
  Widget build(BuildContext context) => FilterBar(
    searchHintKey: SportsKeys.searchHint,
    debounce: Duration.zero,
    onSearchChanged: onSearchChanged,
    onClearAll: onClearAll,
    sortOptions: sortOptions,
    sortKey: query.sortField.name,
    sortAscending: query.sortAscending,
    onSort: (key, ascending) {
      final field = SportSortField.tryParse(key);
      if (field != null) onSort?.call(field, ascending);
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
