import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_dropdown_menu/app_dropdown_menu.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_filter_bar/sort_panel.dart';
export 'package:accounting_software/app/core/presentation/widgets/app_filter_bar/sort_panel.dart'
    show FilterBarSortOption, FilterBarSort, toggleSort;
import 'package:accounting_software/app/core/localization/keys/catalog_ui_keys.dart';
import 'package:accounting_software/app/core/localization/translations/app_key.dart';
import 'package:accounting_software/app/core/presentation/design_system/responsive/extension/ui_extension.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_badge/app_badge.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_button/app_button.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_button/app_icon_button.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_filter_bar/filter_bar_style.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_icon/app_icon.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_text/app_text.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_text_field/app_text_field.dart';

export 'filter_bar_style.dart';

/// A filter chip represents an already-applied filter. Its owner controls
/// query state and data fetching; this widget only presents events and slots.
class FilterBarFilter {
  const FilterBarFilter({
    required this.id,
    required this.label,
    required this.value,
    required this.onRemove,
  });
  final Object id;
  final AppKey label;
  final String value;
  final VoidCallback onRemove;
}

/// One server-sortable field offered by the sort control.

/// The list toolbar: `[leading] [search pill] [sort] [filters] ... [trailing]`
/// in one wrapping row, then the filter row (when opened), then the active
/// filter chips with "clear all".
///
/// * [leading] is the view-mode switcher; [trailing] the page's primary
///   action. Both are slots: this widget knows nothing about them.
/// * Sort: give [sortOptions] and [onSort]; the control only reports
///   `(key, ascending)`; the owner queries the server. It appears only when
///   options exist, so a field the backend cannot sort is never offered.
/// * Filters: [filterControls] (a labelled row below the bar, opened by the
///   Filters button) or [filterPanelBuilder] (the builder owns its own apply
///   button, which is why none is drawn after it). The extra apply button is
///   drawn only for [filterControls] inside the phone sheet.
/// * [resultCount] is optional; it is shown as text, never as a chart.
/// * Give the chip that stands for the search text the id [searchFilterId]:
///   removing it (or "clear all") also empties the field.
/// * On phones: search first, then sort and filters, each in a bottom sheet.
class FilterBar extends StatefulWidget {
  /// Retained for source compatibility. Debouncing belongs to the query owner.
  static const defaultSearchDebounce = Duration.zero;

  /// Id of the [FilterBarFilter] that stands for the search text.
  static const searchFilterId = 'search';

  const FilterBar({
    super.key,
    required this.onSearchChanged,
    required this.activeFilters,
    required this.onClearAll,
    this.searchController,
    this.searchHintKey = CatalogUiKeys.search,
    this.filterPanelBuilder,
    this.filterControls = const [],
    this.onApply,
    this.debounce = defaultSearchDebounce,
    this.leading,
    this.trailing,
    this.sortOptions = const [],
    this.sortKey,
    this.sortAscending = true,
    this.onSort,
    this.sorts = const [],
    this.onSortsChanged,
    this.maxSorts = 2,
    this.searchSuffix,
    this.resultCount,
  });

  final ValueChanged<String> onSearchChanged;
  final List<FilterBarFilter> activeFilters;
  final VoidCallback onClearAll;
  final TextEditingController? searchController;
  final AppKey searchHintKey;
  final Widget Function(BuildContext context, VoidCallback apply)?
  filterPanelBuilder;
  final List<Widget> filterControls;
  final VoidCallback? onApply;

  /// Deprecated compatibility parameter; FilterBar never debounces locally.
  final Duration debounce;

  final Widget? leading;
  final Widget? trailing;
  final List<FilterBarSortOption> sortOptions;
  final String? sortKey;
  final bool sortAscending;
  final void Function(String key, bool ascending)? onSort;

  /// Multi-sort: the active criteria in priority order. When
  /// [onSortsChanged] is set it replaces [sortKey]/[onSort].
  final List<FilterBarSort> sorts;
  final ValueChanged<List<FilterBarSort>>? onSortsChanged;
  final int maxSorts;

  /// Placed right after the search field (e.g. a refresh button).
  final Widget? searchSuffix;
  final int? resultCount;

  @override
  State<FilterBar> createState() => _FilterBarState();
}

