import 'package:flutter/material.dart';
import 'package:accounting_software/app/core/localization/translations/app_key.dart';
import 'package:accounting_software/app/core/presentation/design_system/responsive/extension/ui_extension.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_icon/app_icon.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_text/app_text.dart';

/// The one anchored dropdown of the design system: a surface card with the
/// control radius, a hairline border and soft elevation, opened from any
/// [anchorBuilder] widget. [children] are usually [AppDropdownItem]s, but any
/// widget works (a panel keeps the menu open while it changes).
///
/// Use it for view menus, sort menus and other small pick-lists instead of a
/// raw `PopupMenuButton`, so every dropdown looks and spaces the same.
class AppDropdownMenu extends StatelessWidget {
  const AppDropdownMenu({
    super.key,
    required this.anchorBuilder,
    required this.children,
    this.minWidth,
    this.alignment = AlignmentDirectional.bottomStart,
  });

  /// Builds the anchor; call [toggle] to open or close the menu.
  final Widget Function(BuildContext context, VoidCallback toggle, bool open)
  anchorBuilder;
  final List<Widget> children;
  final AppComponentSize? minWidth;
  final AlignmentGeometry alignment;

  @override
  Widget build(BuildContext context) {
    final colors = context.ui.theme.colors;
    final width = context.ui.size.width(
      minWidth ?? AppComponentSize.filterControlWidth,
    );
    return MenuAnchor(
      alignmentOffset: Offset(0, context.ui.spacing.xs),
      style: MenuStyle(
        backgroundColor: WidgetStatePropertyAll(colors.surface),
        surfaceTintColor: const WidgetStatePropertyAll(Colors.transparent),
        elevation: WidgetStatePropertyAll(
          context.ui.shadow.value(AppElevation.md),
        ),
        padding: WidgetStatePropertyAll(
          context.ui.padding.all(AppSpacing.xs),
        ),
        minimumSize: WidgetStatePropertyAll(Size(width, 0)),
        shape: WidgetStatePropertyAll(
          RoundedRectangleBorder(
            borderRadius: AppSurfaceShape.control.circular(context),
            side: BorderSide(
              color: colors.outlineVariant,
              width: AppBorderWidth.thin.of(context),
            ),
          ),
        ),
      ),
      menuChildren: children,
      builder: (context, controller, _) => anchorBuilder(
        context,
        () => controller.isOpen ? controller.close() : controller.open(),
        controller.isOpen,
      ),
    );
  }
}

/// One row of an [AppDropdownMenu]. The chosen row uses the `selected` token
/// (the brand color); [trailing] is for a check or a direction mark. Choosing
/// a row closes the menu.
class AppDropdownItem extends StatelessWidget {
  const AppDropdownItem({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.selected = false,
    this.trailing,
  });

  final AppKey label;
  final VoidCallback? onPressed;
  final AppIconData? icon;
  final bool selected;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final saas = context.ui.theme.saasColors;
    final colors = context.ui.theme.colors;
    final foreground = selected ? saas.onSelected : colors.onSurface;
    return MenuItemButton(
      onPressed: onPressed,
      style: ButtonStyle(
        backgroundColor: WidgetStatePropertyAll(
          selected ? saas.selected : Colors.transparent,
        ),
        foregroundColor: WidgetStatePropertyAll(foreground),
        overlayColor: WidgetStatePropertyAll(
          colors.onSurface.withValues(alpha: 0.08),
        ),
        minimumSize: WidgetStatePropertyAll(
          Size(0, context.ui.size.height(AppComponentSize.medium)),
        ),
        padding: WidgetStatePropertyAll(
          context.ui.padding.symmetric(horizontal: AppSpacing.md),
        ),
        shape: WidgetStatePropertyAll(
          RoundedRectangleBorder(
            borderRadius: AppSurfaceShape.control.circular(context),
          ),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            AppIcon(icon!, size: AppIconSize.md, color: foreground),
            context.ui.spacing.gap(AppSpacing.sm, axis: Axis.horizontal),
          ],
          AppText(label, color: foreground),
          if (trailing != null) ...[
            context.ui.spacing.gap(AppSpacing.md, axis: Axis.horizontal),
            trailing!,
          ],
        ],
      ),
    );
  }
}
