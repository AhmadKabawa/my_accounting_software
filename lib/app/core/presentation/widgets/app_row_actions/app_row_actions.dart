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
    this.iconColor,
  });

  final AppIconData icon;
  final AppKey labelKey;
  final VoidCallback? onPressed;

  /// Drawn with the danger style (e.g. delete).
  final bool destructive;

  /// Optional tint for the icon only; leaves the button surface unchanged.
  final Color? iconColor;
}

/// Row/card actions as icon buttons (never text buttons).
///
/// At most [maxVisible] actions are shown inline as icon buttons with
/// tooltips: the first [maxVisible] of [primary]. Any further [primary]
/// actions join [overflow] in the "more" menu (icon + label), so a row never
/// shows more than two icons plus the menu.
class AppRowActions extends StatelessWidget {
  const AppRowActions({
    super.key,
    this.primary = const [],
    this.overflow = const [],
  });

  static const maxVisible = 2;

  final List<AppRowAction> primary;
  final List<AppRowAction> overflow;

  @override
  Widget build(BuildContext context) {
    final inline = primary.take(maxVisible).toList();
    final menu = [...primary.skip(maxVisible), ...overflow];
    return _row(inline, menu);
  }

  Widget _row(List<AppRowAction> primary, List<AppRowAction> overflow) => Row(
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
          color: action.iconColor,
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
