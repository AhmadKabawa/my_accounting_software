import 'package:flutter/widgets.dart';
import 'package:accounting_software/app/core/localization/keys/catalog_ui_keys.dart';
import 'package:accounting_software/app/core/localization/translations/app_key.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_data_view/app_view_mode.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_filter_bar/filter_bar.dart';

/// Everything a list screen tells `ListPageTemplate` about its toolbar.
///
/// A screen describes WHAT it has (search, filters, sort fields, view modes,
/// refresh); the template decides WHERE each control goes and builds it. To
/// move or restyle a control for every CRUD page, change the template, not the
/// screens.
class ListToolbarConfig {
  const ListToolbarConfig({
    required this.onSearchChanged,
    required this.onClearAll,
    this.searchHintKey = CatalogUiKeys.search,
    this.searchDebounce = FilterBar.defaultSearchDebounce,
    this.activeFilters = const [],
    this.filterControls = const [],
    this.sortOptions = const [],
    this.sortKey,
    this.sortAscending = true,
    this.onSort,
    this.sorts = const [],
    this.onSortsChanged,
    this.maxSorts = 2,
    this.viewModes = const [],
    this.viewMode,
    this.onViewModeChanged,
    this.onRefresh,
    this.refreshing = false,
  });

  final ValueChanged<String> onSearchChanged;
  final VoidCallback onClearAll;
  final AppKey searchHintKey;
  final Duration searchDebounce;
  final List<FilterBarFilter> activeFilters;
  final List<Widget> filterControls;

  /// Sorting is done by the server: [onSort] must re-query, not reorder rows.
  final List<FilterBarSortOption> sortOptions;
  final String? sortKey;
  final bool sortAscending;
  final void Function(String key, bool ascending)? onSort;

  /// Multi-sort (preferred): the active criteria in priority order, changed
  /// from the sort menu's up/down arrows. Replaces [sortKey]/[onSort].
  final List<FilterBarSort> sorts;
  final ValueChanged<List<FilterBarSort>>? onSortsChanged;
  final int maxSorts;

  /// Two or more modes show the view menu. [viewMode] null = the default.
  final List<AppViewMode> viewModes;
  final AppViewMode? viewMode;
  final ValueChanged<AppViewMode>? onViewModeChanged;

  /// Not null = a refresh button right after the search field.
  final VoidCallback? onRefresh;
  final bool refreshing;
}
