import 'package:accounting_software/app/core/presentation/design_system/theme/app_theme.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_count_badge/count_badge.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_count_badge/count_badge_style.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_text/app_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/localized_app.dart';
import '../../../../helpers/test_key.dart';

const _label = TestKey('test.badge.label');
const _anchorKey = Key('count-badge-anchor');

Future<void> _pump(
  WidgetTester tester,
  Widget child, {
  TextDirection direction = TextDirection.rtl,
  ThemeData? theme,
}) {
  setScreenSize(tester, const Size(360, 800));
  return tester.pumpWidget(
    buildTestApp(
      theme: theme,
      direction: direction,
      home: Scaffold(body: Center(child: child)),
    ),
  );
}

void main() {
  setUp(() => useTranslations(const Locale('ar')));

  group('CountBadgeStyle.label', () {
    test('shows the number up to 99 and 99+ above it', () {
      expect(CountBadgeStyle.label(1), '1');
      expect(CountBadgeStyle.label(99), '99');
      expect(CountBadgeStyle.label(100), '99+');
      expect(CountBadgeStyle.label(12345), '99+');
    });
  });

  group('CountBadge', () {
    testWidgets('zero and negative counts render nothing', (tester) async {
      for (final count in [0, -3]) {
        await _pump(tester, CountBadge(count: count));
        expect(find.byType(AppText), findsNothing, reason: 'count=$count');
      }
    });

    testWidgets('shows the number, capped at 99+', (tester) async {
      await _pump(tester, const CountBadge(count: 7));
      expect(find.text('7'), findsOneWidget);

      await _pump(tester, const CountBadge(count: 250));
      expect(find.text('99+'), findsOneWidget);
    });

    testWidgets('semantics keep the real count and the label', (tester) async {
      final handle = tester.ensureSemantics();
      await _pump(
        tester,
        const CountBadge(count: 250, semanticsLabelKey: _label),
      );

      final node = tester.getSemantics(find.byType(CountBadge));
      expect(node.value, '250');
      expect(node.label, 'test.badge.label');
      handle.dispose();
    });

    testWidgets('dot style has no number but keeps semantics', (tester) async {
      final handle = tester.ensureSemantics();
      await _pump(
        tester,
        const CountBadge.dot(count: 3, semanticsLabelKey: _label),
      );

      expect(find.byType(AppText), findsNothing);
      expect(tester.getSemantics(find.byType(CountBadge)).value, '3');
      handle.dispose();
    });

    testWidgets('dot style is hidden at zero', (tester) async {
      await _pump(tester, const CountBadge.dot(count: 0));
      expect(
        find.descendant(
          of: find.byType(CountBadge),
          matching: find.byType(DecoratedBox),
        ),
        findsNothing,
      );
    });

    testWidgets('colors come from the theme, in light and dark', (
      tester,
    ) async {
      for (final theme in [AppTheme.light(), AppTheme.dark()]) {
        await _pump(
          tester,
          const CountBadge(count: 4, variant: CountBadgeVariant.error),
          theme: theme,
        );
        // MaterialApp animates a theme change; read the colors after it.
        await tester.pumpAndSettle();

        final decoration =
            tester
                    .widget<DecoratedBox>(
                      find
                          .descendant(
                            of: find.byType(CountBadge),
                            matching: find.byType(DecoratedBox),
                          )
                          .first,
                    )
                    .decoration
                as BoxDecoration;
        expect(decoration.color, theme.colorScheme.error);

        final text = tester.widget<AppText>(find.byType(AppText));
        expect(text.color, theme.colorScheme.onError);
      }
    });
  });

  group('CountBadgeAnchor', () {
    Future<Offset> badgeCenter(
      WidgetTester tester,
      TextDirection direction,
    ) async {
      await _pump(
        tester,
        const CountBadgeAnchor(
          badge: CountBadge(count: 5),
          child: SizedBox(key: _anchorKey, width: 48, height: 48),
        ),
        direction: direction,
      );
      return tester.getCenter(find.byType(CountBadge));
    }

    testWidgets('topEnd flips sides between RTL and LTR', (tester) async {
      final rtl = await badgeCenter(tester, TextDirection.rtl);
      final anchorRtl = tester.getCenter(find.byKey(_anchorKey));
      final ltr = await badgeCenter(tester, TextDirection.ltr);
      final anchorLtr = tester.getCenter(find.byKey(_anchorKey));

      // End = left in RTL, right in LTR.
      expect(rtl.dx, lessThan(anchorRtl.dx));
      expect(ltr.dx, greaterThan(anchorLtr.dx));
    });
  });
}
