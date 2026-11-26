import 'package:flutter/material.dart';
import 'package:accounting_software/app/core/localization/translations/app_key.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_filter_bar/filter_bar.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_searchable_dropdown/searchable_dropdown.dart';
import 'package:accounting_software/app/features/catalog/categories/domain/entity/category_list_query.dart';
import 'package:accounting_software/app/features/catalog/categories/presentation/localization/categories_keys.dart';

class CategoriesFilterBar {
  const CategoriesFilterBar._();

  static const sortOptions = [
    FilterBarSortOption(key: 'name', label: CategoriesKeys.sortByName),
    FilterBarSortOption(key: 'sortOrder', label: CategoriesKeys.sortByOrder),
    FilterBarSortOption(key: 'productCount', label: CategoriesKeys.sortByProducts),
  ];

  static AppKey statusLabel(CategoryStatusFilter value) => switch (value) {
    CategoryStatusFilter.all => CategoriesKeys.allStatuses,
    CategoryStatusFilter.active => CategoriesKeys.active,
    CategoryStatusFilter.inactive => CategoriesKeys.inactive,
  };

  static AppKey levelLabel(CategoryLevelFilter value) => switch (value) {
    CategoryLevelFilter.all => CategoriesKeys.allLevels,
    CategoryLevelFilter.roots => CategoriesKeys.roots,
    CategoryLevelFilter.leaves => CategoriesKeys.leaves,
  };

  static AppKey usageLabel(CategoryUsageFilter value) => switch (value) {
    CategoryUsageFilter.all => CategoriesKeys.allUsage,
    CategoryUsageFilter.withProducts => CategoriesKeys.withProducts,
    CategoryUsageFilter.withoutProducts => CategoriesKeys.withoutProducts,
  };

  static List<FilterBarFilter> activeFilters(
    BuildContext context,
    CategoryListQuery query, {
    required ValueChanged<String> onSearchChanged,
    required ValueChanged<CategoryStatusFilter> onStatusChanged,
    required ValueChanged<CategoryLevelFilter> onLevelChanged,
    required ValueChanged<CategoryUsageFilter> onUsageChanged,
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
    if (query.level != CategoryLevelFilter.all)
      FilterBarFilter(
        id: 'level',
        label: CategoriesKeys.level,
        value: levelLabel(query.level).tr(context: context),
        onRemove: () => onLevelChanged(CategoryLevelFilter.all),
      ),
    if (query.usage != CategoryUsageFilter.all)
      FilterBarFilter(
        id: 'usage',
        label: CategoriesKeys.usage,
        value: usageLabel(query.usage).tr(context: context),
        onRemove: () => onUsageChanged(CategoryUsageFilter.all),
      ),
  ];

  static List<Widget> controls(
    BuildContext context,
    CategoryListQuery query, {
    required ValueChanged<CategoryStatusFilter> onStatusChanged,
    required ValueChanged<CategoryLevelFilter> onLevelChanged,
    required ValueChanged<CategoryUsageFilter> onUsageChanged,
  }) => [
    SearchableDropdown<CategoryStatusFilter>(
      options: const [CategoryStatusFilter.active, CategoryStatusFilter.inactive],
      labelKey: CategoriesKeys.status,
      optionLabel: (value) => statusLabel(value).tr(context: context),
      value: query.status == CategoryStatusFilter.all ? null : query.status,
      clearable: false,
      mode: SearchableDropdownMode.panel,
      allOptionLabel: CategoriesKeys.allStatuses,
      onChanged: (value) => onStatusChanged(value ?? CategoryStatusFilter.all),
    ),
    SearchableDropdown<CategoryLevelFilter>(
      options: const [CategoryLevelFilter.roots, CategoryLevelFilter.leaves],
      labelKey: CategoriesKeys.level,
      optionLabel: (value) => levelLabel(value).tr(context: context),
      value: query.level == CategoryLevelFilter.all ? null : query.level,
      clearable: false,
      mode: SearchableDropdownMode.panel,
      allOptionLabel: CategoriesKeys.allLevels,
      onChanged: (value) => onLevelChanged(value ?? CategoryLevelFilter.all),
    ),
    SearchableDropdown<CategoryUsageFilter>(
      options: const [
        CategoryUsageFilter.withProducts,
        CategoryUsageFilter.withoutProducts,
      ],
      labelKey: CategoriesKeys.usage,
      optionLabel: (value) => usageLabel(value).tr(context: context),
      value: query.usage == CategoryUsageFilter.all ? null : query.usage,
      clearable: false,
      mode: SearchableDropdownMode.panel,
      allOptionLabel: CategoriesKeys.allUsage,
      onChanged: (value) => onUsageChanged(value ?? CategoryUsageFilter.all),
    ),
  ];
}
