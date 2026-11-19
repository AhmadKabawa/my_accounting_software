import 'package:accounting_software/app/core/presentation/design_system/responsive/engine/app_density_scope.dart';
import 'package:accounting_software/app/core/presentation/design_system/responsive/extension/ui_extension.dart';
import 'package:accounting_software/app/core/presentation/design_system/responsive/engine/app_enums.dart';
import 'package:accounting_software/app/core/presentation/design_system/theme/app_theme.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_button/app_button_style.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_text_field/app_text_field_style.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('context.ui.density exposes the nearest scope', (tester) async {
    tester.view.physicalSize = const Size(1280, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    late DensityHelper density;
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        home: AppDensityScope(
          density: AppDensity.compact,
          child: Builder(
            builder: (context) {
              density = context.ui.density;
              return const SizedBox.shrink();
            },
          ),
        ),
      ),
    );

    expect(density.current, AppDensity.compact);
    expect(density.isCompact(), isTrue);
    expect(density.resolve(AppDensity.comfortable), AppDensity.comfortable);
    expect(density.isCompact(AppDensity.comfortable), isFalse);
    expect(density.fieldHeight(), AppDensity.compact.field);
  });

  testWidgets('density helper defaults to comfortable without a scope', (
    tester,
  ) async {
    late AppDensity density;
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        home: Builder(
          builder: (context) {
            density = context.ui.density.current;
            return const SizedBox.shrink();
          },
        ),
      ),
    );

    expect(density, AppDensity.comfortable);
  });

  testWidgets('explicit density overrides the inherited scope', (tester) async {
    tester.view.physicalSize = const Size(1280, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    late double buttonHeight;
    late bool fieldIsDense;
    late double iconTouchTarget;
    late double minimumHitArea;
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        home: AppDensityScope(
          density: AppDensity.comfortable,
          child: Builder(
            builder: (context) {
              final button = AppButtonStyle(
                context,
                density: AppDensity.compact,
              );
              final field = AppTextFieldStyle(
                context,
                density: AppDensity.compact,
              );
              buttonHeight = button
                  .resolve(AppButtonVariant.primary, AppButtonSize.medium)
                  .height;
              fieldIsDense = field.isDense;
              iconTouchTarget = button.touchTarget;
              minimumHitArea = AppComponentSize.hitArea.of(context);
              return const SizedBox.shrink();
            },
          ),
        ),
      ),
    );

    expect(buttonHeight, AppDensity.compact.field);
    expect(fieldIsDense, isTrue);
    expect(iconTouchTarget, greaterThanOrEqualTo(minimumHitArea));
  });

  testWidgets('compact on a phone preserves the minimum touch target', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    late double touchTarget;
    late double minimumHitArea;
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        home: AppDensityScope(
          density: AppDensity.compact,
          child: Builder(
            builder: (context) {
              touchTarget = AppButtonStyle(context).touchTarget;
              minimumHitArea = AppComponentSize.hitArea.of(context);
              return const SizedBox.shrink();
            },
          ),
        ),
      ),
    );

    expect(touchTarget, greaterThanOrEqualTo(minimumHitArea));
  });
}
