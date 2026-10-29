// The padding/radius refactor (df075eb) claims identical behaviour. This test
// keeps a copy of the ORIGINAL implementation and compares it with the current
// one over a grid of inputs, screen widths and modes.

import 'package:accounting_software/app/core/presentation/responsive/engine/scale_engine.dart';
import 'package:accounting_software/app/core/presentation/responsive/engine/screen_engine.dart';
import 'package:accounting_software/app/core/presentation/responsive/helper/responsive_helper.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

// ── Original implementation (verbatim logic from before df075eb) ─────────────

EdgeInsets oldPadding(
  BuildContext context, {
  AppSpacing all = AppSpacing.none,
  AppSpacing horizontal = AppSpacing.none,
  AppSpacing vertical = AppSpacing.none,
  AppSpacing left = AppSpacing.none,
  AppSpacing right = AppSpacing.none,
  AppSpacing top = AppSpacing.none,
  AppSpacing bottom = AppSpacing.none,
  AppSpacing? min,
  AppSpacing? max,
  ResponsiveMode mode = ResponsiveMode.adaptiveScale,
}) {
  final resolvedLeft = left != AppSpacing.none
      ? left
      : horizontal != AppSpacing.none
      ? horizontal
      : all;
  final resolvedRight = right != AppSpacing.none
      ? right
      : horizontal != AppSpacing.none
      ? horizontal
      : all;
  final resolvedTop = top != AppSpacing.none
      ? top
      : vertical != AppSpacing.none
      ? vertical
      : all;
  final resolvedBottom = bottom != AppSpacing.none
      ? bottom
      : vertical != AppSpacing.none
      ? vertical
      : all;
  final allValues = [resolvedLeft, resolvedRight, resolvedTop, resolvedBottom];
  final effectiveMin =
      min ?? allValues.reduce((a, b) => a.mobile < b.mobile ? a : b);
  final effectiveMax =
      max ?? allValues.reduce((a, b) => a.mobile > b.mobile ? a : b);

  double sp(AppSpacing s) => Rh.spacing(
    context,
    s,
    min: effectiveMin,
    max: effectiveMax,
    mode: mode,
  );
  return EdgeInsets.only(
    left: sp(resolvedLeft),
    right: sp(resolvedRight),
    top: sp(resolvedTop),
    bottom: sp(resolvedBottom),
  );
}

double oldRadiusValue(
  BuildContext context,
  AppRadius size, {
  AppRadius? min,
  AppRadius? max,
  required ResponsiveMode mode,
}) {
  final screenType = ScreenEngine.screenType(context);
  switch (mode) {
    case ResponsiveMode.fixed:
      return size.mobile;
    case ResponsiveMode.scaleOnly:
      return ScaleEngine.scale(
        context,
        designValue: size.mobile,
        minValue: (min ?? AppRadius.none).mobile,
        maxValue: (max ?? AppRadius.full).mobile,
      );
    case ResponsiveMode.adaptiveOnly:
      return size.forType(screenType);
    case ResponsiveMode.adaptiveScale:
      final designValue = size.forType(screenType);
      final minValue = (min ?? AppRadius.none).forType(screenType);
      final maxValue = (max ?? AppRadius.full).forType(screenType);
      return ScaleEngine.scale(
        context,
        designValue: designValue,
        minValue: minValue,
        maxValue: maxValue,
      );
  }
}

BorderRadius oldRadius(
  BuildContext context,
  AppRadius size, {
  AppRadius? min,
  AppRadius? max,
  bool topLeft = true,
  bool topRight = true,
  bool bottomLeft = true,
  bool bottomRight = true,
  ResponsiveMode mode = ResponsiveMode.adaptiveOnly,
}) {
  if (size == AppRadius.full) return BorderRadius.circular(double.infinity);
  final r = oldRadiusValue(context, size, min: min, max: max, mode: mode);
  final corner = Radius.circular(r);
  if (topLeft && topRight && bottomLeft && bottomRight) {
    return BorderRadius.circular(r);
  }
  return BorderRadius.only(
    topLeft: topLeft ? corner : Radius.zero,
    topRight: topRight ? corner : Radius.zero,
    bottomLeft: bottomLeft ? corner : Radius.zero,
    bottomRight: bottomRight ? corner : Radius.zero,
  );
}

// ── Harness ──────────────────────────────────────────────────────────────────

const _widths = [320.0, 390.0, 599.0, 600.0, 900.0, 1199.0, 1200.0, 1600.0];

Future<BuildContext> _contextAt(WidgetTester tester, double width) async {
  late BuildContext captured;
  await tester.pumpWidget(
    Directionality(
      textDirection: TextDirection.ltr,
      child: MediaQuery(
        data: MediaQueryData(size: Size(width, 800)),
        child: Builder(
          builder: (context) {
            captured = context;
            return const SizedBox();
          },
        ),
      ),
    ),
  );
  return captured;
}

