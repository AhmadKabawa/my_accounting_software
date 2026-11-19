import 'dart:async';

import 'package:flutter/material.dart';
import 'package:accounting_software/app/core/localization/keys/catalog_ui_keys.dart';
import 'package:accounting_software/app/core/localization/translations/app_key.dart';
import 'package:accounting_software/app/core/presentation/design_system/responsive/engine/screen_engine.dart';
import 'package:accounting_software/app/core/presentation/design_system/responsive/extension/ui_extension.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_badge/app_badge.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_button/app_button.dart';
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

/// Search + active filter summary + a caller-owned filter editor.
class FilterBar extends StatefulWidget {
  static const defaultSearchDebounce = Duration(milliseconds: 300);

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

  Future<void> _openFilters() async {
    final builder = widget.filterPanelBuilder;
    if (builder == null && widget.filterControls.isEmpty) return;

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
              if (builder != null)
                builder(sheetContext, () {
                  widget.onApply?.call();
                  Navigator.of(sheetContext).pop();
                })
              else
                Wrap(
                  spacing: sheetContext.ui.spacing.sm,
                  runSpacing: sheetContext.ui.spacing.sm,
                  children: widget.filterControls,
                ),
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

  @override
  Widget build(BuildContext context) {
    final style = FilterBarStyle(context);
    final mobile = ScreenEngine.isMobile(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (mobile)
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AppTextField(
                controller: _controller,
                labelKey: CatalogUiKeys.search,
                hintKey: widget.searchHintKey,
                textInputAction: TextInputAction.search,
                onChanged: _search,
                onSubmitted: _submitSearch,
              ),
              context.ui.spacing.gap(AppSpacing.sm),
              AppButton(
                CatalogUiKeys.filters,
                variant: AppButtonVariant.outlined,
                onPressed: widget.filterPanelBuilder == null &&
                        widget.filterControls.isEmpty
                    ? null
                    : _openFilters,
              ),
            ],
          )
        else
          Row(
            children: [
              Expanded(
                child: AppTextField(
                  controller: _controller,
                  labelKey: CatalogUiKeys.search,
                  hintKey: widget.searchHintKey,
                  textInputAction: TextInputAction.search,
                  onChanged: _search,
                  onSubmitted: _submitSearch,
                ),
              ),
              if (widget.filterPanelBuilder != null) ...[
                context.ui.spacing.gap(AppSpacing.sm, axis: Axis.horizontal),
                AppButton(
                  CatalogUiKeys.filters,
                  variant: AppButtonVariant.outlined,
                  onPressed: _openFilters,
                ),
              ],
            ],
          ),
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
        if (!mobile && widget.filterControls.isNotEmpty) ...[
          context.ui.spacing.gap(AppSpacing.sm),
          Wrap(
            spacing: style.gap,
            runSpacing: style.gap,
            children: widget.filterControls,
          ),
        ],
        if (widget.activeFilters.isNotEmpty) ...[
          context.ui.spacing.gap(AppSpacing.sm),
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
                onPressed: widget.onClearAll,
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
                  onRemove: filter.onRemove,
                  removeLabel: CatalogUiKeys.removeFilter,
                ),
            ],
          ),
        ],
      ],
    );
  }
}
