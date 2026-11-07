import 'package:accounting_software/app/core/presentation/design_system/responsive/extension/ui_extension.dart';
import 'package:accounting_software/app/core/presentation/design_system/theme/app_theme.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_card/app_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> _pump(WidgetTester tester, Widget child) {
  tester.view.physicalSize = const Size(390, 844);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  return tester.pumpWidget(
    MaterialApp(theme: AppTheme.light(), home: Scaffold(body: child)),
  );
}

void main() {
  group('AppCard', () {
    testWidgets('draws its border from the thin border-width token', (
      tester,
    ) async {
      await _pump(tester, const AppCard(child: Text('x')));

      final material = tester.widget<Material>(
        find.descendant(
          of: find.byType(AppCard),
          matching: find.byType(Material),
        ),
      );
      final shape = material.shape! as RoundedRectangleBorder;
      expect(shape.side.width, AppBorderWidth.thin.mobile);
    });

    testWidgets('is tappable only when onTap is given', (tester) async {
      await _pump(tester, const AppCard(child: Text('x')));
      expect(find.byType(InkWell), findsNothing);

      var taps = 0;
      await _pump(tester, AppCard(onTap: () => taps++, child: const Text('x')));
      await tester.tap(find.byType(AppCard));
      expect(taps, 1);
    });
  });
}
