import 'package:flutter/material.dart';
import 'package:accounting_software/app/core/localization/keys/catalog_ui_keys.dart';
import 'package:accounting_software/app/core/localization/translations/app_key.dart';
import 'package:accounting_software/app/core/presentation/design_system/responsive/extension/ui_extension.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_data_view/app_view_mode.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_icon/app_icon.dart';

/// Pill-shaped switch between the view modes a screen supports. The selected
/// mode uses the `selected` token. Each button has a tooltip and a semantic
/// "selected" state, so color is never the only signal.
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
    return Semantics(
      container: true,
      label: CatalogUiKeys.viewMode.tr(context: context),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: saas.tableHeaderBand,
          borderRadius: radius,
        ),
        child: Padding(
          padding: context.ui.padding.all(AppSpacing.xs),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (final mode in modes)
                _ModeButton(
                  mode: mode,
                  selected: mode == selected,
                  onTap: () => onChanged(mode),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ModeButton extends StatelessWidget {
  const _ModeButton({
    required this.mode,
    required this.selected,
    required this.onTap,
  });

  final AppViewMode mode;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final saas = context.ui.theme.saasColors;
    final radius = AppSurfaceShape.control.circular(context);
    final label = ViewModeSwitcher.labelOf(mode).tr(context: context);
    final side = context.ui.size.width(AppComponentSize.small);
    return Tooltip(
      message: label,
      child: Semantics(
        button: true,
        selected: selected,
        label: label,
        excludeSemantics: true,
        child: Material(
          color: selected ? saas.selected : Colors.transparent,
          borderRadius: radius,
          child: InkWell(
            borderRadius: radius,
            onTap: onTap,
            child: SizedBox.square(
              dimension: side,
              child: Center(
                child: AppIcon(
                  ViewModeSwitcher.iconOf(mode),
                  size: AppIconSize.md,
                  color: selected
                      ? saas.onSelected
                      : context.ui.theme.colors.onSurfaceVariant,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
