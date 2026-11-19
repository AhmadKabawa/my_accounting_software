import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:accounting_software/app/core/localization/keys/catalog_ui_keys.dart';
import 'package:accounting_software/app/core/localization/translations/app_key.dart';
import 'package:accounting_software/app/core/presentation/design_system/responsive/engine/screen_engine.dart';
import 'package:accounting_software/app/core/presentation/design_system/responsive/extension/ui_extension.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_button/app_icon_button.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_icon/app_icon.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_inline_banner/inline_banner.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_searchable_dropdown/searchable_dropdown_style.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_skeleton/app_skeleton.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_text/app_text.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_text_field/app_text_field.dart';

export 'searchable_dropdown_style.dart';

/// A generic, single-selection searchable picker. Data loading and querying
/// remain owned by the caller; pass remote results and [onQueryChanged].
class SearchableDropdown<T extends Object> extends StatefulWidget {
  const SearchableDropdown({
    super.key,
    required this.options,
    required this.labelKey,
    required this.optionLabel,
    required this.value,
    required this.onChanged,
    this.optionSubtitle,
    this.onQueryChanged,
    this.filterLocally = true,
    this.loading = false,
    this.errorKey,
    this.emptyKey = CatalogUiKeys.noOptions,
    this.enabled = true,
    this.readOnly = false,
    this.clearable = true,
    this.onAddNew,
  });

  final List<T> options;
  final AppKey labelKey;
  final String Function(T option) optionLabel;
  final String? Function(T option)? optionSubtitle;
  final T? value;
  final ValueChanged<T?> onChanged;
  final ValueChanged<String>? onQueryChanged;
  final bool filterLocally;
  final bool loading;
  final AppKey? errorKey;
  final AppKey emptyKey;
  final bool enabled;
  final bool readOnly;

  /// Shows a clear button that calls [onChanged] with null. Set false for a
  /// field that must always hold a value.
  final bool clearable;
  final WidgetBuilder? onAddNew;

  @override
  State<SearchableDropdown<T>> createState() => _SearchableDropdownState<T>();
}

