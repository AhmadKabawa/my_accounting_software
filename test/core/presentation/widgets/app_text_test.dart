import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:accounting_software/app/core/presentation/design_system/responsive/extension/ui_extension.dart';
import 'package:accounting_software/app/core/presentation/design_system/theme/app_theme.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_text/app_text.dart';

/// Pumps an [AppText] on a screen of [size] and returns the style it renders.
Future<TextStyle> _styleAt(
  WidgetTester tester,
  Size size, {
  ResponsiveMode? mode,
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    MaterialApp(
      theme: AppTheme.light(),
      home: Scaffold(body: AppText.raw('x', mode: mode)),
    ),
  );
  return tester.widget<Text>(find.text('x')).style!;
}

void main() {
  const desktop = Size(1440, 900);

  group('AppText', () {
    testWidgets('grows from phone to desktop by default', (tester) async {
      final phone = await _styleAt(tester, const Size(390, 844));
      final wide = await _styleAt(tester, desktop);

      expect(wide.fontSize, AppFontSize.base.desktop);
      expect(wide.fontSize, greaterThan(phone.fontSize!));
    });

    testWidgets('mode overrides the size on desktop', (tester) async {
      final adaptive = await _styleAt(tester, desktop);
      final fixed = await _styleAt(tester, desktop, mode: ResponsiveMode.fixed);

      expect(fixed.fontSize, AppFontSize.base.mobile);
      expect(adaptive.fontSize, isNot(fixed.fontSize));
    });

    testWidgets('keeps the type color and zero letter spacing', (tester) async {
      final style = await _styleAt(tester, desktop);

      expect(style.color, AppTheme.light().textTheme.bodyMedium!.color);
      expect(style.letterSpacing, 0);
    });
  });
}
