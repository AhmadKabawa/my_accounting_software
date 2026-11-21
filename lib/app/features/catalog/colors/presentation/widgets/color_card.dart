import 'package:flutter/material.dart';
import 'package:accounting_software/app/core/localization/translations/app_key.dart';
import 'package:accounting_software/app/core/presentation/design_system/responsive/extension/ui_extension.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_text/app_text.dart';
import 'package:accounting_software/app/features/catalog/colors/domain/entity/catalog_color.dart';
import 'package:accounting_software/app/features/catalog/colors/presentation/localization/colors_keys.dart';
import 'package:accounting_software/app/features/catalog/colors/presentation/widgets/color_identity.dart';
import 'package:accounting_software/app/features/catalog/colors/presentation/widgets/color_status_badge.dart';

/// Mobile card body for one color (the table's card mode).
class ColorCard extends StatelessWidget {
  const ColorCard(this.color, {super.key});
  final CatalogColor color;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      ColorIdentity(color),
      context.ui.spacing.gap(AppSpacing.sm),
      AppText.raw(
        ColorsKeys.codeLabel.tr(
          context: context,
          namedArgs: {'code': color.code},
        ),
        type: AppTextType.bodySmall,
        color: context.ui.theme.colors.onSurfaceVariant,
      ),
      context.ui.spacing.gap(AppSpacing.sm),
      ColorStatusBadge(color),
    ],
  );
}
