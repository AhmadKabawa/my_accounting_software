import 'package:flutter/material.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_badge/app_badge.dart';
import 'package:accounting_software/app/features/catalog/product_types/domain/entity/product_type.dart';
import 'package:accounting_software/app/features/catalog/product_types/presentation/localization/product_types_keys.dart';

class ProductTypeStatusBadge extends StatelessWidget {
  const ProductTypeStatusBadge(this.productType, {super.key});

  final ProductType productType;

  @override
  Widget build(BuildContext context) => AppBadge(
    label: productType.isActive
        ? ProductTypesKeys.active
        : ProductTypesKeys.inactive,
    tone: productType.isActive ? AppBadgeTone.success : AppBadgeTone.neutral,
    size: AppBadgeSize.small,
  );
}
