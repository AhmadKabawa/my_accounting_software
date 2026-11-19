import 'package:flutter/material.dart';
import 'package:accounting_software/app/core/localization/translations/app_key.dart';
import 'package:accounting_software/app/core/presentation/design_system/responsive/extension/ui_extension.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_text/app_text.dart';

class AppPageHeader extends StatelessWidget {
  const AppPageHeader({
    super.key,
    required this.titleKey,
    this.count,
    this.primaryAction,
    this.subtitle,
    this.breadcrumb,
  });

  final AppKey titleKey;
  final int? count;
  final Widget? primaryAction;
  final Widget? subtitle;
  final Widget? breadcrumb;

  @override
  Widget build(BuildContext context) {
    final title = Row(
      children: [
        Flexible(child: AppText(titleKey, type: AppTextType.headlineSmall)),
        if (count != null) ...[
          context.ui.spacing.gap(AppSpacing.sm, axis: Axis.horizontal),
          AppText.raw('($count)', type: AppTextType.titleSmall, color: context.ui.theme.colors.onSurfaceVariant),
        ],
      ],
    );
    return Padding(
      padding: context.ui.padding.symmetric(vertical: AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (breadcrumb != null) ...[breadcrumb!, context.ui.spacing.gap(AppSpacing.xs, axis: Axis.vertical)],
          LayoutBuilder(
            builder: (context, constraints) {
              final action = primaryAction;
              if (action == null) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [title, if (subtitle != null) subtitle!],
                );
              }
              if (constraints.maxWidth < context.ui.size.width(AppComponentSize.cardWidth)) {\n                return Column(\n                  crossAxisAlignment: CrossAxisAlignment.stretch,\n                  children: [title, if (subtitle != null) subtitle!, action],\n                );\n              }\n              return Row(
                children: [
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [title, if (subtitle != null) subtitle!])),
                  action,
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
