import 'package:flutter/material.dart';
import 'package:accounting_software/app/core/localization/translations/app_key.dart';
import 'package:accounting_software/app/core/presentation/design_system/responsive/extension/ui_extension.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_text/app_text.dart';

/// A line with a centred label ("or sign in with").
class AuthDivider extends StatelessWidget {
  const AuthDivider({super.key, required this.textKey});

  final AppKey textKey;

  @override
  Widget build(BuildContext context) {
    final line = Expanded(
      child: Divider(color: context.ui.theme.colors.outlineVariant),
    );
    return Row(
      children: [
        line,
        Padding(
          padding: context.ui.padding.horizontal(AppSpacing.md),
          child: AppText(textKey, type: AppTextType.labelMedium),
        ),
        line,
      ],
    );
  }
}
