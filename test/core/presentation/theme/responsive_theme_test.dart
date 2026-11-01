import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:accounting_software/app/core/presentation/responsive/helper/responsive_helper.dart';
import 'package:accounting_software/app/core/presentation/theme/app_theme.dart';
import 'package:accounting_software/app/core/presentation/theme/responsive_theme.dart';

/// Pumps a MaterialApp that uses [AppTheme] wrapped in [ResponsiveTheme] on a
/// screen of [size] and returns the theme a page under it sees.
Future<ThemeData> _themeAt(WidgetTester tester, Size size) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);

  late ThemeData theme;
  await tester.pumpWidget(
    MaterialApp(
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      builder: (context, child) => ResponsiveTheme(child: child!),
      home: Builder(
        builder: (context) {
          theme = Theme.of(context);
          return const SizedBox();
        },
      ),
    ),
  );
  return theme;
}

void main() {
  group('theme without a BuildContext', () {
    test('AppTheme builds with the mobile baseline sizes', () {
      final theme = AppTheme.light();

      expect(theme.textTheme.bodyMedium!.fontSize, AppFontSize.base.mobile);
      expect(theme.textTheme.bodyLarge!.fontSize, AppFontSize.md.mobile);
      expect(
        theme.navigationBarTheme.height,
        AppSpacing.xl.mobile,
      );
    });

    test('keeps letter spacing at 0 so Arabic letters stay joined', () {
      expect(AppTheme.dark().textTheme.bodyMedium!.letterSpacing, 0);
    });
  });

  group('ResponsiveTheme', () {
    testWidgets('phone uses (about) the mobile sizes', (tester) async {
      final theme = await _themeAt(tester, const Size(390, 844));

      expect(
        theme.textTheme.bodyMedium!.fontSize,
        closeTo(AppFontSize.base.mobile, 0.2),
      );
    });

    testWidgets('desktop uses the desktop sizes', (tester) async {
      final theme = await _themeAt(tester, const Size(1440, 900));

      expect(theme.textTheme.bodyMedium!.fontSize, AppFontSize.base.desktop);
    });

    testWidgets('component themes follow the responsive text theme', (
      tester,
    ) async {
      final theme = await _themeAt(tester, const Size(1440, 900));

      expect(
        theme.appBarTheme.titleTextStyle!.fontSize,
        theme.textTheme.titleMedium!.fontSize,
      );
    });

    testWidgets('sizes grow from phone to desktop', (tester) async {
      final phone = await _themeAt(tester, const Size(390, 844));
      final desktop = await _themeAt(tester, const Size(1440, 900));

      expect(
        desktop.textTheme.bodyMedium!.fontSize,
        greaterThan(phone.textTheme.bodyMedium!.fontSize!),
      );
    });
  });
}
