import 'package:flutter/material.dart';
import 'package:accounting_software/app/core/presentation/design_system/responsive/extension/ui_extension.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_text/app_text.dart';
import 'package:accounting_software/app/features/catalog/brands/domain/entity/brand.dart';
import 'brand_logo.dart';
import 'brand_status_badge.dart';

/// Grid tile for one brand: logo, name, product count and status.
class BrandGridTile extends StatelessWidget {
  const BrandGridTile(this.brand, {super.key});
  final Brand brand;

  @override
  Widget build(BuildContext context) => Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      BrandLogo(brand),
      context.ui.spacing.gap(AppSpacing.sm),
      AppText.raw(
        brand.name,
        type: AppTextType.titleSmall,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        textAlign: TextAlign.center,
      ),
      context.ui.spacing.gap(AppSpacing.sm),
      Wrap(
        alignment: WrapAlignment.center,
        spacing: context.ui.spacing.xs,
        runSpacing: context.ui.spacing.xs,
        children: [BrandProductsBadge(brand), BrandStatusBadge(brand)],
      ),
    ],
  );
}
