import 'package:flutter/material.dart';
import 'package:accounting_software/app/core/presentation/design_system/responsive/extension/ui_extension.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_text/app_text.dart';
import 'package:accounting_software/app/features/catalog/product_types/domain/entity/product_type.dart';
import 'package:accounting_software/app/features/catalog/product_types/presentation/localization/product_types_keys.dart';
import 'package:accounting_software/app/features/catalog/product_types/presentation/widgets/product_type_status_badge.dart';

class ProductTypeCard extends StatelessWidget {
  const ProductTypeCard(this.productType, {super.key});

  final ProductType productType;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      AppText.raw(productType.name, type: AppTextType.titleMedium),
      context.ui.spacing.gap(AppSpacing.xs),
      Directionality(
        textDirection: TextDirection.ltr,
        child: Align(
          alignment: AlignmentDirectional.centerStart,
          child: AppText.raw(
            productType.code,
            type: AppTextType.labelMedium,
            color: context.ui.theme.colors.onSurfaceVariant,
          ),
        ),
      ),
      if ((productType.description ?? '').trim().isNotEmpty) ...[
        context.ui.spacing.gap(AppSpacing.sm),
        AppText.raw(
          productType.description!.trim(),
          type: AppTextType.bodySmall,
          color: context.ui.theme.colors.onSurfaceVariant,
          maxLines: 2,
        ),
      ],
      context.ui.spacing.gap(AppSpacing.sm),
      Wrap(
        spacing: context.ui.spacing.sm,
        runSpacing: context.ui.spacing.sm,
        children: [
          ProductTypeStatusBadge(productType),
          AppText.raw(
            productType.productCount?.toString() ?? '—',
            type: AppTextType.bodySmall,
          ),
          const AppText(ProductTypesKeys.products),
        ],
      ),
    ],
  );
}
