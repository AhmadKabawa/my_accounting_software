import 'package:flutter/material.dart';
import 'package:accounting_software/app/core/localization/translations/app_key.dart';
import 'package:accounting_software/app/core/presentation/design_system/responsive/extension/ui_extension.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_badge/app_badge.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_confirm_dialog/confirm_dialog.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_text/app_text.dart';
import 'package:accounting_software/app/features/catalog/product_types/presentation/localization/product_types_keys.dart';

Future<void> confirmProductTypeLinkRemoval(
  BuildContext context,
  Future<void> Function() remove,
) async {
  final confirmed = await showConfirmDialog(
    context,
    titleKey: ProductTypesKeys.removeLink,
    messageKey: ProductTypesKeys.removeLinkConfirmation,
    severity: ConfirmDialogSeverity.warning,
    confirmLabelKey: ProductTypesKeys.removeLink,
  );
  if (confirmed) await remove();
}

class ProductTypeSectionTitle extends StatelessWidget {
  const ProductTypeSectionTitle(this.label, this.count);

  final AppKey label;
  final int count;

  @override
  Widget build(BuildContext context) => Padding(
    padding: context.ui.padding.only(bottom: AppSpacing.sm),
    child: Row(
      children: [
        Expanded(child: AppText(label, type: AppTextType.titleMedium)),
        AppBadge(
          label: label == ProductTypesKeys.sizeGroups
              ? ProductTypesKeys.sizeGroupsCount
              : label == ProductTypesKeys.attributes
              ? ProductTypesKeys.attributesCount
              : ProductTypesKeys.optionSetsCount,
          labelArgs: {'count': count.toString()},
          size: AppBadgeSize.small,
        ),
      ],
    ),
  );
}
