import 'package:flutter/material.dart';
import 'package:accounting_software/app/core/localization/translations/app_key.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_filter_bar/filter_bar.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_searchable_dropdown/searchable_dropdown.dart';
import 'package:accounting_software/app/features/catalog/size_systems/presentation/localization/size_systems_keys.dart';
import 'package:accounting_software/app/features/catalog/size_systems/shared/domain/size_status_filter.dart';

/// Filter controls shared by the three size lists.
abstract final class SizeFilterBar {
  static AppKey statusLabel(SizeStatusFilter value) => switch (value) {
    SizeStatusFilter.all => SizeSystemsKeys.allStatuses,
    SizeStatusFilter.active => SizeSystemsKeys.active,
    SizeStatusFilter.inactive => SizeSystemsKeys.inactive,
  };

  static const systemSortOptions = [
    FilterBarSortOption(key: 'name', label: SizeSystemsKeys.sortByName),
    FilterBarSortOption(key: 'code', label: SizeSystemsKeys.sortByCode),
    FilterBarSortOption(key: 'updated', label: SizeSystemsKeys.sortByUpdated),
  ];

  static const groupSortOptions = systemSortOptions;

  static const sizeSortOptions = [
    FilterBarSortOption(key: 'order', label: SizeSystemsKeys.sortByOrder),
    FilterBarSortOption(key: 'name', label: SizeSystemsKeys.sortByName),
    FilterBarSortOption(key: 'code', label: SizeSystemsKeys.sortByCode),
    FilterBarSortOption(key: 'value', label: SizeSystemsKeys.sortByValue),
  ];

  static Widget statusControl(
    BuildContext context,
    SizeStatusFilter current,
    ValueChanged<SizeStatusFilter> onChanged,
  ) => SearchableDropdown<SizeStatusFilter>(
    options: const [SizeStatusFilter.active, SizeStatusFilter.inactive],
    labelKey: SizeSystemsKeys.status,
    optionLabel: (value) => statusLabel(value).tr(context: context),
    value: current == SizeStatusFilter.all ? null : current,
    allOptionLabel: SizeSystemsKeys.allStatuses,
    mode: SearchableDropdownMode.panel,
    onChanged: (value) => onChanged(value ?? SizeStatusFilter.all),
  );

  static List<FilterBarFilter> activeFilters(
    BuildContext context, {
    required String search,
    required SizeStatusFilter status,
    required ValueChanged<String> onSearchChanged,
    required ValueChanged<SizeStatusFilter> onStatusChanged,
    List<FilterBarFilter> extra = const [],
  }) => [
    if (search.isNotEmpty)
      FilterBarFilter(
        id: FilterBar.searchFilterId,
        label: SizeSystemsKeys.searchHint,
        value: search,
        onRemove: () => onSearchChanged(''),
      ),
    if (status != SizeStatusFilter.all)
      FilterBarFilter(
        id: 'status',
        label: SizeSystemsKeys.status,
        value: statusLabel(status).tr(context: context),
        onRemove: () => onStatusChanged(SizeStatusFilter.all),
      ),
    ...extra,
  ];
}
