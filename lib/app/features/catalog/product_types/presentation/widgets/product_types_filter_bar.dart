import 'package:flutter/material.dart';
import 'package:accounting_software/app/core/localization/translations/app_key.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_filter_bar/filter_bar.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_searchable_dropdown/searchable_dropdown.dart';
import 'package:accounting_software/app/features/catalog/product_types/domain/entity/product_type_list_query.dart';
import 'package:accounting_software/app/features/catalog/product_types/presentation/localization/product_types_keys.dart';

abstract final class ProductTypesFilterBar {
  static AppKey statusLabel(ProductTypeStatusFilter value) => switch (value) {
    ProductTypeStatusFilter.all => ProductTypesKeys.allStatuses,
    ProductTypeStatusFilter.active => ProductTypesKeys.active,
    ProductTypeStatusFilter.inactive => ProductTypesKeys.inactive,
  };

  static List<FilterBarFilter> activeFilters(
    BuildContext context,
    ProductTypeListQuery query, {
    required ValueChanged<String> onSearchChanged,
    required ValueChanged<ProductTypeStatusFilter> onStatusChanged,
  }) => [
    if (query.search.trim().isNotEmpty)
      FilterBarFilter(
        id: FilterBar.searchFilterId,
        label: ProductTypesKeys.searchHint,
        value: query.search,
        onRemove: () => onSearchChanged(''),
      ),
    if (query.status != ProductTypeStatusFilter.all)
      FilterBarFilter(
        id: 'status',
        label: ProductTypesKeys.status,
        value: statusLabel(query.status).tr(context: context),
        onRemove: () => onStatusChanged(ProductTypeStatusFilter.all),
      ),
  ];

  static List<Widget> controls(
    BuildContext context,
    ProductTypeListQuery query, {
    required ValueChanged<ProductTypeStatusFilter> onStatusChanged,
  }) => [
    SearchableDropdown<ProductTypeStatusFilter>(
      options: const [
        ProductTypeStatusFilter.active,
        ProductTypeStatusFilter.inactive,
      ],
      labelKey: ProductTypesKeys.status,
      optionLabel: (value) => statusLabel(value).tr(context: context),
      value: query.status == ProductTypeStatusFilter.all ? null : query.status,
      allOptionLabel: ProductTypesKeys.allStatuses,
      mode: SearchableDropdownMode.panel,
      onChanged: (value) =>
          onStatusChanged(value ?? ProductTypeStatusFilter.all),
    ),
  ];
}
