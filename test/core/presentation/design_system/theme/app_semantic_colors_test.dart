import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:accounting_software/app/core/presentation/design_system/responsive/extension/ui_extension.dart';
import 'package:accounting_software/app/core/presentation/design_system/theme/app_theme.dart';
import 'package:accounting_software/app/core/presentation/design_system/theme/extensions/app_semantic_colors.dart';
import 'package:accounting_software/app/core/presentation/design_system/theme/extensions/theme_mode_extension.dart';
import 'package:accounting_software/app/core/localization/keys/theme_keys.dart';

void main() {
  group('AppSemanticColors', () {
    test('copyWith replaces only the given colors', () {
      final copy = AppSemanticColors.light.copyWith(success: Colors.purple);

      expect(copy.success, Colors.purple);
      expect(copy.warning, AppSemanticColors.light.warning);
      expect(copy.debit, AppSemanticColors.light.debit);
    });

    test('lerp interpolates and returns this for a foreign type', () {
      final mid = AppSemanticColors.light.lerp(AppSemanticColors.dark, 0.5);

      expect(
        mid.success,
        Color.lerp(
          AppSemanticColors.light.success,
          AppSemanticColors.dark.success,
          0.5,
        ),
      );
      expect(AppSemanticColors.light.lerp(null, 0.5), AppSemanticColors.light);
      expect(
        AppSemanticColors.light.lerp(AppSemanticColors.dark, 0).info,
        AppSemanticColors.light.info,
      );
      expect(
        AppSemanticColors.light.lerp(AppSemanticColors.dark, 1).info,
        AppSemanticColors.dark.info,
      );
    });

    test('both themes register the extension', () {
      expect(
        AppTheme.light().extension<AppSemanticColors>(),
        AppSemanticColors.light,
      );
      expect(
        AppTheme.dark().extension<AppSemanticColors>(),
        AppSemanticColors.dark,
      );
    });

    testWidgets('context.ui.theme.semanticColors follows the theme', (
      tester,
    ) async {
      AppSemanticColors? seen;

      Future<void> pump(ThemeData theme) => tester.pumpWidget(
        MaterialApp(
          theme: theme,
          home: Builder(
            builder: (context) {
              seen = context.ui.theme.semanticColors;
              return const SizedBox();
            },
          ),
        ),
      );

      await pump(AppTheme.light());
      expect(seen, AppSemanticColors.light);

      await pump(AppTheme.dark());
      expect(seen, AppSemanticColors.dark);
      expect(AppSemanticColors.light.success, isNot(AppSemanticColors.dark.success));
    });

    testWidgets('falls back to defaults when the theme has no extension', (
      tester,
    ) async {
      AppSemanticColors? seen;
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              seen = context.ui.theme.semanticColors;
              return const SizedBox();
            },
          ),
        ),
      );

      expect(seen, AppSemanticColors.light);
    });
  });

  test('ThemeModeExtension maps modes to translation keys', () {
    expect(ThemeMode.light.nameKey, ThemeKeys.light);
    expect(ThemeMode.dark.nameKey, ThemeKeys.dark);
    expect(ThemeMode.system.nameKey, ThemeKeys.system);
  });
}
