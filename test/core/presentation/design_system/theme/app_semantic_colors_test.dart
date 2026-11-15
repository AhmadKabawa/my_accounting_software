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

    test('copyWith keeps the new roles and replaces them on request', () {
      const status = StatusColor(
        foreground: Colors.black,
        container: Colors.white,
      );
      final copy = AppSemanticColors.light.copyWith(
        balanceNegative: Colors.purple,
        statusPosted: status,
        chart: const [Colors.red],
        focusRing: Colors.orange,
      );

      expect(copy.balanceNegative, Colors.purple);
      expect(copy.statusPosted, status);
      expect(copy.chart, const [Colors.red]);
      expect(copy.focusRing, Colors.orange);
      expect(copy.statusDraft, AppSemanticColors.light.statusDraft);
      expect(copy.successContainer, AppSemanticColors.light.successContainer);
      expect(copy.onSurfaceMuted, AppSemanticColors.light.onSurfaceMuted);
    });

    test('lerp interpolates status pairs and chart series', () {
      final start = AppSemanticColors.light;
      final end = AppSemanticColors.dark;

      final mid = start.lerp(end, 0.5);

      expect(
        mid.statusPosted.foreground,
        Color.lerp(
          start.statusPosted.foreground,
          end.statusPosted.foreground,
          0.5,
        ),
      );
      expect(
        mid.statusPosted.container,
        Color.lerp(
          start.statusPosted.container,
          end.statusPosted.container,
          0.5,
        ),
      );
      expect(mid.chart, hasLength(8));
      expect(mid.chart.first, Color.lerp(start.chart.first, end.chart.first, 0.5));
      expect(start.lerp(end, 0).focusRing, start.focusRing);
      expect(start.lerp(end, 1).focusRing, end.focusRing);
    });

    test('chartColor cycles through the 8 series', () {
      final semantic = AppSemanticColors.light;

      expect(semantic.chartColor(0), semantic.chart[0]);
      expect(semantic.chartColor(7), semantic.chart[7]);
      expect(semantic.chartColor(8), semantic.chart[0]);
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
      expect(
        AppSemanticColors.light.success,
        isNot(AppSemanticColors.dark.success),
      );
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
