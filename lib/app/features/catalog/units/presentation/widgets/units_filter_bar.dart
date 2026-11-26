import 'package:flutter/material.dart';
import 'package:accounting_software/app/core/localization/translations/app_key.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_filter_bar/filter_bar.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_searchable_dropdown/searchable_dropdown.dart';
import 'package:accounting_software/app/features/catalog/units/domain/entity/catalog_unit.dart';
import 'package:accounting_software/app/features/catalog/units/domain/entity/unit_list_query.dart';
import 'package:accounting_software/app/features/catalog/units/presentation/localization/units_keys.dart';

class UnitsFilterBar {
  static AppKey statusLabel(UnitStatusFilter value) => switch (value) {
    UnitStatusFilter.all => UnitsKeys.all,
    UnitStatusFilter.active => UnitsKeys.active,
    UnitStatusFilter.inactive => UnitsKeys.inactive,
  };

  static AppKey typeLabel(UnitType value) => switch (value) {
    UnitType.weight => UnitsKeys.weight,
    UnitType.length => UnitsKeys.length,
    UnitType.volume => UnitsKeys.volume,
    UnitType.piece => UnitsKeys.piece,
  };

  static const sortOptions = [
    FilterBarSortOption(key: 'name', label: UnitsKeys.sortByName),
  ];

  static List<FilterBarFilter> activeFilters(
    BuildContext context,
    UnitListQuery query, {
    required ValueChanged<String> onSearchChanged,
    required ValueChanged<UnitStatusFilter> onStatusChanged,
    required ValueChanged<UnitType?> onTypeChanged,
  }) => [
    if (query.search.isNotEmpty)
      FilterBarFilter(id: FilterBar.searchFilterId, label: UnitsKeys.search, value: query.search, onRemove: () => onSearchChanged('')),
    if (query.status != UnitStatusFilter.all)
      FilterBarFilter(id: 'status', label: UnitsKeys.status, value: statusLabel(query.status).tr(context: context), onRemove: () => onStatusChanged(UnitStatusFilter.all)),
    if (query.type != null)
      FilterBarFilter(id: 'type', label: UnitsKeys.type, value: typeLabel(query.type!).tr(context: context), onRemove: () => onTypeChanged(null)),
  ];

  static List<Widget> controls(
    BuildContext context,
    UnitListQuery query, {
    required ValueChanged<UnitStatusFilter> onStatusChanged,
    required ValueChanged<UnitType?> onTypeChanged,
  }) => [
    SearchableDropdown<UnitStatusFilter>(
      options: const [UnitStatusFilter.active, UnitStatusFilter.inactive],
      labelKey: UnitsKeys.status,
      optionLabel: (value) => statusLabel(value).tr(context: context),
      value: query.status == UnitStatusFilter.all ? null : query.status,
      clearable: false,
      mode: SearchableDropdownMode.panel,
      allOptionLabel: UnitsKeys.all,
      onChanged: (value) => onStatusChanged(value ?? UnitStatusFilter.all),
    ),
    SearchableDropdown<UnitType>(
      options: UnitType.values,
      labelKey: UnitsKeys.type,
      optionLabel: (value) => typeLabel(value).tr(context: context),
      value: query.type,
      clearable: true,
      mode: SearchableDropdownMode.panel,
      onChanged: onTypeChanged,
    ),
  ];
}
