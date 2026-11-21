import 'package:flutter/material.dart';
import 'package:accounting_software/app/core/localization/translations/app_key.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_filter_bar/filter_bar.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_searchable_dropdown/searchable_dropdown.dart';
import 'package:accounting_software/app/features/catalog/colors/domain/entity/color_list_query.dart';
import 'package:accounting_software/app/features/catalog/colors/presentation/localization/colors_keys.dart';

/// Search + status filter for colors.
///
/// The parent owns the Cubit; this widget only renders values and callbacks.
class ColorsFilterBar extends StatelessWidget {
  const ColorsFilterBar({
    super.key,
    required this.query,
    required this.onSearchChanged,
    required this.onStatusChanged,
    required this.onClearAll,
  });

  final ColorListQuery query;
  final ValueChanged<String> onSearchChanged;
  final ValueChanged<ColorStatusFilter> onStatusChanged;
  final VoidCallback onClearAll;

  static AppKey statusLabel(ColorStatusFilter value) => switch (value) {
    ColorStatusFilter.all => ColorsKeys.allStatuses,
    ColorStatusFilter.active => ColorsKeys.active,
    ColorStatusFilter.inactive => ColorsKeys.inactive,
  };

  @override
  Widget build(BuildContext context) => FilterBar(
    searchHintKey: ColorsKeys.searchHint,
    debounce: Duration.zero,
    onSearchChanged: onSearchChanged,
    onClearAll: onClearAll,
    activeFilters: [
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
    ],
    filterControls: [
      SearchableDropdown<ColorStatusFilter>(
        options: ColorStatusFilter.values,
        labelKey: ColorsKeys.status,
        optionLabel: (value) => statusLabel(value).tr(context: context),
        value: query.status,
        clearable: false,
        onChanged: (value) {
          if (value != null) onStatusChanged(value);
        },
      ),
    ],
  );
}
