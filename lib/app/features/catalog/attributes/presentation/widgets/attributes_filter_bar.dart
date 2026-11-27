import 'package:flutter/material.dart';
import 'package:accounting_software/app/core/localization/translations/app_key.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_filter_bar/filter_bar.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_searchable_dropdown/searchable_dropdown.dart';
import 'package:accounting_software/app/features/catalog/attributes/domain/entity/catalog_attribute.dart';
import 'package:accounting_software/app/features/catalog/attributes/domain/entity/attribute_list_query.dart';
import 'package:accounting_software/app/features/catalog/attributes/presentation/localization/attributes_keys.dart';

class AttributesFilterBar {
  static AppKey statusLabel(AttributeStatusFilter value) => switch (value) {
    AttributeStatusFilter.all => AttributesKeys.all,
    AttributeStatusFilter.active => AttributesKeys.active,
    AttributeStatusFilter.inactive => AttributesKeys.inactive,
  };
  static AppKey typeLabel(AttributeDataType value) => switch (value) {
    AttributeDataType.text => AttributesKeys.text,
    AttributeDataType.number => AttributesKeys.number,
    AttributeDataType.boolean => AttributesKeys.boolean,
    AttributeDataType.date => AttributesKeys.date,
    AttributeDataType.json => AttributesKeys.json,
    AttributeDataType.option => AttributesKeys.option,
  };
  static List<FilterBarFilter> activeFilters(
    BuildContext context,
    AttributeListQuery query, {
    required ValueChanged<String> onSearchChanged,
    required ValueChanged<AttributeStatusFilter> onStatusChanged,
    required ValueChanged<AttributeDataType?> onTypeChanged,
    required ValueChanged<AttributeFilterableFilter> onFilterableChanged,
  }) => [
    if (query.search.isNotEmpty)
      FilterBarFilter(
        id: FilterBar.searchFilterId,
        label: AttributesKeys.search,
        value: query.search,
        onRemove: () => onSearchChanged(''),
      ),
    if (query.status != AttributeStatusFilter.all)
      FilterBarFilter(
        id: 'status',
        label: AttributesKeys.status,
        value: statusLabel(query.status).tr(context: context),
        onRemove: () => onStatusChanged(AttributeStatusFilter.all),
      ),
    if (query.dataType != null)
      FilterBarFilter(
        id: 'type',
        label: AttributesKeys.dataType,
        value: typeLabel(query.dataType!).tr(context: context),
        onRemove: () => onTypeChanged(null),
      ),
    if (query.filterable != AttributeFilterableFilter.all)
      FilterBarFilter(
        id: 'filterable',
        label: AttributesKeys.filterable,
        value:
            (query.filterable == AttributeFilterableFilter.filterable
                    ? AttributesKeys.filterableOn
                    : AttributesKeys.notFilterable)
                .tr(context: context),
        onRemove: () => onFilterableChanged(AttributeFilterableFilter.all),
      ),
  ];
  static List<Widget> controls(
    BuildContext context,
    AttributeListQuery query, {
    required ValueChanged<AttributeStatusFilter> onStatusChanged,
    required ValueChanged<AttributeDataType?> onTypeChanged,
    required ValueChanged<AttributeFilterableFilter> onFilterableChanged,
  }) => [
    SearchableDropdown<AttributeStatusFilter>(
      options: const [
        AttributeStatusFilter.active,
        AttributeStatusFilter.inactive,
      ],
      labelKey: AttributesKeys.status,
      optionLabel: (v) => statusLabel(v).tr(context: context),
      value: query.status == AttributeStatusFilter.all ? null : query.status,
      clearable: false,
      mode: SearchableDropdownMode.panel,
      deferPanelRefresh: true,
      deferPanelRefresh: true,
      allOptionLabel: AttributesKeys.all,
      onChanged: (v) => onStatusChanged(v ?? AttributeStatusFilter.all),
    ),
    SearchableDropdown<AttributeDataType>(
      options: AttributeDataType.values,
      labelKey: AttributesKeys.dataType,
      optionLabel: (v) => typeLabel(v).tr(context: context),
      value: query.dataType,
      mode: SearchableDropdownMode.panel,
      deferPanelRefresh: true,
      onChanged: onTypeChanged,
    ),
    SearchableDropdown<AttributeFilterableFilter>(
      options: const [
        AttributeFilterableFilter.filterable,
        AttributeFilterableFilter.notFilterable,
      ],
      labelKey: AttributesKeys.filterable,
      optionLabel: (v) =>
          (v == AttributeFilterableFilter.filterable
                  ? AttributesKeys.filterableOn
                  : AttributesKeys.notFilterable)
              .tr(context: context),
      value: query.filterable == AttributeFilterableFilter.all
          ? null
          : query.filterable,
      clearable: false,
      mode: SearchableDropdownMode.panel,
      deferPanelRefresh: true,
      allOptionLabel: AttributesKeys.all,
      onChanged: (v) => onFilterableChanged(v ?? AttributeFilterableFilter.all),
    ),
  ];
}