class _FilterBarState extends State<FilterBar> {
  static const double _compactBreakpoint = 720;
  static const double _minimumSearchWidth = 180;
  late final TextEditingController _ownedController;
  late final ValueNotifier<List<FilterBarSort>> _sortsNotifier;
  bool _showEditor = false;

  TextEditingController get _controller =>
      widget.searchController ?? _ownedController;

  @override
  void initState() {
    super.initState();
    _ownedController = TextEditingController();
    _sortsNotifier = ValueNotifier([...widget.sorts]);
  }

  @override
  void didUpdateWidget(covariant FilterBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!listEquals(oldWidget.sorts, widget.sorts)) {
      _sortsNotifier.value = [...widget.sorts];
    }
  }

  @override
  void dispose() {
    _sortsNotifier.dispose();
    _ownedController.dispose();
    super.dispose();
  }

  void _onSortsChanged(List<FilterBarSort> sorts) {
    _sortsNotifier.value = [...sorts];
    widget.onSortsChanged?.call(sorts);
  }

  Widget _multiSortPanel() => ValueListenableBuilder<List<FilterBarSort>>(
    valueListenable: _sortsNotifier,
    builder: (context, sorts, _) => SortPanel(
      options: widget.sortOptions,
      sorts: sorts,
      maxSorts: widget.maxSorts,
      onChanged: _onSortsChanged,
    ),
  );

  void _submitSearch() => widget.onSearchChanged(_controller.text);

  void _clearSearch() {
    _controller.clear();
    widget.onSearchChanged('');
  }

  void _clearAll() {
    _controller.clear();
    widget.onClearAll();
  }

  void _removeFilter(FilterBarFilter filter) {
    if (filter.id == FilterBar.searchFilterId) _controller.clear();
    filter.onRemove();
  }

  bool get _hasFilterEditor =>
      widget.filterPanelBuilder != null || widget.filterControls.isNotEmpty;

  bool get _multiSort => widget.onSortsChanged != null;
  bool get _hasSort =>
      widget.sortOptions.isNotEmpty && (_multiSort || widget.onSort != null);

  void _apply() => widget.onApply?.call();

  Future<void> _openFilters({required bool compact}) async {
    if (!_hasFilterEditor) return;
    if (!compact) {
      setState(() => _showEditor = !_showEditor);
      return;
    }
    final builder = widget.filterPanelBuilder;
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (sheet) => SingleChildScrollView(
        child: Padding(
          padding: sheet.ui.padding.all(AppSpacing.md),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AppText(CatalogUiKeys.filters, type: AppTextType.titleMedium),
              sheet.ui.spacing.gap(AppSpacing.md),
              if (builder != null)
                // The builder owns its apply button: no second one is drawn.
                builder(sheet, () {
                  _apply();
                  Navigator.of(sheet).pop();
                })
              else ...[
                for (final control in widget.filterControls) ...[
                  control,
                  sheet.ui.spacing.gap(AppSpacing.sm),
                ],
                AppButton(
                  CatalogUiKeys.apply,
                  onPressed: () {
                    _apply();
                    Navigator.of(sheet).pop();
                  },
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _openSort() async {
    await showModalBottomSheet<void>(
      context: context,
      useSafeArea: true,
      builder: (sheet) => _SortSheet(
        options: widget.sortOptions,
        sortKey: widget.sortKey,
        ascending: widget.sortAscending,
        onSort: (key, ascending) {
          widget.onSort!(key, ascending);
          Navigator.of(sheet).pop();
        },
      ),
    );
  }

  Widget _searchField() => ValueListenableBuilder<TextEditingValue>(
    valueListenable: _controller,
    builder: (context, value, _) => AppTextField(
      controller: _controller,
      labelKey: CatalogUiKeys.search,
      hintKey: widget.searchHintKey,
      prefixIcon: AppIcons.search,
      textInputAction: TextInputAction.search,
      onChanged: widget.onSearchChanged,
      onSubmitted: _submitSearch,
      suffix: value.text.isEmpty
          ? null
          : AppIconButton(
              AppIcons.close,
              tooltipKey: CatalogUiKeys.clearSearch,
              onPressed: _clearSearch,
            ),
    ),
  );

  Widget _sortButton({required bool compact}) {
    if (_multiSort) {
      if (compact) {
        return AppButton(
          CatalogUiKeys.sortBy,
          icon: AppIcons.sort,
          variant: AppButtonVariant.outlined,
          onPressed: () => showModalBottomSheet<void>(
            context: context,
            useSafeArea: true,
            builder: (_) => Padding(
              padding: context.ui.padding.all(AppSpacing.md),
              child: _multiSortPanel(),
            ),
          ),
        );
      }
      return AppDropdownMenu(
        anchorBuilder: (context, toggle, open) => AppButton(
          CatalogUiKeys.sortBy,
          icon: AppIcons.sort,
          variant: AppButtonVariant.outlined,
          onPressed: toggle,
        ),
        children: [_multiSortPanel()],
      );
    }
    final button = AppButton(
      CatalogUiKeys.sortBy,
      icon: AppIcons.sort,
      variant: AppButtonVariant.outlined,
      onPressed: compact ? _openSort : () {},
    );
    // A phone keeps the bottom sheet; wider screens get a small menu.
    if (compact) return button;
    return AppDropdownMenu(
      anchorBuilder: (context, toggle, open) => AppButton(
        CatalogUiKeys.sortBy,
        icon: AppIcons.sort,
        variant: AppButtonVariant.outlined,
        onPressed: toggle,
      ),
      children: [
        for (final option in widget.sortOptions)
          AppDropdownItem(
            label: option.label,
            selected: option.key == widget.sortKey,
            trailing: option.key == widget.sortKey
                ? AppIcon(
                    widget.sortAscending
                        ? AppIcons.sortAscending
                        : AppIcons.sortDescending,
                    size: AppIconSize.md,
                    color: context.ui.theme.saasColors.onSelected,
                  )
                : null,
            onPressed: () {
              // Choosing the active field again reverses its direction.
              final same = option.key == widget.sortKey;
              widget.onSort?.call(
                option.key,
                same ? !widget.sortAscending : true,
              );
            },
          ),
      ],
    );
  }

  Widget _filtersButton({required bool compact}) => AppButton(
    CatalogUiKeys.filters,
    icon: AppIcons.filter,
    variant: AppButtonVariant.outlined,
    onPressed: () => _openFilters(compact: compact),
  );

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final style = FilterBarStyle(context);
      final width = constraints.hasBoundedWidth
          ? constraints.maxWidth
          : MediaQuery.sizeOf(context).width;
      final compact = width < _compactBreakpoint;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (compact)
            _mobileToolbar(context, compact: true)
          else
            _wideToolbar(context, style, width),
          if (!compact && _showEditor && _hasFilterEditor) ...[
            context.ui.spacing.gap(AppSpacing.sm),
            if (widget.filterPanelBuilder != null)
              widget.filterPanelBuilder!(context, () {
                _apply();
                setState(() => _showEditor = false);
              })
            else
              _controlsRow(context, style),
          ],
          if (widget.activeFilters.isNotEmpty) ...[
            context.ui.spacing.gap(AppSpacing.sm),
            _activeFilters(context, style),
          ],
        ],
      );
    },
  );

  /// Phone: search; then view switcher, sort and filters; then the action.
  Widget _mobileToolbar(BuildContext context, {required bool compact}) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      Row(
        children: [
          Expanded(child: _searchField()),
          if (widget.searchSuffix != null) ...[
            context.ui.spacing.gap(AppSpacing.xs, axis: Axis.horizontal),
            widget.searchSuffix!,
          ],
        ],
      ),
      if (widget.leading != null ||
          _hasSort ||
          _hasFilterEditor ||
          widget.trailing != null) ...[
        context.ui.spacing.gap(AppSpacing.sm),
        Wrap(
          spacing: context.ui.spacing.sm,
          runSpacing: context.ui.spacing.sm,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            ?widget.leading,
            if (_hasSort) _sortButton(compact: compact),
            if (_hasFilterEditor) _filtersButton(compact: compact),
            ?widget.trailing,
          ],
        ),
      ],
    ],
  );

  /// One wrapping row, in this order: view switcher, search pill, sort,
  /// filters, result count, primary action (at the end).
  Widget _wideToolbar(BuildContext context, FilterBarStyle style, double availableWidth) {
    final searchWidth = context.ui.size.width(AppComponentSize.searchFieldWidth);
    final suffixWidth = widget.searchSuffix == null ? 0.0 :
        context.ui.size.width(AppComponentSize.hitArea) + style.gap;
    final searchGroupWidth = math.min(
      searchWidth,
      math.max(_minimumSearchWidth, availableWidth - suffixWidth),
    ).toDouble();
    final count = widget.resultCount;
    return Wrap(
      spacing: style.gap,
      runSpacing: style.gap,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        ?widget.leading,
        SizedBox(
          width: searchGroupWidth,
          child: Row(
            children: [
              Expanded(child: _searchField()),
              if (widget.searchSuffix != null) ...[
                context.ui.spacing.gap(AppSpacing.xs, axis: Axis.horizontal),
                widget.searchSuffix!,
              ],
            ],
          ),
        ),
        if (_hasSort) _sortButton(compact: false),
        if (_hasFilterEditor) _filtersButton(compact: false),
        if (count != null)
          AppText.raw(
            CatalogUiKeys.resultsCount.tr(
              context: context,
              namedArgs: {'count': count.toString()},
            ),
            type: AppTextType.bodySmall,
            color: style.colors.onSurfaceVariant,
          ),
        ?widget.trailing,
      ],
    );
  }

  Widget _controlsRow(BuildContext context, FilterBarStyle style) {
    final controlWidth = context.ui.size.width(
      AppComponentSize.filterControlWidth,
    );
    return Wrap(
      spacing: style.gap,
      runSpacing: style.gap,
      children: [
        for (final control in widget.filterControls)
          SizedBox(width: controlWidth, child: control),
      ],
    );
  }

  Widget _activeFilters(BuildContext context, FilterBarStyle style) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      Row(
        children: [
          Expanded(
            child: AppText(
              CatalogUiKeys.activeFilters,
              type: AppTextType.labelMedium,
            ),
          ),
          AppButton(
            CatalogUiKeys.clearAll,
            variant: AppButtonVariant.text,
            size: AppButtonSize.small,
            onPressed: _clearAll,
          ),
        ],
      ),
      Wrap(
        spacing: style.gap,
        runSpacing: style.gap,
        children: [
          for (final filter in widget.activeFilters)
            AppBadge(
              label: CatalogUiKeys.activeFilterLabel,
              labelArgs: {
                'label': filter.label.tr(context: context),
                'value': filter.value,
              },
              size: AppBadgeSize.small,
              onRemove: () => _removeFilter(filter),
              removeLabel: CatalogUiKeys.removeFilter,
            ),
        ],
      ),
    ],
  );
}

