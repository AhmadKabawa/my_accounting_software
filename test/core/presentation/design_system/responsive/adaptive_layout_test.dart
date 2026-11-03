import 'package:accounting_software/app/core/presentation/design_system/responsive/engine/adaptive_layout.dart';
import 'package:accounting_software/app/core/presentation/design_system/responsive/engine/app_enums.dart';
import 'package:accounting_software/app/core/presentation/design_system/responsive/engine/screen_engine.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Future<Map<String, int>> _pump(
  WidgetTester tester, {
  required Size screen,
  double? width,
  bool tablet = true,
  bool desktop = true,
}) async {
  tester.view.physicalSize = screen;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);

  final built = <String, int>{};
  WidgetBuilder probe(String name) => (_) {
    built[name] = (built[name] ?? 0) + 1;
    return Text(name, textDirection: TextDirection.ltr);
  };

  Widget layout = AdaptiveLayout(
    mobile: probe('mobile'),
    tablet: tablet ? probe('tablet') : null,
    desktop: desktop ? probe('desktop') : null,
  );
  // Align gives the child loose constraints, so the SizedBox width wins.
  if (width != null) layout = Align(child: SizedBox(width: width, child: layout));

  await tester.pumpWidget(MediaQuery(data: MediaQueryData(size: screen), child: layout));
  return built;
}

void main() {
  const desktopScreen = Size(1400, 900);

  group('decides by the constraints, not by the screen', () {
    testWidgets('full width on a desktop screen → desktop', (tester) async {
      final built = await _pump(tester, screen: desktopScreen);

      expect(built, {'desktop': 1});
    });

    testWidgets('narrow box on a desktop screen → mobile', (tester) async {
      final built = await _pump(tester, screen: desktopScreen, width: 400);

      expect(built, {'mobile': 1});
    });

    testWidgets('medium box on a desktop screen → tablet', (tester) async {
      final built = await _pump(tester, screen: desktopScreen, width: 800);

      expect(built, {'tablet': 1});
    });

    testWidgets('wide box on a phone screen → desktop', (tester) async {
      final built = await _pump(
        tester,
        screen: const Size(390, 844),
        width: 1300,
      );

      expect(built, {'desktop': 1});
    });
  });

  group('fallback chain', () {
    testWidgets('tablet falls back to mobile', (tester) async {
      final built = await _pump(
        tester,
        screen: desktopScreen,
        width: 800,
        tablet: false,
        desktop: false,
      );

      expect(built, {'mobile': 1});
    });

    testWidgets('desktop falls back to tablet', (tester) async {
      final built = await _pump(tester, screen: desktopScreen, desktop: false);

      expect(built, {'tablet': 1});
    });
  });

  test('screenTypeForWidth applies the breakpoints', () {
    expect(ScreenEngine.screenTypeForWidth(599.9), ScreenType.mobile);
    expect(ScreenEngine.screenTypeForWidth(600), ScreenType.tablet);
    expect(ScreenEngine.screenTypeForWidth(1199.9), ScreenType.tablet);
    expect(ScreenEngine.screenTypeForWidth(1200), ScreenType.desktop);
  });
}
