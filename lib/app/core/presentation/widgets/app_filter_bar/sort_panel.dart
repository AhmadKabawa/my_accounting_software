import 'package:flutter/material.dart';
import 'package:accounting_software/app/core/localization/keys/catalog_ui_keys.dart';
import 'package:accounting_software/app/core/localization/translations/app_key.dart';
import 'package:accounting_software/app/core/presentation/design_system/responsive/extension/ui_extension.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_button/app_button.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_icon/app_icon.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_text/app_text.dart';

class FilterBarSortOption {
  const FilterBarSortOption({required this.key, required this.label});
  final String key;
  final AppKey label;
}

class FilterBarSort {
  const FilterBarSort(this.key, this.ascending);
  final String key;
  final bool ascending;
  @override
  bool operator ==(Object other) =>
      other is FilterBarSort && other.key == key && other.ascending == ascending;
  @override
  int get hashCode => Object.hash(key, ascending);
}

/// Updates an existing criterion or adds one if capacity remains; never drops
/// an older criterion or removes a sort when its direction is pressed.
List<FilterBarSort> toggleSort(List<FilterBarSort> current, String key, bool ascending, {int maxSorts = 2}) {
  if (maxSorts < 1) return const [];
  final next = current.take(maxSorts).toList();
  final index = next.indexWhere((sort) => sort.key == key);
  if (index >= 0) {
    next[index] = FilterBarSort(key, ascending);
    return next;
  }
  if (next.length >= maxSorts) return next;
  next.add(FilterBarSort(key, ascending));
  return next;
}

/// Two-level server sort editor. The supplied [sorts] always drives the UI.
class SortPanel extends StatelessWidget {
  const SortPanel({super.key, required this.options, required this.sorts, required this.onChanged, this.maxSorts = 2});
  static const _none = '__none__';
  final List<FilterBarSortOption> options;
  final List<FilterBarSort> sorts;
  final ValueChanged<List<FilterBarSort>> onChanged;
  final int maxSorts;
  FilterBarSort? get _first => sorts.isEmpty ? null : sorts.first;
  FilterBarSort? get _second => maxSorts < 2 || sorts.length < 2 ? null : sorts[1];

  void _changeFirst(String? key) {
    if (key == null || key.isEmpty || _first?.key == key) return;
    final second = _second;
    onChanged([FilterBarSort(key, true), if (second != null && second.key != key) second]);
  }

  void _changeSecond(String? key) {
    final first = _first;
    if (first == null) return;
    if (key == null || key == _none) {
      if (_second != null) onChanged([first]);
      return;
    }
    if (key == first.key || _second?.key == key) return;
    onChanged([first, FilterBarSort(key, true)]);
  }

  void _toggle(int index) {
    final next = sorts.take(maxSorts).toList();
    if (index >= next.length) return;
    final item = next[index];
    next[index] = FilterBarSort(item.key, !item.ascending);
    onChanged(next);
  }

  @override
  Widget build(BuildContext context) {
    final first = _first;
    final second = _second;
    final duplicate = first != null && second != null && first.key == second.key;
    return Padding(
      padding: context.ui.padding.all(AppSpacing.sm),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _row(context, label: CatalogUiKeys.sortBy, selected: first?.key,
            ascending: first?.ascending ?? true, onField: _changeFirst,
            onDirection: first == null ? null : () => _toggle(0), allowNone: false),
          if (maxSorts > 1) ...[
            context.ui.spacing.gap(AppSpacing.sm),
            _row(context, label: CatalogUiKeys.thenBy,
              selected: duplicate ? _none : second?.key ?? _none,
              ascending: second?.ascending ?? true, onField: _changeSecond,
              onDirection: second == null ? null : () => _toggle(1), allowNone: true,
              primaryKey: first?.key),
            if (duplicate)
              Padding(
                padding: context.ui.padding.only(top: AppSpacing.xs),
                child: AppText(CatalogUiKeys.sortFieldAlreadySelected,
                  type: AppTextType.bodySmall, color: context.ui.theme.colors.error),
              ),
          ],
        ],
      ),
    );
  }

  Widget _row(BuildContext context, {required AppKey label, required String? selected,
    required bool ascending, required ValueChanged<String?> onField,
    required VoidCallback? onDirection, required bool allowNone, String? primaryKey}) {
    final items = <DropdownMenuItem<String>>[
      if (allowNone) DropdownMenuItem(value: _none, child: AppText(CatalogUiKeys.none)),
      for (final option in options)
        DropdownMenuItem(value: option.key, enabled: option.key != primaryKey,
          child: AppText(option.label)),
    ];
    final value = selected != null && items.any((item) => item.value == selected)
        ? selected : (allowNone ? _none : null);
    return Row(children: [
      Expanded(child: DropdownButtonFormField<String>(
        value: value, isExpanded: true,
        decoration: InputDecoration(labelText: label.tr(context: context), isDense: true),
        items: items, onChanged: onField,
      )),
      context.ui.spacing.gap(AppSpacing.sm, axis: Axis.horizontal),
      AppButton(ascending ? CatalogUiKeys.sortAscendingLabel : CatalogUiKeys.sortDescendingLabel,
        icon: ascending ? AppIcons.sortAscending : AppIcons.sortDescending,
        size: AppButtonSize.medium, variant: AppButtonVariant.outlined,
        onPressed: onDirection),
    ]);
  }
}
