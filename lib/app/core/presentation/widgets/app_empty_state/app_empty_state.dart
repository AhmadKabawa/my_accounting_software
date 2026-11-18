import 'package:flutter/material.dart';
import 'package:accounting_software/app/core/localization/translations/app_key.dart';
import 'package:accounting_software/app/core/presentation/design_system/responsive/engine/app_enums.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_icon/app_icon.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_text/app_text.dart';

/// Reusable empty, no-results, and other content-absence presentation.
///
/// All user-facing copy is supplied as [AppKey] values by the owning feature.
/// [action] is an optional slot, normally a localized action button.
class AppEmptyState extends StatelessWidget {
  const AppEmptyState({
    super.key,
    required this.icon,
    required this.titleKey,
    required this.descriptionKey,
    this.action,
    this.compact = false,
    this.textAlign = TextAlign.center,
  });

  final AppIconData icon;
  final AppKey titleKey;
  final AppKey descriptionKey;

  /// Optional action slot. Pass an AppButton (or another localized action).
  final Widget? action;

  /// Compact presentation for embedded table/card contexts.
  final bool compact;
  final TextAlign textAlign;

  @override
  Widget build(BuildContext context) {
    final spacing = compact ? AppSpacing.sm : AppSpacing.md;
    final foreground = Theme.of(context).colorScheme.onSurfaceVariant;

    return Center(
      child: Padding(
        padding: EdgeInsets.all(
          compact ? AppSpacing.md.of(context) : AppSpacing.lg.of(context),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            AppIcon(
              icon,
              size: compact ? AppIconSize.lg : AppIconSize.xl,
              color: foreground,
            ),
            SizedBox(height: spacing.of(context)),
            AppText(
              titleKey,
              type: AppTextType.titleMedium,
              textAlign: textAlign,
            ),
            SizedBox(height: AppSpacing.xs.of(context)),
            AppText(
              descriptionKey,
              type: AppTextType.bodyMedium,
              color: foreground,
              textAlign: textAlign,
            ),
            if (action != null) ...[
              SizedBox(height: spacing.of(context)),
              action!,
            ],
          ],
        ),
      ),
    );
  }
}
