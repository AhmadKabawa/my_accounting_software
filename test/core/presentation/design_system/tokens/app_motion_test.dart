import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:accounting_software/app/core/presentation/design_system/tokens/app_layer.dart';
import 'package:accounting_software/app/core/presentation/design_system/tokens/app_motion.dart';

Future<Duration> _durationWith(
  WidgetTester tester, {
  required bool disableAnimations,
}) async {
  late Duration result;
  await tester.pumpWidget(
    MediaQuery(
      data: MediaQueryData(disableAnimations: disableAnimations),
      child: Builder(
        builder: (context) {
          result = AppMotion.duration(context, AppMotionDuration.base);
          return const SizedBox();
        },
      ),
    ),
  );
  return result;
}

void main() {
  group('AppMotion', () {
    test('durations are 150, 200 and 300 ms', () {
      expect(AppMotionDuration.fast.value, const Duration(milliseconds: 150));
      expect(AppMotionDuration.base.value, const Duration(milliseconds: 200));
      expect(AppMotionDuration.slow.value, const Duration(milliseconds: 300));
    });

    test('curves are the design cubic-beziers', () {
      expect(AppMotion.standard, const Cubic(0.2, 0, 0, 1));
      expect(AppMotion.enter, const Cubic(0.05, 0.7, 0.1, 1));
      expect(AppMotion.exit, const Cubic(0.3, 0, 0.8, 0.15));
    });

    testWidgets('gives the token duration normally', (tester) async {
      expect(
        await _durationWith(tester, disableAnimations: false),
        AppMotionDuration.base.value,
      );
    });

    testWidgets('gives zero when the device asks to reduce motion', (
      tester,
    ) async {
      expect(
        await _durationWith(tester, disableAnimations: true),
        Duration.zero,
      );
    });
  });

  group('AppLayer', () {
    test('z-index values follow the design', () {
      expect(
        {for (final l in AppLayer.values) l.name: l.zIndex},
        {
          'content': 0,
          'stickyHeader': 10,
          'navigation': 20,
          'dropdown': 30,
          'sidePanel': 40,
          'modal': 50,
          'snackbar': 60,
          'tooltip': 70,
          'loadingOverlay': 80,
        },
      );
    });

    test('layers are strictly ordered', () {
      for (var i = 1; i < AppLayer.values.length; i++) {
        expect(AppLayer.values[i].isAbove(AppLayer.values[i - 1]), isTrue);
      }
    });
  });
}
