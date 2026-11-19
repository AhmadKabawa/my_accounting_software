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
    final hitArea = context.ui.size.width(AppComponentSize.hitArea);
    final separator = Directionality.of(context) == TextDirection.rtl
        ? '‹'
        : '›';

    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: context.ui.spacing.xs,
      children: [
        for (var i = 0; i < items.length; i++) ...[
          if (i > 0) AppText.raw(separator, color: muted),
          if (i == items.length - 1)
            Semantics(
              label: items[i].label.tr(context: context),
              selected: true,
              child: ExcludeSemantics(
                child: AppText(items[i].label, type: AppTextType.labelSmall),
              ),
            )
          else if (items[i].onTap == null)
            AppText(items[i].label, type: AppTextType.labelSmall, color: muted)
          else
            TextButton(
              style: TextButton.styleFrom(minimumSize: Size(hitArea, hitArea)),
              onPressed: items[i].onTap,
              child: AppText(items[i].label, type: AppTextType.labelSmall),
            ),
        ],
      ],
    );
  }
}
