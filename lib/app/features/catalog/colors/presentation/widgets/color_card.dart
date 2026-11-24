import 'package:flutter/material.dart';
import 'package:accounting_software/app/core/presentation/design_system/responsive/extension/ui_extension.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_text/app_text.dart';
import 'package:accounting_software/app/features/catalog/colors/domain/entity/catalog_color.dart';
import 'color_identity.dart';
import 'color_status_badge.dart';

/// Card-mode presentation for one catalog color.
class ColorCard extends StatelessWidget {
  const ColorCard(this.color, {super.key});

  final CatalogColor color;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      ColorIdentity(color, size: AppIconSize.lg),
      context.ui.spacing.gap(AppSpacing.xs),
      AppText.raw(color.code, type: AppTextType.bodySmall),
      if (color.hexCode != null) ...[
        context.ui.spacing.gap(AppSpacing.xs),
        Directionality(
          textDirection: TextDirection.ltr,
          child: AppText.raw(color.hexCode ?? '', type: AppTextType.bodySmall),
        ),
      ],
      context.ui.spacing.gap(AppSpacing.sm),
      ColorStatusBadge(color),
    ],
  );
}
