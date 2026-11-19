import 'package:flutter/material.dart';
import 'package:accounting_software/app/core/access/models/access_snapshot.dart';
import 'package:accounting_software/app/core/localization/keys/shell_keys.dart';
import 'package:accounting_software/app/core/localization/translations/app_key.dart';
import 'package:accounting_software/app/core/presentation/design_system/responsive/extension/ui_extension.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_breadcrumb/app_breadcrumb.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_button/app_icon_button.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_icon/app_icon.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_menu/app_menu.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_scope_selector/scope_selector.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_text/app_text.dart';

class AppShellTopBar extends StatelessWidget implements PreferredSizeWidget {
  const AppShellTopBar({
    super.key,
    required this.titleKey,
    required this.snapshot,
    required this.selectedBranchId,
    required this.onBranchChanged,
    required this.userMenuEntries,
    this.beforeBranchChange,
    this.breadcrumbs = const [],
    this.cashierSessionKey,
    this.leading,
  });

  final AppKey titleKey;
  final AccessSnapshot snapshot;
  final int? selectedBranchId;
  final ValueChanged<int> onBranchChanged;
  final List<AppMenuEntry> userMenuEntries;
  final Future<bool> Function(ScopeOption)? beforeBranchChange;
  final List<AppBreadcrumbItem> breadcrumbs;
  final AppKey? cashierSessionKey;
  final Widget? leading;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final branches = [
      for (final branch in snapshot.branches)
        if (branch.canView)
          ScopeOption(
            id: branch.id.toString(),
            name: branch.name,
            viewOnly: !branch.canOperate,
          ),
    ];

    return AppBar(
      leading: leading,
      automaticallyImplyLeading: leading == null,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AppText(titleKey, type: AppTextType.titleMedium),
          if (breadcrumbs.isNotEmpty) AppBreadcrumb(items: breadcrumbs),
        ],
      ),
      actions: [
        if (branches.isNotEmpty)
          ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: context.ui.size.width(AppComponentSize.cardWidth),
            ),
            child: ScopeSelector(
              labelKey: ShellKeys.branch,
              options: branches,
              selectedId: selectedBranchId?.toString(),
              beforeChange: beforeBranchChange,
              onChanged: (option) {
                final id = int.tryParse(option.id);
                if (id != null) onBranchChanged(id);
              },
            ),
          ),
        if (cashierSessionKey != null)
          Padding(
            padding: context.ui.padding.directional(start: AppSpacing.sm),
            child: Center(
              child: AppText(cashierSessionKey!, type: AppTextType.labelMedium),
            ),
          ),
        AppIconButton(
          AppIcons.notifications,
          tooltipKey: ShellKeys.notificationsUnavailable,
          onPressed: null,
        ),
        if (userMenuEntries.isNotEmpty)
          AppMenu(
            entries: userMenuEntries,
            tooltipKey: ShellKeys.userMenu,
            icon: AppIcons.person,
          )
        else
          Padding(
            padding: context.ui.padding.directional(end: AppSpacing.md),
            child: Center(
              child: AppText.raw(
                snapshot.username,
                type: AppTextType.labelMedium,
              ),
            ),
          ),
      ],
    );
  }
}
