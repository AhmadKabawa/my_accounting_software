import 'package:flutter/material.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_badge/app_badge.dart';
import 'package:accounting_software/app/features/catalog/brands/domain/entity/brand.dart';
import 'package:accounting_software/app/features/catalog/brands/presentation/localization/brands_keys.dart';

class BrandStatusBadge extends StatelessWidget {
  const BrandStatusBadge(this.brand, {super.key});
  final Brand brand;

  @override
  Widget build(BuildContext context) => AppBadge(
    label: brand.isActive ? BrandsKeys.active : BrandsKeys.inactive,
    tone: brand.isActive ? AppBadgeTone.success : AppBadgeTone.neutral,
    size: AppBadgeSize.small,
  );
}

/// "Products: 3", or "Products: n/a" when the count is unknown.
class BrandProductsBadge extends StatelessWidget {
  const BrandProductsBadge(this.brand, {super.key});
  final Brand brand;

  @override
  Widget build(BuildContext context) {
    final count = brand.productCount;
    return AppBadge(
      label: count == null ? BrandsKeys.productsUnknown : BrandsKeys.productsLabel,
      labelArgs: count == null ? null : {'count': count.toString()},
      tone: AppBadgeTone.neutral,
      size: AppBadgeSize.small,
    );
  }
}
