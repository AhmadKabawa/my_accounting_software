import 'package:flutter/material.dart';
import 'package:accounting_software/app/core/localization/keys/catalog_ui_keys.dart';
import 'package:accounting_software/app/core/presentation/design_system/responsive/extension/ui_extension.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_button/app_button.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_button/app_icon_button.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_dropdown_menu/app_dropdown_menu.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_icon/app_icon.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_filter_bar/filter_bar_sort.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_text/app_text.dart';

/// One sort criterion: the field picker with its direction, move and remove
/// actions underneath.
///
/// It is laid out the same at every width and uses no [LayoutBuilder]: the
/// panel lives inside a [MenuAnchor], which measures intrinsic sizes, and a
/// LayoutBuilder cannot answer that query.
class SortCriterionRow extends StatelessWidget {
  const SortCriterionRow({
    super.key,
    required this.options,
    required this.current,
    required this.sortsLength,
    required this.isUsedElsewhere,
    required this.onSelect,
    required this.onDirection,
    required this.onMoveUp,
    required this.onMoveDown,
    required this.onRemove,
  });

  final List<FilterBarSortOption> options;
  final FilterBarSort? current;
  final int sortsLength;
  final bool Function(String key) isUsedElsewhere;
  final ValueChanged<String> onSelect;
  final VoidCallback? onDirection;
  final VoidCallback? onMoveUp;
  final VoidCallback? onMoveDown;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    final selected = options.where((option) => option.key == current?.key);
    final selectedLabel = selected.isEmpty
        ? CatalogUiKeys.chooseOption
        : selected.first.label;
    final ascending = current?.ascending ?? true;
    final fieldPicker = AppDropdownMenu(
      minWidth: AppComponentSize.filterControlWidth,
      anchorBuilder: (context, toggle, open) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppButton(
            selectedLabel,
            icon: AppIcons.expand,
            variant: AppButtonVariant.outlined,
            onPressed: toggle,
          ),
          if (open && sortsLength > 1) ...[
            context.ui.spacing.gap(AppSpacing.xs),
            AppText(
              CatalogUiKeys.sortFieldAlreadySelected,
              type: AppTextType.bodySmall,
              color: context.ui.theme.colors.error,
            ),
          ],
        ],
      ),
      children: [
        for (final option in options)
          AppDropdownItem(
            label: option.label,
            selected: option.key == current?.key,
            onPressed: isUsedElsewhere(option.key)
                ? null
                : () => onSelect(option.key),
          ),
      ],
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        fieldPicker,
        context.ui.spacing.gap(AppSpacing.xs),
        // Wraps instead of overflowing on a narrow panel or a large text scale.
        Wrap(
          alignment: WrapAlignment.end,
          spacing: context.ui.spacing.xs,
          children: [
            AppIconButton(
              ascending ? AppIcons.sortAscending : AppIcons.sortDescending,
              tooltipKey: ascending
                  ? CatalogUiKeys.sortAscendingLabel
                  : CatalogUiKeys.sortDescendingLabel,
              size: AppButtonSize.small,
              onPressed: onDirection,
            ),
            if (onMoveUp != null)
              AppIconButton(
                AppIcons.moveSortUp,
                tooltipKey: CatalogUiKeys.moveSortUp,
                size: AppButtonSize.small,
                onPressed: onMoveUp,
              ),
            if (onMoveDown != null)
              AppIconButton(
                AppIcons.moveSortDown,
                tooltipKey: CatalogUiKeys.moveSortDown,
                size: AppButtonSize.small,
                onPressed: onMoveDown,
              ),
            if (onRemove != null)
              AppIconButton(
                AppIcons.close,
                tooltipKey: CatalogUiKeys.removeSort,
                size: AppButtonSize.small,
                onPressed: onRemove,
              ),
          ],
        ),
      ],
    );
  }
}
