import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:accounting_software/app/core/localization/keys/nav_keys.dart';
import 'package:accounting_software/app/core/presentation/design_system/theme/app_theme.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_navigation_bar/app_navigation_bar.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_sidebar/app_sidebar.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_sidebar/app_sidebar_style.dart';

Future<AppSidebarStyle> _styleAt(WidgetTester tester, Size size) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);

  late AppSidebarStyle styles;
  await tester.pumpWidget(
    MaterialApp(
      theme: AppTheme.light(),
      home: Builder(
        builder: (context) {
          styles = AppSidebarStyle(context);
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

Future<void> _pumpSidebar(
  WidgetTester tester, {
  required int activeIndex,
  required ValueChanged<int> onIndexChanged,
  TextDirection direction = TextDirection.ltr,
}) async {
  tester.view.physicalSize = const Size(1400, 900);
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
            AppSidebar(
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
  const desktop = Size(1440, 900);

  group('AppSidebarStyle', () {
    testWidgets('colors come from the theme', (tester) async {
      final styles = await _styleAt(tester, desktop);
      final scheme = AppTheme.light().colorScheme;

      expect(styles.background, scheme.surfaceContainer);
      expect(styles.selectedBackground, scheme.secondaryContainer);
      expect(styles.selectedForeground, scheme.onSecondaryContainer);
      expect(styles.foreground, scheme.onSurfaceVariant);
    });

    testWidgets('selected and unselected items resolve differently', (
      tester,
    ) async {
      final styles = await _styleAt(tester, desktop);

      expect(styles.itemBackground(selected: true), styles.selectedBackground);
      expect(styles.itemBackground(selected: false), Colors.transparent);
      expect(styles.itemForeground(selected: true), styles.selectedForeground);
      expect(styles.itemForeground(selected: false), styles.foreground);
    });

    testWidgets('uses the desktop value of the width token on desktop', (
      tester,
    ) async {
      final styles = await _styleAt(tester, desktop);

      expect(styles.width, 272);
    });

    testWidgets('item padding is directional and the border on the end', (
      tester,
    ) async {
      final styles = await _styleAt(tester, desktop);

      expect(styles.itemPadding, isA<EdgeInsetsDirectional>());
      expect(styles.border.end.style, BorderStyle.solid);
      expect(styles.border.start, BorderSide.none);
    });
  });

  group('AppSidebar', () {
    testWidgets('shows icon and label for every item', (tester) async {
      await _pumpSidebar(tester, activeIndex: 0, onIndexChanged: (_) {});

      expect(find.byIcon(Icons.home), findsOneWidget);
      expect(find.byIcon(Icons.person_outline), findsOneWidget);
      expect(find.byType(Text), findsNWidgets(_items.length));
    });

    testWidgets('tapping an item reports its index', (tester) async {
      final taps = <int>[];
      await _pumpSidebar(tester, activeIndex: 0, onIndexChanged: taps.add);

      await tester.tap(find.byIcon(Icons.person_outline));

      expect(taps, [1]);
    });

    testWidgets('sits on the start side in RTL', (tester) async {
      await _pumpSidebar(
        tester,
        activeIndex: 0,
        onIndexChanged: (_) {},
        direction: TextDirection.rtl,
      );

      final sidebar = tester.getRect(find.byType(AppSidebar));
      expect(sidebar.right, 1400);
    });
  });
}
