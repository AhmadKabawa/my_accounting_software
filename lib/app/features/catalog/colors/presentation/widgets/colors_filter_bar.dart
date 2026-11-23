import 'package:flutter/material.dart';
import 'package:accounting_software/app/core/localization/translations/app_key.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_filter_bar/filter_bar.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_searchable_dropdown/searchable_dropdown.dart';
import 'package:accounting_software/app/features/catalog/colors/domain/entity/color_list_query.dart';
import 'package:accounting_software/app/features/catalog/colors/presentation/localization/colors_keys.dart';

abstract final class ColorsFilterBar {
  static AppKey statusLabel(ColorStatusFilter value) => switch (value) {
    ColorStatusFilter.all => ColorsKeys.allStatuses,
    ColorStatusFilter.active => ColorsKeys.active,
    ColorStatusFilter.inactive => ColorsKeys.inactive,
  };

  static const sortOptions = [
    FilterBarSortOption(key: 'order', label: ColorsKeys.sortByOrder),
    FilterBarSortOption(key: 'name', label: ColorsKeys.sortByName),
    FilterBarSortOption(key: 'code', label: ColorsKeys.sortByCode),
  ];

  static List<FilterBarFilter> activeFilters(
    BuildContext context,
    ColorListQuery query, {
    required ValueChanged<String> onSearchChanged,
    required ValueChanged<ColorStatusFilter> onStatusChanged,
  }) => [
    if (query.search.isNotEmpty)
      FilterBarFilter(
        id: FilterBar.searchFilterId,
        label: ColorsKeys.searchHint,
        value: query.search,
        onRemove: () => onSearchChanged(''),
      ),
    if (query.status != ColorStatusFilter.all)
      FilterBarFilter(
        id: 'status',
        label: ColorsKeys.status,
        value: statusLabel(query.status).tr(context: context),
        onRemove: () => onStatusChanged(ColorStatusFilter.all),
      ),
  ];

  static List<Widget> controls(
    BuildContext context,
    ColorListQuery query, {
    required ValueChanged<ColorStatusFilter> onStatusChanged,
  }) => [
    SearchableDropdown<ColorStatusFilter>(
      options: const [ColorStatusFilter.active, ColorStatusFilter.inactive],
      labelKey: ColorsKeys.status,
      optionLabel: (value) => statusLabel(value).tr(context: context),
      value: query.status == ColorStatusFilter.all ? null : query.status,
      clearable: false,
      mode: SearchableDropdownMode.panel,
      allOptionLabel: ColorsKeys.allStatuses,
      onChanged: (value) => onStatusChanged(value ?? ColorStatusFilter.all),
    ),
  ];
}
