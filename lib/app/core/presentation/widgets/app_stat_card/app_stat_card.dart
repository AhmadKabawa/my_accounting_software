import 'package:flutter/material.dart';
import 'package:accounting_software/app/core/localization/translations/app_key.dart';
import 'package:accounting_software/app/core/presentation/design_system/responsive/extension/ui_extension.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_badge/app_badge.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_badge/app_badge_style.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_card/app_card.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_icon/app_icon.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_skeleton/app_skeleton.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_text/app_text.dart';

/// A summary tile: a [titleKey], a [value] that stands out from the title, a
/// semantic [icon] in a quiet tone, an optional [descriptionKey].
///
/// * [loading] shows placeholders; a null [value] is the empty state (a dash).
/// * [selected] is the pressed/chosen state: a thicker border plus the
///   `selected` semantic flag, so color is never the only signal.
/// * Tappable when [onTap] is given (e.g. to apply a list filter).
/// * No growth or change indicators: those need computed comparison data,
///   which this widget does not accept.
///
/// Colors come from the same tone tokens as `AppBadge`, in Light and Dark.
class AppStatCard extends StatelessWidget {
  const AppStatCard({
    super.key,
    required this.titleKey,
    required this.value,
    this.icon,
    this.tone = AppBadgeTone.neutral,
    this.descriptionKey,
    this.loading = false,
    this.selected = false,
    this.onTap,
    this.compact = false,
  });

  final AppKey titleKey;

  /// Already formatted by the caller. null = no data yet (empty state).
  final String? value;
  final AppIconData? icon;
  final AppBadgeTone tone;
  final AppKey? descriptionKey;
  final bool loading;
  final bool selected;
  final VoidCallback? onTap;

  /// A slim tile for dense pages: small padding, title above the value, no
  /// description. Use it when several tiles sit in one row.
  final bool compact;

  static const _emptyValue = '—';

  @override
  Widget build(BuildContext context) {
    final colors = context.ui.theme.colors;
    final (foreground, background) = AppBadgeStyle.toneColors(context, tone);
    final shown = value ?? _emptyValue;
    final tappable = !loading && onTap != null;
    final effectiveSelected = tappable && selected;
    // One merged node: "title value description", tappable when [onTap].
    return MergeSemantics(
      child: AppCard(
        padding: compact ? AppSpacing.sm : AppSpacing.md,
        selected: effectiveSelected,
        onTap: tappable ? onTap : null,
        child: loading
            ? _loading(context)
            : Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  if (icon != null) ...[
                    _IconBadge(
                      icon: icon!,
                      foreground: foreground,
                      background: background,
                    ),
                    context.ui.spacing.gap(
                      compact ? AppSpacing.sm : AppSpacing.md,
                      axis: Axis.horizontal,
                    ),
                  ],
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        AppText(
                          titleKey,
                          type: AppTextType.labelMedium,
                          color: colors.onSurfaceVariant,
                          maxLines: compact ? 1 : 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (!compact) context.ui.spacing.gap(AppSpacing.xs),
                        AppText.raw(
                          shown,
                          type: compact
                              ? AppTextType.titleMedium
                              : AppTextType.amountKpi,
                          color: value == null
                              ? colors.onSurfaceVariant
                              : colors.onSurface,
                        ),
                        if (descriptionKey != null && !compact) ...[
                          context.ui.spacing.gap(AppSpacing.xs),
                          AppText(
                            descriptionKey!,
                            type: AppTextType.bodySmall,
                            color: colors.onSurfaceVariant,
                            maxLines: 2,
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _loading(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    mainAxisSize: MainAxisSize.min,
    children: [
      const AppSkeleton.line(),
      context.ui.spacing.gap(AppSpacing.sm),
      const AppSkeleton.line(),
    ],
  );
}

class _IconBadge extends StatelessWidget {
  const _IconBadge({
    required this.icon,
    required this.foreground,
    required this.background,
  });

  final AppIconData icon;
  final Color foreground;
  final Color background;

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(
      color: background,
      borderRadius: AppSurfaceShape.pill.circular(context),
    ),
    child: SizedBox.square(
      dimension: context.ui.size.width(AppComponentSize.small),
      child: Center(
        child: AppIcon(icon, size: AppIconSize.md, color: foreground),
      ),
    ),
  );
}
