import 'package:flutter/material.dart';
import 'package:accounting_software/app/core/localization/translations/app_key.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_filter_bar/filter_bar.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_searchable_dropdown/searchable_dropdown.dart';
import 'package:accounting_software/app/features/catalog/categories/domain/entity/category_list_query.dart';
import 'package:accounting_software/app/features/catalog/categories/presentation/localization/categories_keys.dart';

class CategoriesFilterBar {
  const CategoriesFilterBar._();

  static AppKey statusLabel(CategoryStatusFilter value) => switch (value) {
    CategoryStatusFilter.all => CategoriesKeys.allStatuses,
    CategoryStatusFilter.active => CategoriesKeys.active,
    CategoryStatusFilter.inactive => CategoriesKeys.inactive,
  };

  static List<FilterBarFilter> activeFilters(
    BuildContext context,
    CategoryListQuery query, {
    required ValueChanged<String> onSearchChanged,
    required ValueChanged<CategoryStatusFilter> onStatusChanged,
  }) => [
    if (query.search.trim().isNotEmpty)
      FilterBarFilter(
        id: FilterBar.searchFilterId,
        label: CategoriesKeys.searchHint,
        value: query.search,
        onRemove: () => onSearchChanged(''),
      ),
    if (query.status != CategoryStatusFilter.all)
      FilterBarFilter(
        id: 'status',
        label: CategoriesKeys.status,
        value: statusLabel(query.status).tr(context: context),
        onRemove: () => onStatusChanged(CategoryStatusFilter.all),
      ),
  ];

  static List<Widget> controls(
    BuildContext context,
    CategoryListQuery query, {
    required ValueChanged<CategoryStatusFilter> onStatusChanged,
  }) => [
    SearchableDropdown<CategoryStatusFilter>(
      options: const [
        CategoryStatusFilter.active,
        CategoryStatusFilter.inactive,
      ],
      labelKey: CategoriesKeys.status,
      optionLabel: (value) => statusLabel(value).tr(context: context),
      value: query.status == CategoryStatusFilter.all ? null : query.status,
      clearable: false,
      mode: SearchableDropdownMode.panel,
      allOptionLabel: CategoriesKeys.allStatuses,
      onChanged: (value) => onStatusChanged(value ?? CategoryStatusFilter.all),
    ),
  ];
}