void main() {
  const spacings = [AppSpacing.none, AppSpacing.xs, AppSpacing.md, AppSpacing.xl];
  const radii = [AppRadius.xs, AppRadius.md, AppRadius.xl, AppRadius.full];

  testWidgets('padding matches the original implementation', (tester) async {
    var compared = 0;
    for (final width in _widths) {
      final ctx = await _contextAt(tester, width);
      for (final mode in ResponsiveMode.values) {
        for (final all in spacings) {
          for (final horizontal in [AppSpacing.none, AppSpacing.lg]) {
            for (final vertical in [AppSpacing.none, AppSpacing.sm]) {
              for (final left in [AppSpacing.none, AppSpacing.xxl]) {
                for (final top in [AppSpacing.none, AppSpacing.smMd]) {
                  for (final min in [null, AppSpacing.xs]) {
                    for (final max in [null, AppSpacing.xxl]) {
                      final expected = oldPadding(
                        ctx,
                        all: all,
                        horizontal: horizontal,
                        vertical: vertical,
                        left: left,
                        top: top,
                        min: min,
                        max: max,
                        mode: mode,
                      );
                      final actual = Rh.padding(
                        ctx,
                        all: all,
                        horizontal: horizontal,
                        vertical: vertical,
                        left: left,
                        top: top,
                        min: min,
                        max: max,
                        mode: mode,
                      );
                      expect(
                        actual,
                        expected,
                        reason:
                            'w=$width mode=$mode all=$all h=$horizontal '
                            'v=$vertical left=$left top=$top min=$min max=$max',
                      );
                      compared++;
                    }
                  }
                }
              }
            }
          }
        }
      }
    }
    expect(compared, greaterThan(1000));
  });

  testWidgets('paddingDirectional equals padding with start/end as left/right',
      (tester) async {
    for (final width in _widths) {
      final ctx = await _contextAt(tester, width);
      for (final mode in ResponsiveMode.values) {
        for (final all in spacings) {
          final expected = oldPadding(
            ctx,
            all: all,
            left: AppSpacing.lg,
            right: AppSpacing.sm,
            mode: mode,
          );
          final actual = Rh.paddingDirectional(
            context: ctx,
            all: all,
            start: AppSpacing.lg,
            end: AppSpacing.sm,
            mode: mode,
          );
          expect(
            actual,
            EdgeInsetsDirectional.only(
              start: expected.left,
              end: expected.right,
              top: expected.top,
              bottom: expected.bottom,
            ),
            reason: 'w=$width mode=$mode all=$all',
          );
        }
      }
    }
  });

  testWidgets('radius matches the original implementation', (tester) async {
    for (final width in _widths) {
      final ctx = await _contextAt(tester, width);
      for (final mode in ResponsiveMode.values) {
        for (final size in radii) {
          for (final min in [null, AppRadius.xs]) {
            for (final max in [null, AppRadius.lg]) {
              for (final topLeft in [true, false]) {
                for (final bottomRight in [true, false]) {
                  expect(
                    Rh.radius(
                      ctx,
                      size,
                      min: min,
                      max: max,
                      topLeft: topLeft,
                      bottomRight: bottomRight,
                      mode: mode,
                    ),
                    oldRadius(
                      ctx,
                      size,
                      min: min,
                      max: max,
                      topLeft: topLeft,
                      bottomRight: bottomRight,
                      mode: mode,
                    ),
                    reason:
                        'w=$width mode=$mode size=$size min=$min max=$max '
                        'tl=$topLeft br=$bottomRight',
                  );
                }
              }
            }
          }
        }
      }
    }
  });

  testWidgets('radiusDirectional matches radius with start/end as left/right',
      (tester) async {
    for (final width in _widths) {
      final ctx = await _contextAt(tester, width);
      for (final mode in ResponsiveMode.values) {
        for (final size in radii) {
          for (final topStart in [true, false]) {
            for (final bottomEnd in [true, false]) {
              final expected = oldRadius(
                ctx,
                size,
                topLeft: topStart,
                bottomRight: bottomEnd,
                mode: mode,
              );
              final actual = Rh.radiusDirectional(
                ctx,
                size,
                topStart: topStart,
                bottomEnd: bottomEnd,
                mode: mode,
              );
              expect(
                actual,
                BorderRadiusDirectional.only(
                  topStart: expected.topLeft,
                  topEnd: expected.topRight,
                  bottomStart: expected.bottomLeft,
                  bottomEnd: expected.bottomRight,
                ),
                reason: 'w=$width mode=$mode size=$size',
              );
            }
          }
        }
      }
    }
  });
}
