import 'package:flutter/material.dart';
import 'package:accounting_software/app/core/presentation/design_system/responsive/extension/ui_extension.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_text/app_text.dart';
import 'package:accounting_software/app/features/catalog/domain/entity/brand.dart';
import 'brand_logo.dart';
import 'brand_status_badge.dart';

/// Mobile card body for one brand (the table's card mode).
class BrandCard extends StatelessWidget {
  const BrandCard(this.brand, {super.key});
  final Brand brand;

  @override
  Widget build(BuildContext context) {
    final description = brand.description?.trim() ?? '';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        BrandIdentity(brand),
        if (description.isNotEmpty) ...[
          context.ui.spacing.gap(AppSpacing.sm),
          AppText.raw(
            description,
            type: AppTextType.bodySmall,
            color: context.ui.theme.colors.onSurfaceVariant,
            maxLines: 2,
          ),
        ],
        context.ui.spacing.gap(AppSpacing.sm),
        Wrap(
          spacing: context.ui.spacing.sm,
          runSpacing: context.ui.spacing.sm,
          children: [BrandStatusBadge(brand), BrandProductsBadge(brand)],
        ),
      ],
    );
  }
}
