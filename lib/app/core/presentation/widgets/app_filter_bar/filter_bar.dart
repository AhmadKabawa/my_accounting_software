import 'dart:async';

import 'package:flutter/material.dart';
import 'package:accounting_software/app/core/localization/keys/catalog_ui_keys.dart';
import 'package:accounting_software/app/core/localization/translations/app_key.dart';
import 'package:accounting_software/app/core/presentation/design_system/responsive/engine/screen_engine.dart';
import 'package:accounting_software/app/core/presentation/design_system/responsive/extension/ui_extension.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_badge/app_badge.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_button/app_button.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_button/app_icon_button.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_filter_bar/filter_bar_style.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_text_field/app_text_field.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_text/app_text.dart';

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

/// Search + inline filter controls + active filter summary.
///
/// * The search field has a maximum width on tablet/desktop and a clear (x)
///   button while it holds text; clearing searches immediately.
/// * Give the chip that represents the search text the id
///   [searchFilterId]: removing it (or "clear all") also empties the field,
///   so the visible text can never disagree with the applied search.
/// * On phones the filter controls move into a bottom sheet.
class FilterBar extends StatefulWidget {
  static const defaultSearchDebounce = Duration(milliseconds: 300);

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
  final Duration debounce;

  @override
  State<FilterBar> createState() => _FilterBarState();
}

class _FilterBarState extends State<FilterBar> {
  late final TextEditingController _ownedController;
  bool _showEditor = false;
  Timer? _debounce;

  TextEditingController get _controller =>
      widget.searchController ?? _ownedController;

  @override
  void initState() {
    super.initState();
    _ownedController = TextEditingController();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _ownedController.dispose();
    super.dispose();
  }

  void _search(String value) {
    _debounce?.cancel();
    _debounce = Timer(widget.debounce, () => widget.onSearchChanged(value));
  }

  /// Enter / the keyboard's search key: search now, without the debounce.
  void _submitSearch() {
    _debounce?.cancel();
    widget.onSearchChanged(_controller.text);
  }

  /// The x button: empty the field and search immediately.
  void _clearSearch() {
    _debounce?.cancel();
    _controller.clear();
    widget.onSearchChanged('');
  }

  void _clearAll() {
    _debounce?.cancel();
    _controller.clear();
    widget.onClearAll();
  }

  void _removeFilter(FilterBarFilter filter) {
    if (filter.id == FilterBar.searchFilterId) {
      _debounce?.cancel();
      _controller.clear();
    }
    filter.onRemove();
  }

  bool get _hasFilterEditor =>
      widget.filterPanelBuilder != null || widget.filterControls.isNotEmpty;

  Future<void> _openFilters() async {
    final builder = widget.filterPanelBuilder;
    if (!_hasFilterEditor) return;

    if (!ScreenEngine.isMobile(context)) {
      setState(() => _showEditor = !_showEditor);
      return;
    }

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (sheetContext) => SingleChildScrollView(
        child: Padding(
          padding: sheetContext.ui.padding.all(AppSpacing.md),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AppText(CatalogUiKeys.filters, type: AppTextType.titleMedium),
              sheetContext.ui.spacing.gap(AppSpacing.md),
              if (builder != null)
                builder(sheetContext, () {
                  widget.onApply?.call();
                  Navigator.of(sheetContext).pop();
                })
              else
                Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    for (final control in widget.filterControls) ...[
                      control,
                      sheetContext.ui.spacing.gap(AppSpacing.sm),
                    ],
                  ],
                ),
              sheetContext.ui.spacing.gap(AppSpacing.md),
              AppButton(
                CatalogUiKeys.apply,
                onPressed: () {
                  widget.onApply?.call();
                  Navigator.of(sheetContext).pop();
                },
              ),
            ],
          ),
        ),
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
      onChanged: _search,
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

  @override
  Widget build(BuildContext context) {
    final style = FilterBarStyle(context);
    final mobile = ScreenEngine.isMobile(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (mobile) _mobileToolbar(context) else _wideToolbar(context, style),
        if (!mobile && _showEditor && widget.filterPanelBuilder != null) ...[
          context.ui.spacing.gap(AppSpacing.sm),
          widget.filterPanelBuilder!(context, () {
            widget.onApply?.call();
            setState(() => _showEditor = false);
          }),
          AppButton(
            CatalogUiKeys.apply,
            onPressed: () {
              widget.onApply?.call();
              setState(() => _showEditor = false);
            },
          ),
        ],
        if (widget.activeFilters.isNotEmpty) ...[
          context.ui.spacing.gap(AppSpacing.sm),
          _activeFilters(context, style),
        ],
      ],
    );
  }

  Widget _mobileToolbar(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      _searchField(),
      if (_hasFilterEditor) ...[
        context.ui.spacing.gap(AppSpacing.sm),
        AppButton(
          CatalogUiKeys.filters,
          variant: AppButtonVariant.outlined,
          onPressed: _openFilters,
        ),
      ],
    ],
  );

  /// One wrapping row: search (capped width), the filter controls inline, then
  /// the optional filter-panel button.
  Widget _wideToolbar(BuildContext context, FilterBarStyle style) {
    final searchWidth = context.ui.size.width(
      AppComponentSize.searchFieldWidth,
    );
    final controlWidth = context.ui.size.width(
      AppComponentSize.filterControlWidth,
    );
    return Wrap(
      spacing: style.gap,
      runSpacing: style.gap,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        ConstrainedBox(
          constraints: BoxConstraints(maxWidth: searchWidth),
          child: _searchField(),
        ),
        for (final control in widget.filterControls)
          SizedBox(width: controlWidth, child: control),
        if (widget.filterPanelBuilder != null)
          AppButton(
            CatalogUiKeys.filters,
            variant: AppButtonVariant.outlined,
            onPressed: _openFilters,
          ),
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
