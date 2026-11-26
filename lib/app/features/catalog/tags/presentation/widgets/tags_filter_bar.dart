import 'package:flutter/material.dart';
import 'package:accounting_software/app/core/localization/translations/app_key.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_filter_bar/filter_bar.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_searchable_dropdown/searchable_dropdown.dart';
import 'package:accounting_software/app/features/catalog/tags/domain/entity/tag_list_query.dart';
import 'package:accounting_software/app/features/catalog/tags/presentation/localization/tags_keys.dart';

class TagsFilterBar extends StatelessWidget {
  const TagsFilterBar({
    super.key,
    required this.query,
    required this.onSearchChanged,
    required this.onStatusChanged,
    required this.onClearAll,
    this.onSort,
  });

  final TagListQuery query;
  final ValueChanged<String> onSearchChanged;
  final ValueChanged<TagStatusFilter> onStatusChanged;
  final VoidCallback onClearAll;
  final void Function(TagSortField field, bool ascending)? onSort;

  static AppKey statusLabel(TagStatusFilter value) => switch (value) {
    TagStatusFilter.all => TagsKeys.allStatuses,
    TagStatusFilter.active => TagsKeys.active,
    TagStatusFilter.inactive => TagsKeys.inactive,
  };

  static const sortOptions = [
    FilterBarSortOption(key: 'name', label: TagsKeys.sortByName),
    FilterBarSortOption(key: 'slug', label: TagsKeys.sortBySlug),
  ];

  static List<FilterBarFilter> activeFilters(
    BuildContext context,
    TagListQuery query, {
    required ValueChanged<String> onSearchChanged,
    required ValueChanged<TagStatusFilter> onStatusChanged,
  }) => [
    if (query.search.isNotEmpty)
      FilterBarFilter(
        id: FilterBar.searchFilterId,
        label: TagsKeys.searchHint,
        value: query.search,
        onRemove: () => onSearchChanged(''),
      ),
    if (query.status != TagStatusFilter.all)
      FilterBarFilter(
        id: 'status',
        label: TagsKeys.status,
        value: statusLabel(query.status).tr(context: context),
        onRemove: () => onStatusChanged(TagStatusFilter.all),
      ),
  ];

  static List<Widget> controls(
    BuildContext context,
    TagListQuery query, {
    required ValueChanged<TagStatusFilter> onStatusChanged,
  }) => [
    SearchableDropdown<TagStatusFilter>(
      options: const [TagStatusFilter.active, TagStatusFilter.inactive],
      labelKey: TagsKeys.status,
      optionLabel: (value) => statusLabel(value).tr(context: context),
      value: query.status == TagStatusFilter.all ? null : query.status,
      clearable: false,
      mode: SearchableDropdownMode.panel,
      allOptionLabel: TagsKeys.allStatuses,
      onChanged: (value) => onStatusChanged(value ?? TagStatusFilter.all),
    ),
  ];

  @override
  Widget build(BuildContext context) => FilterBar(
    searchHintKey: TagsKeys.searchHint,
    debounce: Duration.zero,
    onSearchChanged: onSearchChanged,
    onClearAll: onClearAll,
    sortOptions: sortOptions,
    sortKey: query.sortField.name,
    sortAscending: query.sortAscending,
    onSort: (key, ascending) {
      final field = TagSortField.tryParse(key);
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
