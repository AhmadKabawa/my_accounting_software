import 'package:flutter/material.dart';
import 'package:accounting_software/app/core/localization/keys/catalog_ui_keys.dart';
import 'package:accounting_software/app/core/localization/translations/app_key.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_button/app_button.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_button/app_icon_button.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_menu/app_menu.dart';

/// One record action: icon + accessible name (shown as tooltip / menu label).
class AppRowAction {
  const AppRowAction({
    required this.icon,
    required this.labelKey,
    required this.onPressed,
    this.destructive = false,
  });

  final AppIconData icon;
  final AppKey labelKey;
  final VoidCallback? onPressed;

  /// Drawn with the danger style (e.g. delete).
  final bool destructive;
}

/// Row/card actions as icon buttons (never text buttons).
///
/// [primary] actions are shown inline as icon buttons with tooltips (keep it
/// to 2); [overflow] actions go to a "more" menu with icon + label.
class AppRowActions extends StatelessWidget {
  const AppRowActions({
    super.key,
    this.primary = const [],
    this.overflow = const [],
  });

  final List<AppRowAction> primary;
  final List<AppRowAction> overflow;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      for (final action in primary)
        AppIconButton(
          action.icon,
          tooltipKey: action.labelKey,
          variant: action.destructive
              ? AppButtonVariant.danger
              : AppButtonVariant.text,
          size: AppButtonSize.small,
          onPressed: action.onPressed,
        ),
      if (overflow.isNotEmpty)
        AppMenu(
          tooltipKey: CatalogUiKeys.moreActions,
          icon: AppIcons.more,
          entries: [
            for (final action in overflow)
              AppMenuEntry(
                label: action.labelKey,
                icon: action.icon,
                enabled: action.onPressed != null,
                onSelected: action.onPressed ?? () {},
              ),
          ],
        ),
    ],
  );
}
