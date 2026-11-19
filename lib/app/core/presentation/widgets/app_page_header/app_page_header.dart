import 'package:flutter/material.dart';
import 'package:accounting_software/app/core/localization/translations/app_key.dart';
import 'package:accounting_software/app/core/presentation/design_system/responsive/extension/ui_extension.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_text/app_text.dart';

/// Standard page heading with an optional count, breadcrumb and primary action.
/// On narrow widths the action is stacked below the heading; a bottom action
/// bar is owned by the page template, not by this header.
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
          AppText.raw(
            '\u2068($count)\u2069',
            type: AppTextType.titleSmall,
            color: context.ui.theme.colors.onSurfaceVariant,
          ),
        ],
      ],
    );

    return Padding(
      padding: context.ui.padding.symmetric(vertical: AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (breadcrumb != null) ...[
            breadcrumb!,
            context.ui.spacing.gap(AppSpacing.xs, axis: Axis.vertical),
          ],
          LayoutBuilder(
            builder: (context, constraints) {
              final action = primaryAction;
              final heading = Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [title, if (subtitle != null) subtitle!],
              );
              if (action == null) return heading;

              if (constraints.maxWidth <
                  context.ui.size.width(AppComponentSize.cardWidth)) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [heading, action],
                );
              }

              return Row(
                children: [
                  Expanded(child: heading),
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
