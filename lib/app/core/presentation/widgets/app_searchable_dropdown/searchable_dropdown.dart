import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

/// Select between the legacy editable autocomplete and a trigger-driven panel.
enum SearchableDropdownMode { autocomplete, panel }

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
    this.allOptionLabel,
    this.mode = SearchableDropdownMode.autocomplete,
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

  /// Optional localized label for the null selection. Panel mode defaults to
  /// [CatalogUiKeys.allOptions] when this override is omitted.
  final AppKey? allOptionLabel;

  /// `autocomplete` preserves the original editable/remote-search contract.
  /// `panel` shows the selected value in a trigger and opens a dedicated picker.
  final SearchableDropdownMode mode;

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
  final _panelTriggerKey = GlobalKey();
  final _panelLayerLink = LayerLink();
  OverlayEntry? _desktopPanelEntry;
  Completer<_PickerSelection<T>?>? _desktopPanelCompleter;

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
    if (_desktopFocusNode.hasFocus) {
      // The field shows the selected label, which is not a search query:
      // select it so typing replaces it (see [_effectiveQuery]).
      final text = _desktopController.text;
      if (text.isNotEmpty && text == _selectedLabel) {
        _desktopController.selection = TextSelection(
          baseOffset: 0,
          extentOffset: text.length,
        );
      }
      return;
    }
    _setText(_selectedLabel);
    _resetQuery();
    if (mounted) setState(() {});
  }

  /// The x button. With [SearchableDropdown.clearable] it clears the value;
  /// otherwise (a field that must keep a value) it only drops what the user
  /// typed and shows the selected label again.
  void _clear() {
    if (!widget.clearable) {
      _setText(_selectedLabel);
      _resetQuery();
      setState(() {});
      return;
    }
    _setText('');
    _resetQuery();
    widget.onChanged(null);
    setState(() {});
  }

  bool _showClear(String text) {
    if (text.isEmpty) return false;
    return widget.clearable || text != _selectedLabel;
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
      // Refresh its field value after this build instead of replacing the
      // RawAutocomplete subtree: replacing it closes the overlay while the
      // externally-owned FocusNode remains focused, so the panel never reopens.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        if (_desktopFocusNode.hasFocus) {
          final value = _desktopController.value;
          _desktopController.value = value.copyWith(
            text: '${value.text} ',
            selection: TextSelection.collapsed(offset: value.text.length + 1),
            composing: TextRange.empty,
          );
          _desktopController.value = value;
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

    _desktopPanelEntry?.markNeedsBuild();
  }

  String _lastQuery = '';
  @override
  void dispose() {
    _debounce?.cancel();
    _dismissDesktopPanel();
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

  /// The field text is a search query only when the user typed it. While it
  /// still equals the selected label it is just the shown value, so the full
  /// option list is offered (otherwise re-opening after a choice would list
  /// only the chosen option).

  String _effectiveQuery(String text) =>
      widget.value != null && text == _selectedLabel ? '' : text;

  Iterable<T> _options(String query) {
    if (!widget.filterLocally) return widget.options;
    final normalized = _effectiveQuery(query).trim().toLowerCase();
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

    if (widget.mode == SearchableDropdownMode.panel) {
      return _panelTrigger(context, style);
    }

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
              onTap: () {
                if (widget.value != null && controller.text == _selectedLabel) {
                  controller.clear();
                }
              },
              onSubmitted: onFieldSubmitted,
              suffix: !_showClear(controller.text)
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

  String _panelDisplayLabel(BuildContext context) {
    final value = widget.value;
    if (value != null) return widget.optionLabel(value);
    return (widget.allOptionLabel ?? CatalogUiKeys.allOptions).tr(
      context: context,
    );
  }

  Widget _panelTrigger(BuildContext context, SearchableDropdownStyle style) {
    final label = _panelDisplayLabel(context);
    return _PanelTrigger(
      key: ValueKey(label),
      label: label,
      labelKey: widget.labelKey,
      enabled: widget.enabled,
      readOnly: widget.readOnly,
      style: style,
      triggerKey: _panelTriggerKey,
      link: _panelLayerLink,
      onTap: widget.enabled && !widget.readOnly
          ? () => _openPanelPicker(context)
          : null,
    );
  }

  Future<void> _openPanelPicker(BuildContext context) async {
    final isMobile = ScreenEngine.isMobile(context);
    final selection = isMobile
        ? await showModalBottomSheet<_PickerSelection<T>>(
            context: context,
            isScrollControlled: true,
            useSafeArea: true,
            builder: (sheetContext) => FractionallySizedBox(
              heightFactor: _mobileSheetHeightFactor,
              child: _PanelSearchPicker<T>(
                data: _pickerData,
                labelKey: widget.labelKey,
                optionLabel: widget.optionLabel,
                optionSubtitle: widget.optionSubtitle,
                emptyKey: widget.emptyKey,
                allOptionLabel:
                    widget.allOptionLabel ?? CatalogUiKeys.allOptions,
                selectedValue: widget.value,
                filterLocally: widget.filterLocally,
                onQueryChanged: widget.onQueryChanged == null ? null : _query,
                onAddNew: widget.onAddNew,
                onDismiss: () => Navigator.of(sheetContext).maybePop(),
                onSelect: (value) => Navigator.of(
                  sheetContext,
                ).pop(_PickerSelection<T>(value: value)),
              ),
            ),
          )
        : await _showDesktopPanel(context);

    if (!context.mounted) return;
    if (selection != null) widget.onChanged(selection.value);
    _resetQuery();
    final displayLabel = _panelDisplayLabel(context);
    if (!mounted) return;
    _setText(displayLabel);
    setState(() {});
  }

  Future<_PickerSelection<T>?> _showDesktopPanel(BuildContext context) {
    final renderBox =
        _panelTriggerKey.currentContext?.findRenderObject() as RenderBox?;
    final triggerSize = renderBox?.size ?? Size.zero;
    final triggerTop = renderBox?.localToGlobal(Offset.zero).dy ?? 0;
    final screenHeight = MediaQuery.sizeOf(context).height;
    final gap = context.ui.padding.all(AppSpacing.md).top;
    final below = screenHeight - triggerTop - triggerSize.height - gap;
    final above = triggerTop - gap;
    final style = SearchableDropdownStyle(context);
    final showAbove = below < style.maxPanelHeight && above > below;
    final availableHeight = (showAbove ? above : below)
        .clamp(0.0, style.maxPanelHeight)
        .toDouble();
    final panelWidth = triggerSize.width;
    final direction = Directionality.of(context);
    final targetAnchor =
        (showAbove
                ? AlignmentDirectional.topStart
                : AlignmentDirectional.bottomStart)
            .resolve(direction);
    final followerAnchor =
        (showAbove
                ? AlignmentDirectional.bottomStart
                : AlignmentDirectional.topStart)
            .resolve(direction);
    final completer = Completer<_PickerSelection<T>?>();
    _desktopPanelCompleter = completer;

    final entry = OverlayEntry(
      builder: (overlayContext) => Stack(
        children: [
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: _dismissDesktopPanel,
              child: const SizedBox.expand(),
            ),
          ),
          CompositedTransformFollower(
            link: _panelLayerLink,
            showWhenUnlinked: false,
            targetAnchor: targetAnchor,
            followerAnchor: followerAnchor,
            offset: Offset(0, showAbove ? -gap : gap),
            child: Material(
              elevation: overlayContext.ui.shadow.value(AppElevation.md),
              color: style.colors.surface,
              borderRadius: style.radius,
              clipBehavior: Clip.antiAlias,
              child: SizedBox(
                width: panelWidth,
                height: availableHeight,
                child: _PanelSearchPicker<T>(
                  data: _pickerData,
                  labelKey: widget.labelKey,
                  optionLabel: widget.optionLabel,
                  optionSubtitle: widget.optionSubtitle,
                  emptyKey: widget.emptyKey,
                  allOptionLabel:
                      widget.allOptionLabel ?? CatalogUiKeys.allOptions,
                  selectedValue: widget.value,
                  filterLocally: widget.filterLocally,
                  onQueryChanged: widget.onQueryChanged == null ? null : _query,
                  onAddNew: widget.onAddNew,
                  onDismiss: _dismissDesktopPanel,
                  onSelect: (value) =>
                      _dismissDesktopPanel(_PickerSelection<T>(value: value)),
                ),
              ),
            ),
          ),
        ],
      ),
    );
    _desktopPanelEntry = entry;
    Overlay.of(context).insert(entry);
    return completer.future;
  }

  void _dismissDesktopPanel([_PickerSelection<T>? selection]) {
    final entry = _desktopPanelEntry;
    _desktopPanelEntry = null;
    entry?.remove();
    entry?.dispose();

    final completer = _desktopPanelCompleter;
    _desktopPanelCompleter = null;
    if (completer != null && !completer.isCompleted) {
      completer.complete(selection);
    }
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
        if (widget.allOptionLabel != null)
          _optionTile(
            context,
            widget.allOptionLabel!.tr(context: context),
            () {
              widget.onChanged(null);
              // The nullable selection is terminal just like a normal choice:
              // close RawAutocomplete explicitly instead of waiting for blur.
              _desktopFocusNode.unfocus();
            },
            selected: widget.value == null,
          ),
        for (final option in options)
          _optionTile(
            context,
            widget.optionLabel(option),
            () => select(option),
            selected: widget.value == option,
            subtitle: widget.optionSubtitle?.call(option),
          ),
        if (widget.onAddNew != null) widget.onAddNew!(context),
      ],
    );
  }

  Widget _optionTile(
    BuildContext context,
    String label,
    VoidCallback onTap, {
    bool selected = false,
    String? subtitle,
  }) {
    final style = SearchableDropdownStyle(context);
    return Semantics(
      button: true,
      selected: selected,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: style.optionPadding,
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppText.raw(label, maxLines: 2),
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
              if (selected) ...[
                context.ui.spacing.gap(AppSpacing.sm),
                const AppIcon(AppIcons.check, tone: AppIconTone.primary),
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
                  suffix: _query.isEmpty
                      ? null
                      : AppIconButton(
                          AppIcons.close,
                          tooltipKey: CatalogUiKeys.clearSearch,
                          onPressed: () {
                            _searchController.clear();
                            setState(() => _query = '');
                            widget.onQueryChanged?.call('');
                          },
                        ),
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

class _PickerSelection<T extends Object> {
  const _PickerSelection({required this.value});
  final T? value;
}

class _PanelSearchPicker<T extends Object> extends StatefulWidget {
  const _PanelSearchPicker({
    required this.data,
    required this.labelKey,
    required this.optionLabel,
    required this.emptyKey,
    required this.filterLocally,
    required this.onSelect,
    required this.onDismiss,
    required this.selectedValue,
    this.optionSubtitle,
    required this.allOptionLabel,
    this.onQueryChanged,
    this.onAddNew,
  });

  final ValueListenable<_PickerData<T>> data;
  final AppKey labelKey;
  final String Function(T) optionLabel;
  final String? Function(T)? optionSubtitle;
  final AppKey emptyKey;
  final AppKey allOptionLabel;
  final T? selectedValue;
  final bool filterLocally;
  final ValueChanged<String>? onQueryChanged;
  final WidgetBuilder? onAddNew;
  final ValueChanged<T?> onSelect;
  final VoidCallback onDismiss;

  @override
  State<_PanelSearchPicker<T>> createState() => _PanelSearchPickerState<T>();
}

class _PanelSearchPickerState<T extends Object>
    extends State<_PanelSearchPicker<T>> {
  final _controller = TextEditingController();
  final _searchFocus = FocusNode();
  String _query = '';
  int _activeIndex = 0;
  bool _selectionMade = false;

  @override
  void dispose() {
    _controller.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  void _selectActive(List<T> options) {
    if (_selectionMade) return;
    const allCount = 1;
    if (_activeIndex == 0) {
      _selectionMade = true;
      widget.onSelect(null);
      return;
    }
    final index = _activeIndex - allCount;
    if (index >= 0 && index < options.length) {
      _selectionMade = true;
      widget.onSelect(options[index]);
    }
  }

  KeyEventResult _handleKey(FocusNode _, KeyEvent event, List<T> options) {
    if (event is! KeyDownEvent) return KeyEventResult.ignored;
    final count = options.length + 1;
    if (event.logicalKey == LogicalKeyboardKey.escape) {
      widget.onDismiss();
      return KeyEventResult.handled;
    }
    if (event.logicalKey == LogicalKeyboardKey.arrowDown && count > 0) {
      setState(() => _activeIndex = (_activeIndex + 1) % count);
      return KeyEventResult.handled;
    }
    if (event.logicalKey == LogicalKeyboardKey.arrowUp && count > 0) {
      setState(() => _activeIndex = (_activeIndex - 1 + count) % count);
      return KeyEventResult.handled;
    }
    if (event.logicalKey == LogicalKeyboardKey.enter && count > 0) {
      _selectActive(options);
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<_PickerData<T>>(
      valueListenable: widget.data,
      builder: (context, data, _) {
        final normalized = _query.trim().toLowerCase();
        final options = widget.filterLocally && normalized.isNotEmpty
            ? data.options
                  .where((option) {
                    return widget
                            .optionLabel(option)
                            .toLowerCase()
                            .contains(normalized) ||
                        (widget.optionSubtitle
                                ?.call(option)
                                ?.toLowerCase()
                                .contains(normalized) ??
                            false);
                  })
                  .toList(growable: false)
            : data.options;
        const allCount = 1;
        final count = options.length + allCount;
        if (_activeIndex >= count && count > 0) _activeIndex = count - 1;

        return Focus(
          key: const ValueKey('searchable-dropdown-panel'),
          onKeyEvent: (node, event) => _handleKey(node, event, options),
          child: SafeArea(
            child: Padding(
              padding: context.ui.padding.all(AppSpacing.sm),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  AppTextField(
                    labelKey: widget.labelKey,
                    controller: _controller,
                    focusNode: _searchFocus,
                    hintKey: CatalogUiKeys.search,
                    prefixIcon: AppIcons.search,
                    autofocus: true,
                    textInputAction: TextInputAction.search,
                    onSubmitted: () => _selectActive(options),
                    onChanged: (value) {
                      setState(() {
                        _query = value;
                        _activeIndex = 0;
                        _selectionMade = false;
                      });
                      widget.onQueryChanged?.call(value);
                    },
                    suffix: _query.isEmpty
                        ? null
                        : AppIconButton(
                            AppIcons.close,
                            tooltipKey: CatalogUiKeys.clearSearch,
                            onPressed: () {
                              _controller.clear();
                              setState(() {
                                _query = '';
                                _activeIndex = 0;
                                _selectionMade = false;
                              });
                              widget.onQueryChanged?.call('');
                            },
                          ),
                  ),
                  context.ui.spacing.gap(AppSpacing.sm),
                  Expanded(
                    child: data.errorKey != null
                        ? InlineBanner(
                            messageKey: data.errorKey!,
                            variant: InlineBannerVariant.error,
                          )
                        : data.loading
                        ? const AppSkeleton.block()
                        : ListView(
                            padding: EdgeInsets.zero,
                            children: [
                              _tile(
                                context,
                                widget.allOptionLabel.tr(context: context),
                                selected: widget.selectedValue == null,
                                active: _activeIndex == 0,
                                onTap: () => widget.onSelect(null),
                              ),
                              if (options.isEmpty && _query.trim().isNotEmpty)
                                Padding(
                                  padding: context.ui.padding.all(
                                    AppSpacing.md,
                                  ),
                                  child: AppText(widget.emptyKey),
                                ),
                              for (
                                var index = 0;
                                index < options.length;
                                index++
                              )
                                _tile(
                                  context,
                                  widget.optionLabel(options[index]),
                                  subtitle: widget.optionSubtitle?.call(
                                    options[index],
                                  ),
                                  selected:
                                      widget.selectedValue == options[index],
                                  active: _activeIndex == index + allCount,
                                  onTap: () => widget.onSelect(options[index]),
                                ),
                              if (widget.onAddNew != null)
                                widget.onAddNew!(context),
                            ],
                          ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _tile(
    BuildContext context,
    String label, {
    String? subtitle,
    required bool selected,
    required bool active,
    required VoidCallback onTap,
  }) {
    return Semantics(
      button: true,
      selected: selected,
      child: InkWell(
        onTap: onTap,
        child: Container(
          color: active
              ? context.ui.theme.colors.surfaceContainerHighest
              : null,
          padding: context.ui.padding.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppText.raw(label, maxLines: 2),
                    if (subtitle != null && subtitle.isNotEmpty)
                      AppText.raw(
                        subtitle,
                        type: AppTextType.bodySmall,
                        color: context.ui.theme.colors.onSurfaceVariant,
                        maxLines: 2,
                      ),
                  ],
                ),
              ),
              if (selected)
                const AppIcon(AppIcons.check, tone: AppIconTone.primary),
            ],
          ),
        ),
      ),
    );
  }
}

/// Owns the read-only panel trigger controller. The parent keys this widget by
/// the label derived during build, so a changed selection rebuilds the field
/// without lifecycle callbacks or post-frame controller mutations.
class _PanelTrigger extends StatefulWidget {
  const _PanelTrigger({
    super.key,
    required this.label,
    required this.labelKey,
    required this.enabled,
    required this.readOnly,
    required this.style,
    required this.triggerKey,
    required this.link,
    required this.onTap,
  });

  final String label;
  final AppKey labelKey;
  final bool enabled;
  final bool readOnly;
  final SearchableDropdownStyle style;
  final GlobalKey triggerKey;
  final LayerLink link;
  final VoidCallback? onTap;

  @override
  State<_PanelTrigger> createState() => _PanelTriggerState();
}

class _PanelTriggerState extends State<_PanelTrigger> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.label);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    enabled: widget.enabled && !widget.readOnly,
    label: widget.labelKey.tr(context: context),
    value: widget.label,
    excludeSemantics: true,
    onTap: widget.onTap,
    child: CompositedTransformTarget(
      key: widget.triggerKey,
      link: widget.link,
      child: InkWell(
        onTap: widget.onTap,
        borderRadius: widget.style.radius,
        child: ExcludeFocus(
          child: IgnorePointer(
            child: AppTextField(
              controller: _controller,
              labelKey: widget.labelKey,
              readOnly: true,
              enabled: widget.enabled,
              suffix: const AppIcon(AppIcons.expand),
            ),
          ),
        ),
      ),
    ),
  );
}
