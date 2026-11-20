import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:accounting_software/app/core/presentation/design_system/theme/app_theme.dart';

import 'localized_app.dart';

/// Pumps a screen using the same responsive matrix dimensions and themes
/// required by the UI remediation quality gate.
///
/// Call once per matrix case (width × direction × brightness) from a
/// `testWidgets` loop. The helper also fails immediately on framework
/// exceptions produced during the first settled frame.
Future<void> pumpScreenMatrix(
  WidgetTester tester, {
  required Widget home,
  required double width,
  required TextDirection direction,
  required bool dark,
  double height = 900,
  double textScale = 1,
}) async {
  setScreenSize(tester, Size(width, height));
  await tester.pumpWidget(
    buildTestApp(
      direction: direction,
      theme: dark ? AppTheme.dark() : AppTheme.light(),
      textScale: textScale,
      home: home,
    ),
  );
  await tester.pumpAndSettle();
  expect(
    tester.takeException(),
    isNull,
    reason: 'Screen threw at width=$width, direction=$direction, dark=$dark',
  );
}
