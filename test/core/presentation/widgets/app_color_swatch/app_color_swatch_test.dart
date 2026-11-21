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

Future<void> _pumpSwatch(WidgetTester tester, Widget swatch) async {
  await tester.pumpWidget(
    buildTestApp(home: Scaffold(body: Center(child: swatch))),
  );
}

Future<void> _pump(WidgetTester tester, String? hex) async {
  await _pumpSwatch(tester, AppColorSwatch(hex: hex));
}

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

  testWidgets('empty ring for a missing value', (tester) async {
    await _pump(tester, null);
    expect(_decoration(tester).color, isNull);
  });

  testWidgets('empty ring for an invalid value', (tester) async {
    await _pump(tester, 'not-a-color');
    expect(_decoration(tester).color, isNull);
  });

  testWidgets('always has an outline', (tester) async {
    await _pump(tester, '#FFFFFF');
    expect(_decoration(tester).border, isNotNull);
  });

  testWidgets('display swatch is hidden from screen readers', (tester) async {
    await _pump(tester, '#FF0000');
    final hidden = find.descendant(
      of: find.byType(AppColorSwatch),
      matching: find.byType(ExcludeSemantics),
    );
    expect(hidden, findsOneWidget);
  });

  testWidgets('a selectable swatch reports taps', (tester) async {
    var taps = 0;
    await _pumpSwatch(
      tester,
      AppColorSwatch(hex: '#FF0000', onTap: () => taps++, semanticLabel: 'Red'),
    );
    await tester.tap(find.byType(AppColorSwatch));
    expect(taps, 1);
  });

  testWidgets('selected swatch has a thicker ring', (tester) async {
    await _pump(tester, '#FF0000');
    final plain = (_decoration(tester).border! as Border).top.width;
    await _pumpSwatch(
      tester,
      AppColorSwatch(hex: '#FF0000', selected: true, onTap: () {}),
    );
    final chosen = (_decoration(tester).border! as Border).top.width;
    expect(chosen, greaterThan(plain));
  });
}
