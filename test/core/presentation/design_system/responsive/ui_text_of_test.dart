import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:accounting_software/app/core/presentation/design_system/responsive/extension/ui_extension.dart';
import 'package:accounting_software/app/core/presentation/design_system/theme/app_text_styles.dart';
import 'package:accounting_software/app/core/presentation/design_system/theme/app_theme.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_text/app_text.dart';

void main() {
  testWidgets('context.ui.text.of resolves a text role responsively', (
    tester,
  ) async {
    late TextStyle viaUi;
    late TextStyle direct;
    late Color? themeColor;

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        home: Builder(
          builder: (context) {
            viaUi = context.ui.text.of(AppTextType.bodyMedium);
            direct = AppTextStyles.bodyMedium.resolve(context);
            themeColor = Theme.of(context).textTheme.bodyMedium?.color;
            return const SizedBox();
          },
        ),
      ),
    );

    expect(viaUi.fontSize, direct.fontSize);
    expect(viaUi.fontWeight, direct.fontWeight);
    expect(viaUi.color, themeColor);
    // Arabic letters stay joined only with zero letter spacing.
    expect(viaUi.letterSpacing, 0);
  });

  testWidgets('a role without a theme color leaves the color to the caller', (
    tester,
  ) async {
    late TextStyle style;
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        home: Builder(
          builder: (context) {
            style = context.ui.text.of(AppTextType.buttonText);
            return const SizedBox();
          },
        ),
      ),
    );

    expect(style.color, isNull);
  });
}
