import 'package:flutter/material.dart';
import 'package:accounting_software/app/core/localization/translations/app_key.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_filter_bar/filter_bar.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_searchable_dropdown/searchable_dropdown.dart';
import 'package:accounting_software/app/features/catalog/option_sets/domain/entity/option_set_list_query.dart';
import 'package:accounting_software/app/features/catalog/option_sets/presentation/localization/option_sets_keys.dart';

class OptionSetsFilterBar {
  static AppKey statusLabel(OptionSetStatusFilter value) => switch (value) {
    OptionSetStatusFilter.all => OptionSetsKeys.all,
    OptionSetStatusFilter.active => OptionSetsKeys.active,
    OptionSetStatusFilter.inactive => OptionSetsKeys.inactive,
  };

  static const sortOptions = [
    FilterBarSortOption(key: 'name', label: OptionSetsKeys.sortByName),
  ];

  static List<FilterBarFilter> activeFilters(
    BuildContext context,
    OptionSetListQuery query, {
    required ValueChanged<String> onSearchChanged,
    required ValueChanged<OptionSetStatusFilter> onStatusChanged,
  }) => [
    if (query.search.isNotEmpty)
      FilterBarFilter(
        id: FilterBar.searchFilterId,
        label: OptionSetsKeys.search,
        value: query.search,
        onRemove: () => onSearchChanged(''),
      ),
    if (query.status != OptionSetStatusFilter.all)
      FilterBarFilter(
        id: 'status',
        label: OptionSetsKeys.status,
        value: statusLabel(query.status).tr(context: context),
        onRemove: () => onStatusChanged(OptionSetStatusFilter.all),
      ),
  ];

  static List<Widget> controls(
    BuildContext context,
    OptionSetListQuery query, {
    required ValueChanged<OptionSetStatusFilter> onStatusChanged,
  }) => [
    SearchableDropdown<OptionSetStatusFilter>(
      options: const [OptionSetStatusFilter.active, OptionSetStatusFilter.inactive],
      labelKey: OptionSetsKeys.status,
      optionLabel: (value) => statusLabel(value).tr(context: context),
      value: query.status == OptionSetStatusFilter.all ? null : query.status,
      clearable: false,
      mode: SearchableDropdownMode.panel,
      allOptionLabel: OptionSetsKeys.all,
      onChanged: (value) => onStatusChanged(value ?? OptionSetStatusFilter.all),
    ),
  ];
}
