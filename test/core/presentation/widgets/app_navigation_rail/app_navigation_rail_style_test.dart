import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:accounting_software/app/core/localization/keys/nav_keys.dart';
import 'package:accounting_software/app/core/presentation/design_system/theme/app_theme.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_navigation_bar/app_navigation_bar.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_navigation_rail/app_navigation_rail.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_navigation_rail/app_navigation_rail_style.dart';

Future<AppNavigationRailStyle> _styleAt(WidgetTester tester, Size size) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);

  late AppNavigationRailStyle styles;
  await tester.pumpWidget(
    MaterialApp(
      theme: AppTheme.light(),
      home: Builder(
        builder: (context) {
          styles = AppNavigationRailStyle(context);
          return const SizedBox();
        },
      ),
    ),
  );
  return styles;
}

const _items = [
  NavBarItem(
    icon: Icons.home_outlined,
    activeIcon: Icons.home,
    label: NavKeys.home,
  ),
  NavBarItem(
    icon: Icons.person_outline,
    activeIcon: Icons.person,
    label: NavKeys.person,
  ),
];

Future<void> _pumpRail(
  WidgetTester tester, {
  required int activeIndex,
  required ValueChanged<int> onIndexChanged,
  TextDirection direction = TextDirection.ltr,
}) async {
  tester.view.physicalSize = const Size(800, 1280);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    MaterialApp(
      theme: AppTheme.light(),
      builder: (context, child) =>
          Directionality(textDirection: direction, child: child!),
      home: Scaffold(
        body: Row(
          children: [
            AppNavigationRail(
              items: _items,
              activeIndex: activeIndex,
              onIndexChanged: onIndexChanged,
            ),
            const Expanded(child: SizedBox()),
          ],
        ),
      ),
    ),
  );
}

void main() {
  const tablet = Size(800, 1280);
  const desktop = Size(1440, 900);

  group('AppNavigationRailStyle', () {
    testWidgets('colors come from the theme', (tester) async {
      final styles = await _styleAt(tester, tablet);
      final scheme = AppTheme.light().colorScheme;

      expect(styles.background, scheme.surfaceContainer);
      expect(styles.selectedBackground, scheme.secondaryContainer);
      expect(styles.selectedForeground, scheme.onSecondaryContainer);
      expect(styles.foreground, scheme.onSurfaceVariant);
    });

    testWidgets('selected and unselected items resolve differently', (
      tester,
    ) async {
      final styles = await _styleAt(tester, tablet);

      expect(styles.itemBackground(selected: true), styles.selectedBackground);
      expect(styles.itemBackground(selected: false), Colors.transparent);
      expect(styles.itemForeground(selected: true), styles.selectedForeground);
      expect(styles.itemForeground(selected: false), styles.foreground);
    });

    testWidgets('width is the item width plus the horizontal padding', (
      tester,
    ) async {
      final styles = await _styleAt(tester, tablet);

      expect(styles.width, styles.itemWidth + styles.padding.horizontal);
    });

    testWidgets('sizes are responsive tokens, not fixed values', (
      tester,
    ) async {
      final onTablet = await _styleAt(tester, tablet);
      final tabletWidth = onTablet.width;
      final onDesktop = await _styleAt(tester, desktop);

      expect(onDesktop.width, greaterThanOrEqualTo(tabletWidth));
    });

    testWidgets('the border is on the end side', (tester) async {
      final styles = await _styleAt(tester, tablet);

      expect(styles.border.end.style, BorderStyle.solid);
      expect(styles.border.start, BorderSide.none);
    });
  });

  group('AppNavigationRail', () {
    testWidgets('shows the active icon only for the selected item', (
      tester,
    ) async {
      await _pumpRail(tester, activeIndex: 1, onIndexChanged: (_) {});

      expect(find.byIcon(Icons.home_outlined), findsOneWidget);
      expect(find.byIcon(Icons.home), findsNothing);
      expect(find.byIcon(Icons.person), findsOneWidget);
      expect(find.byIcon(Icons.person_outline), findsNothing);
    });

    testWidgets('tapping an item reports its index', (tester) async {
      final taps = <int>[];
      await _pumpRail(tester, activeIndex: 0, onIndexChanged: taps.add);

      await tester.tap(find.byIcon(Icons.person_outline));

      expect(taps, [1]);
    });

    testWidgets('sits on the start side in LTR and RTL', (tester) async {
      await _pumpRail(
        tester,
        activeIndex: 0,
        onIndexChanged: (_) {},
        direction: TextDirection.rtl,
      );

      final rail = tester.getRect(find.byType(AppNavigationRail));
      expect(rail.right, 800);
    });
  });
}
