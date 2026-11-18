import 'package:accounting_software/app/core/presentation/design_system/responsive/engine/app_density_scope.dart';
import 'package:accounting_software/app/core/presentation/design_system/responsive/engine/app_enums.dart';
import 'package:accounting_software/app/core/presentation/design_system/theme/app_theme.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_button/app_button_style.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_text_field/app_text_field_style.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Resolves button and field values for [density] at the given window [size].
Future<({double button, double touch, EdgeInsets padding, bool dense})>
_resolve(WidgetTester tester, Size size, {AppDensity? density}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);

  late ({double button, double touch, EdgeInsets padding, bool dense}) out;
  Widget probe = Builder(
    builder: (context) {
      final button = AppButtonStyle(context);
      final field = AppTextFieldStyle(context);
      out = (
        button: button
            .resolve(AppButtonVariant.primary, AppButtonSize.medium)
            .height,
        touch: button.touchTarget,
        padding: field.contentPadding,
        dense: field.isDense,
      );
      return const SizedBox();
    },
  );
  if (density != null) {
    probe = AppDensityScope(density: density, child: probe);
  }
  await tester.pumpWidget(MaterialApp(theme: AppTheme.light(), home: probe));
  return out;
}

void main() {
  const desktop = Size(1280, 800);
  const phone = Size(390, 844);

  testWidgets('no scope means comfortable', (tester) async {
    late AppDensity found;
    await tester.pumpWidget(
      Builder(
        builder: (context) {
          found = AppDensityScope.of(context);
          return const SizedBox();
        },
      ),
    );
    expect(found, AppDensity.comfortable);
  });

  testWidgets('comfortable looks the same as without a scope', (tester) async {
    final plain = await _resolve(tester, desktop);
    final comfortable = await _resolve(
      tester,
      desktop,
      density: AppDensity.comfortable,
    );
    expect(comfortable, plain);
    expect(comfortable.dense, isFalse);
  });

  testWidgets('compact on desktop: control height does not exceed the field', (
    tester,
  ) async {
    final plain = await _resolve(tester, desktop);
    final compact = await _resolve(
      tester,
      desktop,
      density: AppDensity.compact,
    );
    expect(compact.button, lessThanOrEqualTo(AppDensity.compact.field));
    expect(compact.touch, lessThanOrEqualTo(AppDensity.compact.field));
    expect(compact.button, lessThanOrEqualTo(plain.button));
    expect(compact.dense, isTrue);
    expect(compact.padding.top, lessThanOrEqualTo(plain.padding.top));
  });

  testWidgets('compact on a phone changes nothing (touch floor)', (
    tester,
  ) async {
    final plain = await _resolve(tester, phone);
    final compact = await _resolve(tester, phone, density: AppDensity.compact);
    expect(compact, plain);
  });
}
