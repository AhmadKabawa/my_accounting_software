import 'package:flutter/material.dart';
import 'package:accounting_software/app/core/localization/translations/app_key.dart';
import 'package:accounting_software/app/core/presentation/design_system/responsive/extension/ui_extension.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_text/app_text.dart';

class AppBreadcrumbItem {
  const AppBreadcrumbItem({required this.label, this.onTap});

  final AppKey label;
  final VoidCallback? onTap;
}

/// Direction-aware breadcrumb trail; the final item is the current location.
class AppBreadcrumb extends StatelessWidget {
  const AppBreadcrumb({super.key, required this.items});

  final List<AppBreadcrumbItem> items;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();

    final muted = context.ui.theme.colors.onSurfaceVariant;
    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: context.ui.spacing.xs,
      children: [
        for (var i = 0; i < items.length; i++) ...[
          if (i > 0) AppText.raw('›', color: muted),
          if (i == items.length - 1 || items[i].onTap == null)
            AppText(
              items[i].label,
              type: AppTextType.labelSmall,
              color: i == items.length - 1 ? null : muted,
            )
          else
            TextButton(
              onPressed: items[i].onTap,
              child: AppText(
                items[i].label,
                type: AppTextType.labelSmall,
              ),
            ),
        ],
      ],
    );
  }
}
