import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_button/app_button.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_button/app_icon_button.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_text/app_text.dart';
import 'package:accounting_software/app/features/catalog/colors/domain/entity/catalog_color.dart';
import 'package:accounting_software/app/features/catalog/colors/presentation/localization/colors_keys.dart';

/// HEX value cell with the existing copy action and empty-value presentation.
class ColorHexCell extends StatelessWidget {
  const ColorHexCell(this.color, {super.key});

  final CatalogColor color;

  @override
  Widget build(BuildContext context) => color.hexCode == null
      ? AppText(ColorsKeys.noSampleLabel, type: AppTextType.bodySmall)
      : Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Expanded(
              child: Directionality(
                textDirection: TextDirection.ltr,
                child: AppText.raw(color.hexCode ?? ''),
              ),
            ),
            AppIconButton(
              AppIcons.copy,
              tooltipKey: ColorsKeys.copyHex,
              size: AppButtonSize.small,
              onPressed: () =>
                  Clipboard.setData(ClipboardData(text: color.hexCode ?? '')),
            ),
          ],
        );
}
