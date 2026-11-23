import 'package:flutter/material.dart';
import 'package:accounting_software/app/core/localization/keys/catalog_ui_keys.dart';
import 'package:accounting_software/app/core/localization/translations/app_key.dart';
import 'package:accounting_software/app/core/presentation/design_system/responsive/extension/ui_extension.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_button/app_button.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_button/app_icon_button.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_dropdown_menu/app_dropdown_menu.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_filter_bar/filter_bar_sort.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_text/app_text.dart';

/// Field selection and sort direction are separate touch targets.
class SortFieldButton extends StatelessWidget {
  const SortFieldButton({
    super.key,
    required this.options,
    required this.current,
    required this.isUsedElsewhere,
    required this.onSelect,
    required this.onDirection,
    required this.expandField,
  });

  final List<FilterBarSortOption> options;
  final FilterBarSort? current;
  final bool Function(String key) isUsedElsewhere;
  final ValueChanged<String> onSelect;
  final VoidCallback? onDirection;
  final bool expandField;

  @override
  Widget build(BuildContext context) {
    final selected = options.where((option) => option.key == current?.key);
    final selectedLabel = selected.isEmpty
        ? CatalogUiKeys.chooseOption
        : selected.first.label;
    final ascending = current?.ascending ?? true;
    final colors = context.ui.theme.colors;

    final fieldMenu = AppDropdownMenu(
      minWidth: AppComponentSize.none,
      anchorBuilder: (context, toggle, open) => Semantics(
        button: true,
        label: CatalogUiKeys.sortChooseField.tr(context: context),
        excludeSemantics: true,
        child: Material(
          color: colors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: AppSurfaceShape.control.circular(context),
            side: BorderSide(
              color: colors.outlineVariant,
              width: AppBorderWidth.thin.of(context),
            ),
          ),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: toggle,
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: context.ui.size.height(AppComponentSize.hitArea),
              ),
              child: Padding(
                padding: context.ui.padding.symmetric(
                  horizontal: AppSpacing.sm,
                ),
                child: AppText(
                  selectedLabel,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  useEllipsis: true,
                ),
              ),
            ),
          ),
        ),
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

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (expandField)
          Expanded(child: fieldMenu)
        else
          Flexible(fit: FlexFit.loose, child: fieldMenu),
        if (current != null)
          AppIconButton(
            ascending ? AppIcons.sortAscending : AppIcons.sortDescending,
            tooltipKey: ascending
                ? CatalogUiKeys.sortAscendingLabel
                : CatalogUiKeys.sortDescendingLabel,
            size: AppButtonSize.small,
            onPressed: onDirection,
          ),
      ],
    );
  }
}
