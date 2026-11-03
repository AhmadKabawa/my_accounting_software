import 'package:accounting_software/app/core/presentation/design_system/responsive/helper/responsive_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Builds a screen of [size] with an [Rh.builder] whose builders count how
/// many times each one ran. A null builder is not passed.
class _Probe {
  final built = <String, int>{};

  WidgetBuilder builder(String name) => (_) {
    built[name] = (built[name] ?? 0) + 1;
    return Text(name, textDirection: TextDirection.ltr);
  };
}

Future<_Probe> _pump(
  WidgetTester tester,
  Size size, {
  bool tablet = true,
  bool tabletLandscape = false,
  bool desktop = true,
  bool mobileLandscape = false,
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);

  final probe = _Probe();
  await tester.pumpWidget(
    MediaQuery(
      data: MediaQueryData(size: size),
      child: Builder(
        builder: (context) => Rh.builder(
          context: context,
          mobile: probe.builder('mobile'),
          mobileLandscape: mobileLandscape
              ? probe.builder('mobileLandscape')
              : null,
          tablet: tablet ? probe.builder('tablet') : null,
          tabletLandscape: tabletLandscape
              ? probe.builder('tabletLandscape')
              : null,
          desktop: desktop ? probe.builder('desktop') : null,
        ),
      ),
    ),
  );
  return probe;
}

void main() {
  const phone = Size(390, 844);
  const tablet = Size(800, 1280);
  const desktop = Size(1400, 900);

  group('Rh.builder builds only the chosen builder', () {
    testWidgets('phone → mobile', (tester) async {
      final probe = await _pump(tester, phone);

      expect(find.text('mobile'), findsOneWidget);
      expect(probe.built, {'mobile': 1});
    });

    testWidgets('tablet → tablet', (tester) async {
      final probe = await _pump(tester, tablet);

      expect(find.text('tablet'), findsOneWidget);
      expect(probe.built, {'tablet': 1});
    });

    testWidgets('desktop → desktop', (tester) async {
      final probe = await _pump(tester, desktop);

      expect(find.text('desktop'), findsOneWidget);
      expect(probe.built, {'desktop': 1});
    });
  });

  group('fallback chain', () {
    testWidgets('tablet falls back to mobile', (tester) async {
      final probe = await _pump(tester, tablet, tablet: false, desktop: false);

      expect(probe.built, {'mobile': 1});
    });

    testWidgets('desktop falls back to tablet', (tester) async {
      final probe = await _pump(tester, desktop, desktop: false);

      expect(probe.built, {'tablet': 1});
    });

    testWidgets('desktop falls back to mobile when it is the only one', (
      tester,
    ) async {
      final probe = await _pump(tester, desktop, tablet: false, desktop: false);

      expect(probe.built, {'mobile': 1});
    });
  });

  group('landscape', () {
    testWidgets('phone landscape (844×390) stays mobile', (tester) async {
      final probe = await _pump(tester, const Size(844, 390));

      expect(probe.built, {'mobile': 1});
    });

    testWidgets('phone landscape uses mobileLandscape when given', (
      tester,
    ) async {
      final probe = await _pump(
        tester,
        const Size(844, 390),
        mobileLandscape: true,
      );

      expect(probe.built, {'mobileLandscape': 1});
    });

    testWidgets('tablet landscape uses tabletLandscape when given', (
      tester,
    ) async {
      final probe = await _pump(
        tester,
        const Size(1024, 768),
        tabletLandscape: true,
      );

      expect(probe.built, {'tabletLandscape': 1});
    });

    testWidgets('tablet landscape falls back to tablet', (tester) async {
      final probe = await _pump(tester, const Size(1024, 768));

      expect(probe.built, {'tablet': 1});
    });
  });
}
