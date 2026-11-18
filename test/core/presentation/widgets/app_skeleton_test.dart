import 'package:accounting_software/app/core/presentation/design_system/theme/app_theme.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_skeleton/app_skeleton.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Future<void> pumpSkeleton(
    WidgetTester tester,
    Widget skeleton, {
    bool reduceMotion = false,
  }) {
    return tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        home: MediaQuery(
          data: MediaQueryData(disableAnimations: reduceMotion),
          child: Scaffold(body: Center(child: skeleton)),
        ),
      ),
    );
  }

  group('AppSkeleton', () {
    testWidgets('delays the placeholder to avoid a loading flash', (
      tester,
    ) async {
      await pumpSkeleton(tester, const AppSkeleton.line());
      final sizeBeforeReveal = tester.getSize(find.byType(AppSkeleton));

      expect(
        find.descendant(
          of: find.byType(AppSkeleton),
          matching: find.byType(DecoratedBox),
        ),
        findsNothing,
      );

      await tester.pump(const Duration(milliseconds: 200));

      expect(tester.getSize(find.byType(AppSkeleton)), sizeBeforeReveal);
      expect(
        find.descendant(
          of: find.byType(AppSkeleton),
          matching: find.byType(DecoratedBox),
        ),
        findsOneWidget,
      );
    });

    testWidgets('shows immediately when reduced motion is requested', (
      tester,
    ) async {
      await pumpSkeleton(tester, const AppSkeleton.line(), reduceMotion: true);

      expect(
        find.descendant(
          of: find.byType(AppSkeleton),
          matching: find.byType(DecoratedBox),
        ),
        findsOneWidget,
      );
    });

    testWidgets('supports line, block, card, and table-row variants', (
      tester,
    ) async {
      final variants = <Widget>[
        const AppSkeleton.line(),
        const AppSkeleton.block(),
        const AppSkeleton.card(),
        const AppSkeleton.tableRow(columns: 3),
      ];

      for (final variant in variants) {
        await pumpSkeleton(tester, variant, reduceMotion: true);
        expect(tester.takeException(), isNull);
        expect(find.byType(AppSkeleton), findsOneWidget);
      }
    });
  });
}
