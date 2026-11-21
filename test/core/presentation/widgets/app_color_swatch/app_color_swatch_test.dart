import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_color_swatch/app_color_swatch.dart';

import '../../../../helpers/localized_app.dart';

BoxDecoration _decoration(WidgetTester tester) {
  final box = tester.widget<DecoratedBox>(
    find.descendant(
      of: find.byType(AppColorSwatch),
      matching: find.byType(DecoratedBox),
    ),
  );
  return box.decoration as BoxDecoration;
}

Future<void> _pump(WidgetTester tester, String? hex) => tester.pumpWidget(
  buildTestApp(home: Scaffold(body: Center(child: AppColorSwatch(hex: hex)))),
);

void main() {
  testWidgets('fills the circle with the parsed color', (tester) async {
    await _pump(tester, '#FF0000');
    final decoration = _decoration(tester);
    expect(decoration.shape, BoxShape.circle);
    expect(decoration.color, const Color(0xFFFF0000));
  });

  testWidgets('keeps the alpha channel', (tester) async {
    await _pump(tester, '#FF000080');
    expect(_decoration(tester).color, const Color(0x80FF0000));
  });

  testWidgets('shows an empty ring for a missing or invalid value', (
    tester,
  ) async {
    await _pump(tester, null);
    expect(_decoration(tester).color, isNull);
    await _pump(tester, 'not-a-color');
    expect(_decoration(tester).color, isNull);
  });

  testWidgets('always has a visible outline so light colors stay visible', (
    tester,
  ) async {
    await _pump(tester, '#FFFFFF');
    expect(_decoration(tester).border, isNotNull);
  });

  testWidgets('is hidden from screen readers (the name sits beside it)', (
    tester,
  ) async {
    await _pump(tester, '#FF0000');
    expect(
      find.descendant(
        of: find.byType(AppColorSwatch),
        matching: find.byType(ExcludeSemantics),
      ),
      findsOneWidget,
    );
  });
}
