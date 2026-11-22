import 'package:flutter/material.dart';
import 'package:accounting_software/app/core/localization/keys/catalog_ui_keys.dart';
import 'package:accounting_software/app/core/localization/translations/app_key.dart';
import 'package:accounting_software/app/core/presentation/design_system/responsive/extension/ui_extension.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_data_view/app_view_mode.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_icon/app_icon.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_text/app_text.dart';

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
    final colors = context.ui.theme.colors;
    final radius = AppSurfaceShape.control.circular(context);
    final others = [
      for (final mode in modes)
        if (mode != selected) mode,
    ];
    final side = context.ui.size.width(AppComponentSize.medium);
    return Semantics(
      container: true,
      label:
          '${CatalogUiKeys.viewMode.tr(context: context)}: '
          '${labelOf(selected).tr(context: context)}',
      child: PopupMenuButton<AppViewMode>(
        tooltip: CatalogUiKeys.viewMode.tr(context: context),
        position: PopupMenuPosition.under,
        onSelected: onChanged,
        itemBuilder: (menuContext) => [
          for (final mode in others)
            PopupMenuItem<AppViewMode>(
              value: mode,
              child: Row(
                children: [
                  AppIcon(iconOf(mode), size: AppIconSize.md),
                  menuContext.ui.spacing.gap(
                    AppSpacing.sm,
                    axis: Axis.horizontal,
                  ),
                  AppText(labelOf(mode)),
                ],
              ),
            ),
        ],
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: context.ui.theme.saasColors.tableHeaderBand,
            borderRadius: radius,
          ),
          child: SizedBox(
            height: side,
            child: Padding(
              padding: context.ui.padding.symmetric(horizontal: AppSpacing.sm),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AppIcon(
                    iconOf(selected),
                    size: AppIconSize.md,
                    color: colors.onSurface,
                  ),
                  AppIcon(
                    AppIcons.expand,
                    size: AppIconSize.sm,
                    color: colors.onSurfaceVariant,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