class _SearchableDropdownState<T extends Object>
    extends State<SearchableDropdown<T>> {
  static const _mobileSheetHeightFactor = 0.9;
  static const _queryDebounce = Duration(milliseconds: 300);
  Timer? _debounce;
  late final ValueNotifier<_PickerData<T>> _pickerData;
  late final TextEditingController _desktopController;
  late final FocusNode _desktopFocusNode;

  @override
  void initState() {
    super.initState();
    _pickerData = ValueNotifier(
      _PickerData<T>(
        options: widget.options,
        loading: widget.loading,
        errorKey: widget.errorKey,
      ),
    );
    _desktopController = TextEditingController(text: _selectedLabel);
    _desktopFocusNode = FocusNode()..addListener(_onDesktopFocusChanged);
  }

  String get _selectedLabel {
    final value = widget.value;
    return value == null ? '' : widget.optionLabel(value);
  }

  void _setText(String text) {
    if (_desktopController.text == text) return;
    _desktopController.value = TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }

  /// The text the user typed is only a search query. When the field loses
  /// focus it must show the selected value again, so the visible text and
  /// [SearchableDropdown.value] can never disagree.
  void _onDesktopFocusChanged() {
    if (_desktopFocusNode.hasFocus) return;
    _setText(_selectedLabel);
    _resetQuery();
    if (mounted) setState(() {});
  }

  void _clear() {
    _setText('');
    _resetQuery();
    widget.onChanged(null);
    setState(() {});
  }

  /// Drops the pending search so remote results are not left filtered by a
  /// query the user can no longer see.
  void _resetQuery() {
    _debounce?.cancel();
    if (_lastQuery.isEmpty) return;
    _lastQuery = '';
    widget.onQueryChanged?.call('');
  }

  @override
  void didUpdateWidget(covariant SearchableDropdown<T> oldWidget) {
    super.didUpdateWidget(oldWidget);

    final optionsChanged = !identical(oldWidget.options, widget.options);
    final stateChanged =
        oldWidget.loading != widget.loading ||
        oldWidget.errorKey != widget.errorKey;
    if (optionsChanged || stateChanged) {
      // RawAutocomplete recalculates its options when its controller notifies.
      // Nudge the selection after this build instead of replacing the
      // RawAutocomplete subtree: replacing it closes the overlay while the
      // externally-owned FocusNode remains focused, so the panel never reopens.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        if (_desktopFocusNode.hasFocus) {
          final selection = _desktopController.selection;
          _desktopController.selection = const TextSelection.collapsed(
            offset: 0,
          );
          _desktopController.selection = selection;
        }
        // A modal sheet may still be listening to this notifier. Notify it
        // after the current widget build, never from didUpdateWidget itself.
        _pickerData.value = _PickerData<T>(
          options: widget.options,
          loading: widget.loading,
          errorKey: widget.errorKey,
        );
      });
    }

    if (oldWidget.value != widget.value && !_desktopFocusNode.hasFocus) {
      _setText(_selectedLabel);
    }
  }

  String _lastQuery = '';
  @override
  void dispose() {
    _debounce?.cancel();
    _pickerData.dispose();
    _desktopController.dispose();
    _desktopFocusNode
      ..removeListener(_onDesktopFocusChanged)
      ..dispose();
    super.dispose();
  }

  void _query(String value) {
    _lastQuery = value;
    setState(() {});
    _debounce?.cancel();
    final callback = widget.onQueryChanged;
    if (callback == null) return;
    _debounce = Timer(_queryDebounce, () => callback(value));
  }

  Iterable<T> _options(String query) {
    if (!widget.filterLocally) return widget.options;
    final normalized = query.trim().toLowerCase();
    if (normalized.isEmpty) return widget.options;
    return widget.options.where(
      (option) =>
          widget.optionLabel(option).toLowerCase().contains(normalized) ||
          (widget.optionSubtitle
                  ?.call(option)
                  ?.toLowerCase()
                  .contains(normalized) ??
              false),
    );
  }

  @override
  Widget build(BuildContext context) {
    final style = SearchableDropdownStyle(context);
    final isMobile = ScreenEngine.isMobile(context);

    // Disabled looks unavailable; read-only keeps the normal look but cannot
    // be edited, so the two states stay visually distinct.
    if (!widget.enabled || widget.readOnly) {
      return AppTextField(
        controller: _desktopController,
        labelKey: widget.labelKey,
        enabled: widget.enabled,
        readOnly: widget.readOnly,
      );
    }

    if (isMobile) {
      // The field is only a trigger for the bottom sheet, so it is announced
      // as one button (label + current value) instead of a text input.
      return Semantics(
        button: true,
        enabled: true,
        label: widget.labelKey.tr(context: context),
        value: _selectedLabel,
        excludeSemantics: true,
        onTap: () => _openMobilePicker(context),
        child: InkWell(
          onTap: () => _openMobilePicker(context),
          borderRadius: style.radius,
          child: ExcludeFocus(
            child: IgnorePointer(
              child: AppTextField(
                controller: _desktopController,
                labelKey: widget.labelKey,
                readOnly: true,
                suffix: const AppIcon(AppIcons.expand),
              ),
            ),
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        RawAutocomplete<T>(
          textEditingController: _desktopController,
          focusNode: _desktopFocusNode,
          displayStringForOption: widget.optionLabel,
          optionsBuilder: (value) {
            if (widget.loading || widget.errorKey != null) {
              return Iterable<T>.empty();
            }
            return _options(value.text);
          },
          onSelected: widget.onChanged,
          fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
            return AppTextField(
              controller: controller,
              focusNode: focusNode,
              labelKey: widget.labelKey,
              hintKey: CatalogUiKeys.search,
              textInputAction: TextInputAction.search,
              onChanged: _query,
              onSubmitted: onFieldSubmitted,
              suffix:
                  !widget.clearable ||
                      (widget.value == null && controller.text.isEmpty)
                  ? null
                  : AppIconButton(
                      AppIcons.close,
                      tooltipKey: CatalogUiKeys.clearSelection,
                      onPressed: _clear,
                    ),
            );
          },
          optionsViewBuilder: (context, onSelected, options) => _optionsPanel(
            context,
            options.toList(growable: false),
            onSelected,
          ),
        ),
        if (widget.errorKey != null)
          InlineBanner(
            messageKey: widget.errorKey!,
            variant: InlineBannerVariant.error,
          ),
        if (widget.loading) const AppSkeleton.block(),
        // RawAutocomplete never opens its panel for an empty option list, so
        // loading, error and "no results" are shown here, under the field.
        // The "add new" action lives here too, otherwise it would be
        // unreachable exactly when the user needs it (nothing matched).
        // TextFieldTapRegion: a tap here must not count as "outside" the
        // field, or the field would lose focus (and reset this block) before
        // the tap completes.
        if (!widget.loading &&
            widget.errorKey == null &&
            _lastQuery.isNotEmpty &&
            _options(_lastQuery).isEmpty)
          TextFieldTapRegion(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: context.ui.padding.all(AppSpacing.sm),
                  child: AppText(widget.emptyKey),
                ),
                if (widget.onAddNew != null) widget.onAddNew!(context),
              ],
            ),
          ),
      ],
    );
  }

  Widget _optionsPanel(
    BuildContext context,
    List<T> options,
    AutocompleteOnSelected<T> onSelected,
  ) {
    final style = SearchableDropdownStyle(context);
    return TextFieldTapRegion(
      child: Align(
        alignment: AlignmentDirectional.topStart,
        child: Material(
          elevation: context.ui.shadow.value(AppElevation.md),
          color: style.colors.surface,
          borderRadius: style.radius,
          clipBehavior: Clip.antiAlias,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: style.maxOptionsHeight,
              minWidth: context.ui.size.width(AppComponentSize.cardWidth),
            ),
            child: _optionsContent(
              context,
              options,
              (option) => onSelected(option),
            ),
          ),
        ),
      ),
    );
  }

  /// Only reached with a non-empty list (see [build]: loading, error and
  /// empty results are rendered under the field, not in the panel).
  Widget _optionsContent(
    BuildContext context,
    List<T> options,
    ValueChanged<T> select,
  ) {
    return ListView(
      padding: EdgeInsets.zero,
      shrinkWrap: true,
      children: [
        for (final option in options)
          _optionTile(context, option, () => select(option)),
        if (widget.onAddNew != null) widget.onAddNew!(context),
      ],
    );
  }

  Widget _optionTile(BuildContext context, T option, VoidCallback onTap) {
    final style = SearchableDropdownStyle(context);
    final subtitle = widget.optionSubtitle?.call(option);
    return Semantics(
      button: true,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: style.optionPadding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppText.raw(widget.optionLabel(option), maxLines: 2),
              if (subtitle != null && subtitle.isNotEmpty) ...[
                context.ui.spacing.gap(AppSpacing.xs),
                AppText.raw(
                  subtitle,
                  type: AppTextType.bodySmall,
                  color: style.colors.onSurfaceVariant,
                  maxLines: 2,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _openMobilePicker(BuildContext context) async {
    final result = await showModalBottomSheet<T>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (sheetContext) => FractionallySizedBox(
        heightFactor: _mobileSheetHeightFactor,
        child: _MobileSearchPicker<T>(
          data: _pickerData,
          labelKey: widget.labelKey,
          optionLabel: widget.optionLabel,
          optionSubtitle: widget.optionSubtitle,
          emptyKey: widget.emptyKey,
          filterLocally: widget.filterLocally,
          onQueryChanged: widget.onQueryChanged == null ? null : _query,
          onAddNew: widget.onAddNew,
          onSelect: (option) => Navigator.of(sheetContext).pop(option),
        ),
      ),
    );
    if (!mounted) return;
    if (result != null) widget.onChanged(result);
    // The sheet's search box starts empty on every open, so do not leave the
    // remote results filtered by the previous query.
    _resetQuery();
  }
}

class _PickerData<T extends Object> {
  const _PickerData({
    required this.options,
    required this.loading,
    required this.errorKey,
  });
  final List<T> options;
  final bool loading;
  final AppKey? errorKey;
}

class _MobileSearchPicker<T extends Object> extends StatefulWidget {
  const _MobileSearchPicker({
    required this.data,
    required this.labelKey,
    required this.optionLabel,
    required this.emptyKey,
    required this.filterLocally,
    required this.onSelect,
    this.optionSubtitle,
    this.onQueryChanged,
    this.onAddNew,
  });
  final ValueListenable<_PickerData<T>> data;
  final AppKey labelKey;
  final String Function(T) optionLabel;
  final String? Function(T)? optionSubtitle;
  final AppKey emptyKey;
  final bool filterLocally;
  final ValueChanged<String>? onQueryChanged;
  final WidgetBuilder? onAddNew;
  final ValueChanged<T> onSelect;

  @override
  State<_MobileSearchPicker<T>> createState() => _MobileSearchPickerState<T>();
}

class _MobileSearchPickerState<T extends Object>
    extends State<_MobileSearchPicker<T>> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<_PickerData<T>>(
      valueListenable: widget.data,
      builder: (context, data, _) {
        final options = widget.filterLocally && _query.trim().isNotEmpty
            ? data.options.where(
                (option) =>
                    widget
                        .optionLabel(option)
                        .toLowerCase()
                        .contains(_query.trim().toLowerCase()) ||
                    (widget.optionSubtitle
                            ?.call(option)
                            ?.toLowerCase()
                            .contains(_query.trim().toLowerCase()) ??
                        false),
              )
            : data.options;
        return SafeArea(
          child: Padding(
            padding: context.ui.padding.all(AppSpacing.md),
            child: Column(
              children: [
                AppTextField(
                  controller: _searchController,
                  labelKey: widget.labelKey,
                  prefixIcon: AppIcons.search,
                  autofocus: true,
                  textInputAction: TextInputAction.search,
                  onChanged: (value) {
                    setState(() => _query = value);
                    widget.onQueryChanged?.call(value);
                  },
                ),
                context.ui.spacing.gap(AppSpacing.md),
                Expanded(
                  child: data.errorKey != null
                      ? InlineBanner(
                          messageKey: data.errorKey!,
                          variant: InlineBannerVariant.error,
                        )
                      : data.loading
                      ? const AppSkeleton.block()
                      : options.isEmpty
                      ? Center(child: AppText(widget.emptyKey))
                      : ListView(
                          children: [
                            for (final option in options)
                              Semantics(
                                button: true,
                                child: InkWell(
                                  onTap: () => widget.onSelect(option),
                                  child: Padding(
                                    padding: context.ui.padding.symmetric(
                                      vertical: AppSpacing.sm,
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        AppText.raw(
                                          widget.optionLabel(option),
                                          maxLines: 2,
                                        ),
                                        if (widget.optionSubtitle?.call(
                                              option,
                                            ) !=
                                            null)
                                          AppText.raw(
                                            widget.optionSubtitle!(option)!,
                                            type: AppTextType.bodySmall,
                                            color: context
                                                .ui
                                                .theme
                                                .colors
                                                .onSurfaceVariant,
                                            maxLines: 2,
                                          ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            if (widget.onAddNew != null)
                              widget.onAddNew!(context),
                          ],
                        ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
