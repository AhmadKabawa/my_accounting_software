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

BorderSide _side(NavbarVariant v) => (v.border! as Border).top;

void main() {
  const phone = Size(390, 844);
  const desktop = Size(1440, 900);

  // The values below are the literals app_navigation_bar.dart used before
  // they moved into AppNavigationBarStyle.
  group('AppNavigationBarStyle.variant on mobile', () {
    testWidgets('elegant', (tester) async {
      final v = (await _navbarAt(tester, phone)).variant(NavBarStyle.elegant);

      expect(v.padding, const EdgeInsets.all(8));
      expect(_side(v).width, 1);
      expect(v.shadows.single.blurRadius, 8);
      expect(v.shadows.single.offset, const Offset(0, 4));
      expect(v.blur, isNull);
    });

    testWidgets('elegant honours the elevation override', (tester) async {
      final styles = await _navbarAt(tester, phone);

      final v = styles.variant(NavBarStyle.elegant, elevation: 2);

      expect(v.shadows.single.blurRadius, 2);
    });

    testWidgets('glassmorphism blurs the backdrop', (tester) async {
      final v = (await _navbarAt(
        tester,
        phone,
      )).variant(NavBarStyle.glassmorphism);

      expect(v.blur, 10);
      expect(_side(v).width, 1.5);
      expect(_side(v).color, Colors.white.withOpacity(0.3));
      expect(v.shadows.single.blurRadius, 10);
      expect(v.shadows.single.offset, const Offset(0, 5));
    });

    testWidgets('pill has a gradient, a glow and no blur', (tester) async {
      final v = (await _navbarAt(tester, phone)).variant(NavBarStyle.pill);

      expect(v.gradient, isNotNull);
      expect(v.blur, isNull);
      expect(v.shadows.single.blurRadius, 15);
      expect(v.shadows.single.offset, const Offset(0, 8));
    });

    testWidgets('minimal is a flat bar with a hairline top border', (
      tester,
    ) async {
      final v = (await _navbarAt(tester, phone)).variant(NavBarStyle.minimal);

      expect(v.radius, BorderRadius.zero);
      expect(v.shadows, isEmpty);
      expect(_side(v).width, 0.5);
      // transparent and without a gradient -> blurred, as before
      expect(v.blur, 10);
    });

    testWidgets('neon glows', (tester) async {
      final v = (await _navbarAt(tester, phone)).variant(NavBarStyle.neon);

      expect(_side(v).width, 1.5);
      expect(v.shadows.single.blurRadius, 16);
      expect(v.shadows.single.offset, const Offset(0, 4));
    });
  });

  group('moved values are not responsive', () {
    testWidgets('desktop keeps the same decorative values', (tester) async {
      final styles = await _navbarAt(tester, desktop);

      final elegant = styles.variant(NavBarStyle.elegant);
      final glass = styles.variant(NavBarStyle.glassmorphism);

      expect(elegant.padding, const EdgeInsets.all(8));
      expect(elegant.shadows.single.blurRadius, 8);
      expect(glass.blur, 10);
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