/// Phone sort sheet: pick a field, then the direction. Reports and closes.
class _SortSheet extends StatefulWidget {
  const _SortSheet({
    required this.options,
    required this.sortKey,
    required this.ascending,
    required this.onSort,
  });

  final List<FilterBarSortOption> options;
  final String? sortKey;
  final bool ascending;
  final void Function(String key, bool ascending) onSort;

  @override
  State<_SortSheet> createState() => _SortSheetState();
}

class _SortSheetState extends State<_SortSheet> {
  late String? _key = widget.sortKey ?? widget.options.first.key;
  late bool _ascending = widget.ascending;

  @override
  Widget build(BuildContext context) => Padding(
    padding: context.ui.padding.all(AppSpacing.md),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppText(CatalogUiKeys.sortBy, type: AppTextType.titleMedium),
        context.ui.spacing.gap(AppSpacing.sm),
        for (final option in widget.options)
          AppButton(
            option.label,
            variant: option.key == _key
                ? AppButtonVariant.primary
                : AppButtonVariant.text,
            onPressed: () => setState(() => _key = option.key),
          ),
        context.ui.spacing.gap(AppSpacing.sm),
        Row(
          children: [
            Expanded(
              child: AppButton(
                CatalogUiKeys.sortAscendingLabel,
                icon: AppIcons.sortAscending,
                variant: _ascending
                    ? AppButtonVariant.primary
                    : AppButtonVariant.outlined,
                onPressed: () => setState(() => _ascending = true),
              ),
            ),
            context.ui.spacing.gap(AppSpacing.sm),
            Expanded(
              child: AppButton(
                CatalogUiKeys.sortDescendingLabel,
                icon: AppIcons.sortDescending,
                variant: !_ascending
                    ? AppButtonVariant.primary
                    : AppButtonVariant.outlined,
                onPressed: () => setState(() => _ascending = false),
              ),
            ),
          ],
        ),
        context.ui.spacing.gap(AppSpacing.md),
        AppButton(
          CatalogUiKeys.done,
          onPressed: _key == null
              ? null
              : () => widget.onSort(_key!, _ascending),
        ),
      ],
    ),
  );
}
