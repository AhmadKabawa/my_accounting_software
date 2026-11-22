import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:accounting_software/app/core/presentation/design_system/theme/app_theme.dart';
import 'package:accounting_software/app/core/presentation/design_system/responsive/extension/ui_extension.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_icon/app_icon.dart';
import '../../../helpers/localized_app.dart';

void main() {
  setUpAll(() => useTranslations(const Locale('en')));

  testWidgets('each tone resolves to its documented semantic theme role', (
    tester,
  ) async {
    for (final theme in [AppTheme.light(), AppTheme.dark()]) {
      for (final tone in AppIconTone.values) {
        Color? toneExpected;
        await tester.pumpWidget(
          buildTestApp(
            theme: theme,
            home: Builder(
              builder: (context) {
                final colors = context.ui.theme.colors;
                final semantic = context.ui.theme.semanticColors;
                toneExpected = switch (tone) {
                  AppIconTone.neutral => colors.onSurface,
                  AppIconTone.primary => colors.primary,
                  AppIconTone.success => semantic.success,
                  AppIconTone.warning => semantic.warning,
                  AppIconTone.info => semantic.info,
                  AppIconTone.danger => colors.error,
                };
                return Scaffold(body: AppIcon(AppIcons.add, tone: tone));
              },
            ),
          ),
        );
        final icon = tester.widget<Icon>(find.byType(Icon).first);
        expect(icon.color, toneExpected, reason: tone.name);
      }
    }
  });
}
