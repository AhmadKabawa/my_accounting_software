import 'dart:async';

import 'package:flutter/material.dart';
import 'package:accounting_software/app/core/localization/keys/catalog_ui_keys.dart';
import 'package:accounting_software/app/core/localization/translations/app_key.dart';
import 'package:accounting_software/app/core/presentation/design_system/responsive/engine/screen_engine.dart';
import 'package:accounting_software/app/core/presentation/design_system/responsive/extension/ui_extension.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_button/app_button.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_inline_banner/inline_banner.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_searchable_dropdown/searchable_dropdown_style.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_text/app_text.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_text_field/app_text_field_style.dart';

export 'searchable_dropdown_style.dart';

/// A generic, single-selection searchable picker. Data loading and querying
/// remain owned by the caller; pass remote results and [onQueryChanged].
class SearchableDropdown<T extends Object> extends StatefulWidget {
  const SearchableDropdown({
    super.key,
    required this.data,
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
    this.onAddNew,
    this.addNewLabelKey,
  });

  final ValueListenable<_PickerData<T>> data;
  final AppKey labelKey;
  final String Function(T option) optionLabel;
  final String? Function(T option)? optionSubtitle;
  final T? value;
  final ValueChanged<T?> onChanged;
  final ValueChanged<String>? onQueryChanged;
  final bool filterLocally;
  final AppKey emptyKey;
  final bool enabled;
  final bool readOnly;
  final WidgetBuilder? onAddNew;
  final AppKey? addNewLabelKey;

  @override
  State<SearchableDropdown<T>> createState() => _SearchableDropdownState<T>();
}

