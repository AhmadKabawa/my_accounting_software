import 'package:flutter/material.dart';
import 'package:accounting_software/app/core/localization/translations/app_key.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_filter_bar/filter_bar.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_searchable_dropdown/searchable_dropdown.dart';
import 'package:accounting_software/app/features/catalog/brands/domain/entity/brand_list_query.dart';
import 'package:accounting_software/app/features/catalog/brands/presentation/localization/brands_keys.dart';

/// Search + status filter for brands.
///
/// The parent owns the Cubit; this widget only renders values and callbacks.
class BrandsFilterBar extends StatelessWidget {
  const BrandsFilterBar({
    super.key,
    required this.query,
    required this.onSearchChanged,
    required this.onStatusChanged,
    required this.onClearAll,
  });

  final BrandListQuery query;
  final ValueChanged<String> onSearchChanged;
  final ValueChanged<BrandStatusFilter> onStatusChanged;
  final VoidCallback onClearAll;

  static AppKey statusLabel(BrandStatusFilter value) => switch (value) {
    BrandStatusFilter.all => BrandsKeys.allStatuses,
    BrandStatusFilter.active => BrandsKeys.active,
    BrandStatusFilter.inactive => BrandsKeys.inactive,
  };

  @override
  Widget build(BuildContext context) => FilterBar(
    searchHintKey: BrandsKeys.searchHint,
    debounce: Duration.zero,
    onSearchChanged: onSearchChanged,
    onClearAll: onClearAll,
    activeFilters: [
      if (query.search.isNotEmpty)
        FilterBarFilter(
          id: FilterBar.searchFilterId,
          label: BrandsKeys.searchHint,
          value: query.search,
          onRemove: () => onSearchChanged(''),
        ),
      if (query.status != BrandStatusFilter.all)
        FilterBarFilter(
          id: 'status',
          label: BrandsKeys.status,
          value: statusLabel(query.status).tr(context: context),
          onRemove: () => onStatusChanged(BrandStatusFilter.all),
        ),
    ],
    filterControls: [
      SearchableDropdown<BrandStatusFilter>(
        options: const [
          BrandStatusFilter.active,
          BrandStatusFilter.inactive,
        ],
        labelKey: BrandsKeys.status,
        optionLabel: (value) => statusLabel(value).tr(context: context),
        value: query.status == BrandStatusFilter.all ? null : query.status,
        allOptionLabel: BrandsKeys.allStatuses,
        mode: SearchableDropdownMode.panel,
        onChanged: (value) =>
            onStatusChanged(value ?? BrandStatusFilter.all),
      ),
    ],
  );
}
