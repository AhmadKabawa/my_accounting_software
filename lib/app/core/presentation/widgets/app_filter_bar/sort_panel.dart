import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:accounting_software/app/core/localization/keys/catalog_ui_keys.dart';
import 'package:accounting_software/app/core/presentation/design_system/responsive/extension/ui_extension.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_button/app_button.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_dropdown_menu/app_dropdown_menu.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_filter_bar/filter_bar_sort.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_filter_bar/sort_criterion_row.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_icon/app_icon.dart';

export 'filter_bar_sort.dart';

class SortPanel extends StatelessWidget {
  const SortPanel({
    super.key,
    required this.options,
    required this.sorts,
    required this.onChanged,
    this.maxSorts = 0,
  });

  final List<FilterBarSortOption> options;
  final List<FilterBarSort> sorts;
  final ValueChanged<List<FilterBarSort>> onChanged;

  final int maxSorts;

  int get _limit => maxSorts > 0 && maxSorts < options.length
      ? maxSorts
      : options.length;

  bool _usedElsewhere(String key, int index) => sorts.indexed.any(
    (entry) => entry.$1 != index && entry.$2.key == key,
  );

  void _selectField(int index, String key) {
    if (_usedElsewhere(key, index)) return;
    final next = sorts.toList();
    if (index < next.length) {
      next[index] = FilterBarSort(key, next[index].ascending);
    } else if (index == next.length) {
      next.add(FilterBarSort(key, true));
    } else {
      return;
    }
    onChanged(next);
  }

  void _addField(String key) {
    if (sorts.length >= _limit || sorts.any((sort) => sort.key == key)) return;
    onChanged([...sorts, FilterBarSort(key, true)]);
  }

  void _removeField(int index) {
    if (index <= 0 || index >= sorts.length) return;
    onChanged(sorts.toList()..removeAt(index));
  }

  void _toggleDirection(int index) {
    if (index >= sorts.length) return;
    final next = sorts.toList();
    next[index] = FilterBarSort(next[index].key, !next[index].ascending);
    onChanged(next);
  }

  void _moveField(int index, int offset) {
    final target = index + offset;
    if (target < 0 || target >= sorts.length) return;
    final next = sorts.toList();
    final current = next[index];
    next[index] = next[target];
    next[target] = current;
    onChanged(next);
  }

  @override
  Widget build(BuildContext context) {
    final hasDuplicate =
        sorts.map((sort) => sort.key).toSet().length != sorts.length;
    final limitExceeded = sorts.length > _limit;
    final rowCount = math.max(1, math.min(sorts.length, _limit));
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.hasBoundedWidth
            ? constraints.maxWidth
            : context.ui.size.width(AppComponentSize.filterControlWidth);
        return SizedBox(
          width: width,
          child: Padding(
            padding: context.ui.padding.all(AppSpacing.sm),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (var index = 0; index < rowCount; index++) ...[
                  if (index > 0) context.ui.spacing.gap(AppSpacing.sm),
                  SortCriterionRow(
                    options: options,
                    current: index < sorts.length ? sorts[index] : null,
                    sortsLength: sorts.length,
                    isUsedElsewhere: (key) => _usedElsewhere(key, index),
                    onSelect: (key) => _selectField(index, key),
                    onDirection: index < sorts.length ? () => _toggleDirection(index) : null,
                    onMoveUp: index > 0 ? () => _moveField(index, -1) : null,
                    onMoveDown: index < sorts.length - 1
                        ? () => _moveField(index, 1)
                        : null,
                    onRemove: index > 0 ? () => _removeField(index) : null,
                  ),
                ],
                if (sorts.isNotEmpty && sorts.length < _limit &&
                    options.any(
                      (option) => !sorts.any((sort) => sort.key == option.key),
                    )) ...[
                  context.ui.spacing.gap(AppSpacing.sm),
                  _addCriterionMenu(),
                ],
                if (hasDuplicate || limitExceeded) ...[
                  context.ui.spacing.gap(AppSpacing.xs),
                  AppText(
                    hasDuplicate
                        ? CatalogUiKeys.sortFieldAlreadySelected
                        : CatalogUiKeys.sortLimitExceeded,
                    type: AppTextType.bodySmall,
                    color: context.ui.theme.colors.error,
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _addCriterionMenu() {
    final available = options
        .where((option) => !sorts.any((sort) => sort.key == option.key))
        .toList(growable: false);
    return AppDropdownMenu(
      minWidth: AppComponentSize.filterControlWidth,
      anchorBuilder: (context, toggle, open) => AppButton(
        CatalogUiKeys.thenBy,
        icon: AppIcons.add,
        variant: AppButtonVariant.text,
        onPressed: toggle,
      ),
      children: [
        for (final option in available)
          AppDropdownItem(
            label: option.label,
            onPressed: () => _addField(option.key),
          ),
      ],
    );
  }
}
