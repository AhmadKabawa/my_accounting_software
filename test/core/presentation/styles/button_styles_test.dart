import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:accounting_software/app/core/presentation/styles/components/button_styles.dart';
import 'package:accounting_software/app/core/presentation/styles/styles_extension.dart';
import 'package:accounting_software/app/core/presentation/theme/app_theme.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_button/app_button.dart';

Future<ButtonStyles> _buttonStylesAt(WidgetTester tester, Size size) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);

  late ButtonStyles styles;
  await tester.pumpWidget(
    MaterialApp(
      theme: AppTheme.light(),
      home: Builder(
        builder: (context) {
          styles = context.uiStyles.button;
          return const SizedBox();
        },
      ),
    ),
  );
  return styles;
}

Future<void> _pumpButton(
  WidgetTester tester,
  Widget button, {
  Size size = const Size(390, 844),
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    MaterialApp(
      theme: AppTheme.light(),
      home: Scaffold(body: Center(child: button)),
    ),
  );
}

void main() {
  const phone = Size(390, 844);
  const desktop = Size(1440, 900);

  group('ButtonStyles.resolve', () {
    testWidgets('variants give different colors', (tester) async {
      final styles = await _buttonStylesAt(tester, phone);
      final scheme = AppTheme.light().colorScheme;

      final primary = styles.resolve(
        AppButtonVariant.primary,
        AppButtonSize.medium,
      );
      final secondary = styles.resolve(
        AppButtonVariant.secondary,
        AppButtonSize.medium,
      );
      final outlined = styles.resolve(
        AppButtonVariant.outlined,
        AppButtonSize.medium,
      );
      final danger = styles.resolve(
        AppButtonVariant.danger,
        AppButtonSize.medium,
      );

      expect(primary.background, scheme.primary);
      expect(primary.foreground, scheme.onPrimary);
      expect(secondary.background, scheme.secondaryContainer);
      expect(danger.background, scheme.error);
      expect(danger.foreground, scheme.onError);
      expect(outlined.background, Colors.transparent);
      expect(outlined.borderColor, scheme.outline);
      expect(outlined.borderWidth, greaterThan(0));
      expect(primary.borderColor, isNull);
      expect(
        {primary.background, secondary.background, danger.background},
        hasLength(3),
      );
    });

    testWidgets('sizes give increasing heights on mobile', (tester) async {
      final styles = await _buttonStylesAt(tester, phone);

      final small = styles.resolve(AppButtonVariant.primary, AppButtonSize.small);
      final medium = styles.resolve(
        AppButtonVariant.primary,
        AppButtonSize.medium,
      );
      final large = styles.resolve(AppButtonVariant.primary, AppButtonSize.large);

      expect(small.height, 32);
      expect(medium.height, 40);
      expect(large.height, 48);
      expect(small.iconSize, lessThan(medium.iconSize));
      expect(medium.iconSize, lessThan(large.iconSize));
      expect(small.padding.horizontal, lessThan(medium.padding.horizontal));
      expect(medium.padding.horizontal, lessThan(large.padding.horizontal));
    });

    testWidgets('disabled differs from enabled', (tester) async {
      final styles = await _buttonStylesAt(tester, phone);

      final enabled = styles.resolve(
        AppButtonVariant.primary,
        AppButtonSize.medium,
      );
      final disabled = styles.resolve(
        AppButtonVariant.primary,
        AppButtonSize.medium,
        state: AppButtonState.disabled,
      );

      expect(disabled.background, isNot(enabled.background));
      expect(disabled.foreground, isNot(enabled.foreground));
      expect(disabled.foreground.alpha, lessThan(255));
    });

    testWidgets('pressed differs from enabled', (tester) async {
      final styles = await _buttonStylesAt(tester, phone);

      final enabled = styles.resolve(
        AppButtonVariant.primary,
        AppButtonSize.medium,
      );
      final pressed = styles.resolve(
        AppButtonVariant.primary,
        AppButtonSize.medium,
        state: AppButtonState.pressed,
      );

      expect(pressed.background, isNot(enabled.background));
      expect(pressed.foreground, enabled.foreground);
    });

    testWidgets('sizes grow on desktop, mobile is unchanged', (tester) async {
      final onPhone = (await _buttonStylesAt(
        tester,
        phone,
      )).resolve(AppButtonVariant.primary, AppButtonSize.medium);
      final onDesktop = (await _buttonStylesAt(
        tester,
        desktop,
      )).resolve(AppButtonVariant.primary, AppButtonSize.medium);

      expect(onPhone.height, 40);
      expect(onDesktop.height, 48);
      expect(onDesktop.iconSize, greaterThan(onPhone.iconSize));
      expect(onDesktop.padding.horizontal, greaterThan(onPhone.padding.horizontal));
    });
  });

  group('AppButton', () {
    testWidgets('size changes the rendered height', (tester) async {
      await _pumpButton(
        tester,
        AppButton.raw('x', onPressed: () {}, size: AppButtonSize.small),
      );
      final small = tester.getSize(find.byType(AppButton)).height;

      await _pumpButton(
        tester,
        AppButton.raw('x', onPressed: () {}, size: AppButtonSize.large),
      );
      final large = tester.getSize(find.byType(AppButton)).height;

      expect(small, 32);
      expect(large, 48);
    });

    testWidgets('variant changes the Material color', (tester) async {
      Color colorOf(WidgetTester t) => t
          .widget<Material>(
            find.descendant(
              of: find.byType(AppButton),
              matching: find.byType(Material),
            ),
          )
          .color!;

      await _pumpButton(tester, AppButton.raw('x', onPressed: () {}));
      final primary = colorOf(tester);

      await _pumpButton(
        tester,
        AppButton.raw('x', onPressed: () {}, variant: AppButtonVariant.danger),
      );
      final danger = colorOf(tester);

      expect(primary, isNot(danger));
    });

    testWidgets('onPressed null disables the button', (tester) async {
      var taps = 0;
      await _pumpButton(tester, AppButton.raw('x', onPressed: () => taps++));
      final enabled = tester
          .widget<Material>(
            find.descendant(
              of: find.byType(AppButton),
              matching: find.byType(Material),
            ),
          )
          .color;

      await tester.tap(find.byType(AppButton));
      expect(taps, 1);

      await _pumpButton(tester, const AppButton.raw('x', onPressed: null));
      final disabled = tester
          .widget<Material>(
            find.descendant(
              of: find.byType(AppButton),
              matching: find.byType(Material),
            ),
          )
          .color;

      expect(disabled, isNot(enabled));
      await tester.tap(find.byType(AppButton));
      expect(taps, 1);
    });

    testWidgets('isLoading shows a spinner and blocks taps', (tester) async {
      var taps = 0;
      await _pumpButton(
        tester,
        AppButton.raw('x', onPressed: () => taps++, isLoading: true),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      await tester.tap(find.byType(AppButton));
      expect(taps, 0);
    });
  });
}
