import 'package:flutter/material.dart';
import 'package:accounting_software/app/core/localization/keys/catalog_ui_keys.dart';
import 'package:accounting_software/app/core/localization/translations/app_key.dart';
import 'package:accounting_software/app/core/presentation/design_system/responsive/extension/ui_extension.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_data_view/app_view_mode.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_icon/app_icon.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_dropdown_menu/app_dropdown_menu.dart';

/// A small menu for the view modes a screen supports: the button shows the
/// icon of the current mode with a small arrow; opening it lists the other
/// modes. The button has a tooltip and a semantic label with the current mode.
class ViewModeSwitcher extends StatelessWidget {
  const ViewModeSwitcher({
    super.key,
    required this.modes,
    required this.selected,
    required this.onChanged,
  });

  final List<AppViewMode> modes;
  final AppViewMode selected;
  final ValueChanged<AppViewMode> onChanged;

  static AppIconData iconOf(AppViewMode mode) => switch (mode) {
    AppViewMode.table => AppIcons.tableView,
    AppViewMode.cards => AppIcons.cardView,
    AppViewMode.grid => AppIcons.gridView,
  };

  static AppKey labelOf(AppViewMode mode) => switch (mode) {
    AppViewMode.table => CatalogUiKeys.viewTable,
    AppViewMode.cards => CatalogUiKeys.viewCards,
    AppViewMode.grid => CatalogUiKeys.viewGrid,
  };

  @override
  Widget build(BuildContext context) {
    if (modes.length < 2) return const SizedBox.shrink();
    final saas = context.ui.theme.saasColors;
    final radius = AppSurfaceShape.control.circular(context);
    final side = context.ui.size.height(AppComponentSize.medium);
    return Semantics(
      container: true,
      label:
          '${CatalogUiKeys.viewMode.tr(context: context)}: '
          '${labelOf(selected).tr(context: context)}',
      child: AppDropdownMenu(
        minWidth: AppComponentSize.large,
        anchorBuilder: (context, toggle, open) => Tooltip(
          message: CatalogUiKeys.viewMode.tr(context: context),
          child: Material(
            color: saas.selected,
            borderRadius: radius,
            child: InkWell(
              borderRadius: radius,
              onTap: toggle,
              child: SizedBox(
                height: side,
                child: Padding(
                  padding: context.ui.padding.symmetric(
                    horizontal: AppSpacing.smMd,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AppIcon(
                        iconOf(selected),
                        size: AppIconSize.md,
                        color: saas.onSelected,
                      ),
                      context.ui.spacing.gap(
                        AppSpacing.xs,
                        axis: Axis.horizontal,
                      ),
                      AppIcon(
                        open ? AppIcons.collapse : AppIcons.expand,
                        size: AppIconSize.sm,
                        color: saas.onSelected,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        children: [
          for (final mode in modes)
            if (mode != selected)
              AppDropdownItem(
                label: labelOf(mode),
                icon: iconOf(mode),
                onPressed: () => onChanged(mode),
              ),
        ],
      ),
    );
  }
}
