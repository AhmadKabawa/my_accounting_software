import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:accounting_software/app/core/presentation/design_system/theme/app_theme.dart';
import 'package:accounting_software/app/core/presentation/design_system/theme/extensions/app_semantic_colors.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_icon/app_icon.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_icon/app_icons.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_icon/app_icon_tone.dart';
import '../../../helpers/localized_app.dart';

void main() {
  setUpAll(() => useTranslations(const Locale('en')));

  testWidgets('each tone resolves to its documented semantic theme role', (
    tester,
  ) async {
    for (final theme in [AppTheme.light(), AppTheme.dark()]) {
      final semantic = theme.extension<AppSemanticColors>()!;
      for (final tone in AppIconTone.values) {
        await tester.pumpWidget(
          buildTestApp(
            theme: theme,
            home: Scaffold(body: AppIcon(AppIcons.add, tone: tone)),
          ),
        );
        final icon = tester.widget<Icon>(find.byType(Icon).first);
        final expected = switch (tone) {
          AppIconTone.neutral => theme.colorScheme.onSurface,
          AppIconTone.primary => theme.colorScheme.primary,
          AppIconTone.success => semantic.success,
          AppIconTone.warning => semantic.warning,
          AppIconTone.info => semantic.info,
          AppIconTone.danger => theme.colorScheme.error,
        };
        expect(icon.color, expected, reason: tone.name);
      }
    }
  });
}
