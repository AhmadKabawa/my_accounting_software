import 'package:flutter/material.dart';
import 'package:accounting_software/app/core/localization/keys/catalog_ui_keys.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_button/app_button.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_button/app_button_style.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_button/app_icon_button.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_filter_bar/filter_bar_sort.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_filter_bar/sort_field_button.dart';

/// One compact, single-line sort criterion.
class SortCriterionRow extends StatelessWidget {
  const SortCriterionRow({
    super.key,
    required this.options,
    required this.current,
    required this.isUsedElsewhere,
    required this.onSelect,
    required this.onDirection,
    required this.expandField,
    required this.onMoveUp,
    required this.reserveRemoveSlot,
    required this.onRemove,
  });

  final List<FilterBarSortOption> options;
  final FilterBarSort? current;
  final bool Function(String key) isUsedElsewhere;
  final ValueChanged<String> onSelect;
  final VoidCallback? onDirection;
  final bool expandField;
  final VoidCallback? onMoveUp;
  final bool reserveRemoveSlot;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    final field = SortFieldButton(
      options: options,
      current: current,
      isUsedElsewhere: isUsedElsewhere,
      onSelect: onSelect,
      onDirection: onDirection,
      onMoveUp: onMoveUp,
      expandField: expandField,
    );

    return Row(
      mainAxisSize: MainAxisSize.max,
      children: [
        if (expandField) Expanded(child: field) else Flexible(child: field),
        if (onRemove != null)
          AppIconButton(
            AppIcons.close,
            tooltipKey: CatalogUiKeys.removeSort,
            size: AppButtonSize.small,
            onPressed: onRemove,
          )
        else if (reserveRemoveSlot)
          SizedBox(width: AppButtonStyle(context).touchTarget),
      ],
    );
  }
}
