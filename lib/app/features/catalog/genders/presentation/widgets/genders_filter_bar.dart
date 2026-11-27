import 'package:flutter/material.dart';
import 'package:accounting_software/app/core/localization/translations/app_key.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_filter_bar/filter_bar.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_searchable_dropdown/searchable_dropdown.dart';
import 'package:accounting_software/app/features/catalog/genders/domain/entity/gender_list_query.dart';
import 'package:accounting_software/app/features/catalog/genders/presentation/localization/genders_keys.dart';

class GendersFilterBar {
  static AppKey statusLabel(GenderStatusFilter value) => switch (value) {
    GenderStatusFilter.all => GendersKeys.allStatuses,
    GenderStatusFilter.active => GendersKeys.active,
    GenderStatusFilter.inactive => GendersKeys.inactive,
  };

  static const sortOptions = [
    FilterBarSortOption(key: 'order', label: GendersKeys.sortByOrder),
    FilterBarSortOption(key: 'name', label: GendersKeys.sortByName),
    FilterBarSortOption(key: 'code', label: GendersKeys.sortByCode),
  ];

  static List<FilterBarFilter> activeFilters(
    BuildContext context,
    GenderListQuery query, {
    required ValueChanged<String> onSearchChanged,
    required ValueChanged<GenderStatusFilter> onStatusChanged,
  }) => [
    if (query.search.isNotEmpty)
      FilterBarFilter(
        id: FilterBar.searchFilterId,
        label: GendersKeys.searchHint,
        value: query.search,
        onRemove: () => onSearchChanged(''),
      ),
    if (query.status != GenderStatusFilter.all)
      FilterBarFilter(
        id: 'status',
        label: GendersKeys.status,
        value: statusLabel(query.status).tr(context: context),
        onRemove: () => onStatusChanged(GenderStatusFilter.all),
      ),
  ];

  static List<Widget> controls(
    BuildContext context,
    GenderListQuery query, {
    required ValueChanged<GenderStatusFilter> onStatusChanged,
  }) => [
    SearchableDropdown<GenderStatusFilter>(
      options: const [GenderStatusFilter.active, GenderStatusFilter.inactive],
      labelKey: GendersKeys.status,
      optionLabel: (value) => statusLabel(value).tr(context: context),
      value: query.status == GenderStatusFilter.all ? null : query.status,
      allOptionLabel: GendersKeys.allStatuses,
      mode: SearchableDropdownMode.panel,
      onChanged: (value) => onStatusChanged(value ?? GenderStatusFilter.all),
    ),
  ];
}
