import 'package:flutter/material.dart';
import 'package:accounting_software/app/core/access/permission.dart';
import 'package:accounting_software/app/core/presentation/state_management/list_selection_cubit.dart';
import 'package:accounting_software/app/core/access/permission_gate/permission_gate.dart';
import 'package:accounting_software/app/core/localization/keys/catalog_ui_keys.dart';
import 'package:accounting_software/app/core/presentation/design_system/responsive/compact_content_breakpoint.dart';
import 'package:accounting_software/app/core/localization/translations/app_key.dart';
import 'package:accounting_software/app/core/presentation/design_system/responsive/extension/ui_extension.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_button/app_button.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_button/app_icon_button.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_icon/app_icon.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_text/app_text.dart';

class BulkAction {
  const BulkAction({
    required this.labelKey,
    required this.icon,
    required this.permission,
    required this.onRun,
    this.destructive = false,
    this.confirm,
  });

  final AppKey labelKey;
  final AppIconData icon;
  final Permission permission;
  final bool destructive;
  final Future<void> Function() onRun;
  final Future<bool> Function(BuildContext context, int selectedCount)? confirm;
}

/// Actions for the selected records. The caller supplies only actions available
/// to the current feature; each action is additionally permission-gated here.
class BulkActionBar extends StatefulWidget {
  const BulkActionBar({
    super.key,
    required this.selectedCount,
    required this.actions,
    required this.onClear,
    this.pageSelectionState = PageSelectionState.none,
    this.onSelectPage,
  });

  final int selectedCount;
  final List<BulkAction> actions;
  final VoidCallback onClear;
  final PageSelectionState pageSelectionState;
  final ValueChanged<bool>? onSelectPage;

  @override
  State<BulkActionBar> createState() => _BulkActionBarState();
}

class _BulkActionBarState extends State<BulkActionBar> {
  bool _running = false;

  Future<void> _run(BulkAction action) async {
    if (_running) return;
    setState(() => _running = true);
    try {
      final confirm = action.confirm;
      if (confirm != null && !await confirm(context, widget.selectedCount)) {
        return;
      }
      await action.onRun();
    } finally {
      if (mounted) setState(() => _running = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.hasBoundedWidth
            ? constraints.maxWidth
            : MediaQuery.sizeOf(context).width;
        final compact = width < compactContentBreakpoint;
        return Container(
          padding: context.ui.padding.all(AppSpacing.sm),
          decoration: BoxDecoration(
            color: context.ui.theme.colors.surfaceContainerHighest,
            borderRadius: AppSurfaceShape.control.circular(context),
          ),
          child: Wrap(
            spacing: context.ui.spacing.sm,
            runSpacing: context.ui.spacing.sm,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              if (widget.onSelectPage != null) ...[
                Semantics(
                  label: CatalogUiKeys.selectPage.tr(context: context),
                  child: Checkbox(
                    tristate: true,
                    value: switch (widget.pageSelectionState) {
                      PageSelectionState.none => false,
                      PageSelectionState.partial => null,
                      PageSelectionState.all => true,
                    },
                    onChanged: _running
                        ? null
                        : (_) => widget.onSelectPage!(
                            widget.pageSelectionState != PageSelectionState.all,
                          ),
                  ),
                ),
              ],
              AppText.raw(
                CatalogUiKeys.selectedCount.tr(
                  context: context,
                  namedArgs: {'count': widget.selectedCount.toString()},
                ),
                type: AppTextType.labelMedium,
              ),
              for (final action in widget.actions)
                PermissionGate(
                  permission: action.permission,
                  child: compact
                      ? AppIconButton(
                          action.icon,
                          tooltipKey: action.labelKey,
                          size: AppButtonSize.small,
                          variant: action.destructive
                              ? AppButtonVariant.danger
                              : AppButtonVariant.outlined,
                          onPressed: _running || widget.selectedCount == 0
                              ? null
                              : () => _run(action),
                        )
                      : AppButton(
                          action.labelKey,
                          icon: action.icon,
                          size: AppButtonSize.medium,
                          variant: action.destructive
                              ? AppButtonVariant.danger
                              : AppButtonVariant.outlined,
                          onPressed: _running || widget.selectedCount == 0
                              ? null
                              : () => _run(action),
                        ),
                ),
              if (compact)
                AppIconButton(
                  AppIcons.close,
                  tooltipKey: CatalogUiKeys.finishSelection,
                  size: AppButtonSize.small,
                  onPressed: _running ? null : widget.onClear,
                )
              else
                AppButton(
                  CatalogUiKeys.finishSelection,
                  size: AppButtonSize.small,
                  variant: AppButtonVariant.text,
                  onPressed: _running ? null : widget.onClear,
                ),
            ],
          ),
        );
      },
    );
  }
}
