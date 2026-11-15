import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_navigation_bar/app_navigation_bar_style.dart';
import 'package:accounting_software/app/core/presentation/design_system/theme/app_theme.dart';

Future<AppNavigationBarStyle> _navbarAt(WidgetTester tester, Size size) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);

  late AppNavigationBarStyle styles;
  await tester.pumpWidget(
    MaterialApp(
      theme: AppTheme.light(),
      home: Builder(
        builder: (context) {
          styles = AppNavigationBarStyle(context);
          return const SizedBox();
        },
      ),
    ),
  );
  return styles;
}

void main() {
  const phone = Size(390, 844);
  const desktop = Size(1440, 900);

  test('only the minimal and pill styles exist (minimal is the default)', () {
    expect(NavBarStyle.values, [NavBarStyle.minimal, NavBarStyle.pill]);
  });

  group('AppNavigationBarStyle.variant on mobile', () {
    testWidgets('minimal is a flat surface with a hairline top border', (
      tester,
    ) async {
      final styles = await _navbarAt(tester, phone);
      final scheme = AppTheme.light().colorScheme;

      final v = styles.variant(NavBarStyle.minimal);

      expect(v.radius, BorderRadius.zero);
      expect(v.shadows, isEmpty);
      expect(v.gradient, isNull);
      expect(v.margin, EdgeInsets.zero);
      expect(v.background, scheme.surface);
      expect(v.border!.top.width, 1);
      expect(v.border!.top.color, scheme.outlineVariant);
    });

    testWidgets('minimal honours the background override', (tester) async {
      final styles = await _navbarAt(tester, phone);

      final v = styles.variant(
        NavBarStyle.minimal,
        backgroundColor: Colors.purple,
      );

      expect(v.background, Colors.purple);
    });

    testWidgets('pill has a gradient and a glow, and no border', (
      tester,
    ) async {
      final styles = await _navbarAt(tester, phone);

      final v = styles.variant(NavBarStyle.pill);

      expect(v.gradient, isNotNull);
      expect(v.border, isNull);
      expect(v.shadows.single.blurRadius, 15);
      expect(v.shadows.single.offset, const Offset(0, 8));
    });

    testWidgets('pill honours the radius override', (tester) async {
      final styles = await _navbarAt(tester, phone);

      final v = styles.variant(NavBarStyle.pill, borderRadius: 7);

      expect(v.radius, BorderRadius.circular(7));
    });
  });

  group('moved values are not responsive', () {
    testWidgets('desktop keeps the same decorative values', (tester) async {
      final styles = await _navbarAt(tester, desktop);

      final pill = styles.variant(NavBarStyle.pill);

      expect(pill.shadows.single.blurRadius, 15);
      expect(styles.minGap, 4);
      expect(styles.maxGap, 12);
    });
  });

  group('item geometry', () {
    testWidgets('inset is 15% of the height and the icon fills the rest', (
      tester,
    ) async {
      final styles = await _navbarAt(tester, phone);

      expect(styles.itemInset(40), closeTo(6, 1e-9));
      expect(styles.itemIconSize(40), closeTo(22, 1e-9));
      expect(styles.itemRadius(40), BorderRadius.circular(20));
    });

    testWidgets('the active item is twice an inactive one', (tester) async {
      final styles = await _navbarAt(tester, phone);

      expect(styles.defaultActiveItemWidth, styles.defaultMaxItemSize * 2);
    });
  });
}
