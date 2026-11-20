import 'package:flutter/material.dart';
import 'package:accounting_software/app/core/localization/translations/app_key.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_filter_bar/filter_bar.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_searchable_dropdown/searchable_dropdown.dart';
import 'package:accounting_software/app/features/catalog/domain/entity/brand_list_query.dart';
import 'package:accounting_software/app/features/catalog/presentation/cubit/brands_list_cubit.dart';
import 'package:accounting_software/app/features/catalog/presentation/localization/brands_keys.dart';

/// Search + status filter for brands.
///
/// Filter source: the status values are a closed domain enum
/// ([BrandStatusFilter]), so they are fixed in the client, not fetched.
class BrandsFilterBar extends StatelessWidget {
  const BrandsFilterBar({super.key, required this.query, required this.cubit});

  final BrandListQuery query;
  final BrandsListCubit cubit;

  static AppKey statusLabel(BrandStatusFilter value) => switch (value) {
    BrandStatusFilter.all => BrandsKeys.allStatuses,
    BrandStatusFilter.active => BrandsKeys.active,
    BrandStatusFilter.inactive => BrandsKeys.inactive,
  };

  @override
  Widget build(BuildContext context) => FilterBar(
    searchHintKey: BrandsKeys.searchHint,
    // The cubit debounces already; avoid a second 300ms delay here.
    debounce: Duration.zero,
    onSearchChanged: cubit.searchChanged,
    onClearAll: () {
      cubit.searchChanged('');
      cubit.setStatus(BrandStatusFilter.all);
    },
    activeFilters: [
      if (query.search.isNotEmpty)
        FilterBarFilter(
          id: FilterBar.searchFilterId,
          label: BrandsKeys.searchHint,
          value: query.search,
          onRemove: () => cubit.searchChanged(''),
        ),
      if (query.status != BrandStatusFilter.all)
        FilterBarFilter(
          id: 'status',
          label: BrandsKeys.status,
          value: statusLabel(query.status).tr(context: context),
          onRemove: () => cubit.setStatus(BrandStatusFilter.all),
        ),
    ],
    filterControls: [
      SearchableDropdown<BrandStatusFilter>(
        options: BrandStatusFilter.values,
        labelKey: BrandsKeys.status,
        optionLabel: (value) => statusLabel(value).tr(context: context),
        value: query.status,
        clearable: false,
        onChanged: (value) {
          if (value != null) cubit.setStatus(value);
        },
      ),
    ],
  );
}
