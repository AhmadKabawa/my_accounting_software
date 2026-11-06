import 'package:flutter/material.dart';
import 'package:accounting_software/app/core/localization/translations/app_key.dart';
import 'package:accounting_software/app/core/presentation/design_system/responsive/extension/ui_extension.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_text/app_text.dart';

/// A horizontal line, optionally with a centred translated label
/// ("or sign in with").
class AppDivider extends StatelessWidget {
  const AppDivider({super.key, this.labelKey});

  final AppKey? labelKey;

  @override
  Widget build(BuildContext context) {
    final color = context.ui.theme.colors.outlineVariant;
    final key = labelKey;
    if (key == null) return Divider(color: color);

    final line = Expanded(child: Divider(color: color));
    return Row(
      children: [
        line,
        Padding(
          padding: context.ui.padding.symmetric(horizontal: AppSpacing.md),
          child: AppText(key, type: AppTextType.labelMedium),
        ),
        line,
      ],
    );
  }
}