class _SearchableDropdownState<T extends Object>
    extends State<SearchableDropdown<T>> {
  Timer? _debounce;
  late final ValueNotifier<_PickerData<T>> _pickerData;
  late final TextEditingController _desktopController;
  late final FocusNode _desktopFocusNode;

  @override
  void initState() {
    super.initState();
    _pickerData = ValueNotifier(_PickerData<T>(
      options: widget.options,
      loading: widget.loading,
      errorKey: widget.errorKey,
    ));
    _desktopController = TextEditingController();
    _desktopFocusNode = FocusNode();
  }

  @override
  void didUpdateWidget(covariant SearchableDropdown<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!identical(oldWidget.options, widget.options) ||
        oldWidget.loading != widget.loading ||
        oldWidget.errorKey != widget.errorKey) {
      _pickerData.value = _PickerData<T>(
        options: widget.options,
        loading: widget.loading,
        errorKey: widget.errorKey,
      );
    }
  }
  String _lastQuery = '';

  @override
  void dispose() {
    _debounce?.cancel();
    _pickerData.dispose();
    _desktopController.dispose();
    _desktopFocusNode.dispose();
    super.dispose();
  }

  void _query(String value) {
    _lastQuery = value;
    setState(() {});
    _debounce?.cancel();
    final callback = widget.onQueryChanged;
    if (callback == null) return;
    _debounce = Timer(const Duration(milliseconds: 300), () => callback(value));
  }

  Iterable<T> _options(String query) {
    if (!widget.filterLocally) return widget.options;
    final normalized = query.trim().toLowerCase();
    if (normalized.isEmpty) return widget.options;
    return widget.options.where(
      (option) => widget.optionLabel(option).toLowerCase().contains(normalized) ||
          (widget.optionSubtitle?.call(option)?.toLowerCase().contains(normalized) ?? false),
    );
  }

  @override
  Widget build(BuildContext context) {
    final style = SearchableDropdownStyle(context);
    final selected = widget.value;
    final label = selected == null ? '' : widget.optionLabel(selected);
    final isMobile = ScreenEngine.isMobile(context);

    if (!widget.enabled || widget.readOnly) {
      return InputDecorator(
        decoration: InputDecoration(
          labelText: widget.labelKey.tr(context: context),
          enabled: widget.enabled,
        ),
        child: AppText.raw(label, maxLines: 2),
      );
    }

    if (isMobile) {
      return InkWell(
        onTap: () => _openMobilePicker(context),
        borderRadius: style.radius,
        child: InputDecorator(
          decoration: InputDecoration(
            labelText: widget.labelKey.tr(context: context),
            suffixIcon: const AppIcon(AppIcons.expand),
          ),
          child: AppText.raw(
            label.isEmpty ? CatalogUiKeys.chooseOption.tr(context: context) : label,
            color: label.isEmpty ? style.colors.onSurfaceVariant : null,
            maxLines: 2,
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        RawAutocomplete<T>(
          key: ValueKey(identityHashCode(widget.options)),
          textEditingController: _desktopController,
          focusNode: _desktopFocusNode,
          displayStringForOption: widget.optionLabel,
          optionsBuilder: (value) => _options(value.text),
          onSelected: widget.onChanged,
          fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
            if (selected != null &&
                controller.text != label &&
                !focusNode.hasFocus) {
              controller.text = label;
            }
            return TextField(
              controller: controller,
              focusNode: focusNode,
              enabled: widget.enabled,
              readOnly: widget.readOnly,
              onChanged: _query,
              style: AppTextFieldStyle(context).textStyle,
              decoration: AppTextFieldStyle(context).decoration(
                label: widget.labelKey.tr(context: context),
                hint: CatalogUiKeys.search.tr(context: context),
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
        if (widget.loading)
          const Center(child: CircularProgressIndicator()),
        if (!widget.loading &&
            widget.errorKey == null &&
            _lastQuery.isNotEmpty &&
            _options(_lastQuery).isEmpty)
          Padding(
            padding: context.ui.padding.all(AppSpacing.sm),
            child: AppText(widget.emptyKey),
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
    return Align(
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
    );
  }

  Widget _optionsContent(
    BuildContext context,
    List<T> options,
    ValueChanged<T> select,
  ) {
    if (widget.errorKey != null) {
      return Padding(
        padding: context.ui.padding.all(AppSpacing.sm),
        child: InlineBanner(
          messageKey: widget.errorKey!,
          variant: InlineBannerVariant.error,
        ),
      );
    }
    if (widget.loading) {
      return Padding(
        padding: context.ui.padding.all(AppSpacing.lg),
        child: const Center(child: CircularProgressIndicator()),
      );
    }
    if (options.isEmpty) {
      return Padding(
        padding: context.ui.padding.all(AppSpacing.md),
        child: AppText(widget.emptyKey, color: Theme.of(context).colorScheme.onSurfaceVariant),
      );
    }
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
        heightFactor: 0.9,
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
    if (result != null) widget.onChanged(result);
  }
}

class _PickerData<T extends Object> {
  const _PickerData({required this.options, required this.loading, required this.errorKey});
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
  String _query = '';

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<_PickerData<T>>(
      valueListenable: widget.data,
      builder: (context, data, _) {
        final options = widget.filterLocally && _query.trim().isNotEmpty
            ? data.options.where(
                (option) =>
                    widget.optionLabel(option).toLowerCase().contains(
                      _query.trim().toLowerCase(),
                    ) ||
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
                TextField(
                  autofocus: true,
                  onChanged: (value) {
                    setState(() => _query = value);
                    widget.onQueryChanged?.call(value);
                  },
                  decoration: InputDecoration(
                    labelText: widget.labelKey.tr(context: context),
                    prefixIcon: const AppIcon(AppIcons.search),
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
                          ? const Center(
                              child: CircularProgressIndicator(),
                            )
                          : options.isEmpty
                              ? Center(child: AppText(widget.emptyKey))
                              : ListView(
                                  children: [
                                    for (final option in options)
                                      ListTile(
                                        title: AppText.raw(
                                          widget.optionLabel(option),
                                          maxLines: 2,
                                        ),
                                        subtitle:
                                            widget.optionSubtitle?.call(option) ==
                                                    null
                                                ? null
                                                : AppText.raw(
                                                    widget.optionSubtitle!(
                                                      option,
                                                    )!,
                                                  ),
                                        onTap: () => widget.onSelect(option),
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
