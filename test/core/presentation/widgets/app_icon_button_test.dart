import 'package:accounting_software/app/core/presentation/design_system/theme/app_theme.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_button/app_icon_button.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_icon/app_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import '../../../helpers/localized_app.dart';

import '../../../helpers/test_key.dart';

void main() {
  setUpAll(() => useTranslations(const Locale('en')));

  const tooltip = TestKey('test.tooltip');

  Future<void> pump(WidgetTester tester, {VoidCallback? onPressed}) {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    return tester.pumpWidget(
      buildTestApp(
        theme: AppTheme.light(),
        home: Scaffold(
          body: Center(
            child: AppIconButton(
              AppIcons.visibility,
              tooltipKey: tooltip,
              onPressed: onPressed,
            ),
          ),
        ),
      ),
    );
  }

  testWidgets('touch target is at least 48 logical pixels', (tester) async {
    await pump(tester, onPressed: () {});

    final size = tester.getSize(find.byType(AppIconButton));
    expect(size.width, greaterThanOrEqualTo(48));
    expect(size.height, greaterThanOrEqualTo(48));
  });

  testWidgets('calls onPressed when tapped', (tester) async {
    var taps = 0;
    await pump(tester, onPressed: () => taps++);

    await tester.tap(find.byType(AppIconButton));

    expect(taps, 1);
  });

  testWidgets('custom icon color does not change the button surface', (tester) async {
    await tester.pumpWidget(
      buildTestApp(
        theme: AppTheme.light(),
        home: Scaffold(
          body: Center(
            child: AppIconButton(
              AppIcons.block,
              tooltipKey: tooltip,
              color: Colors.red,
              onPressed: () {},
            ),
          ),
        ),
      ),
    );

    final material = tester.widget<Material>(
      find.descendant(
        of: find.byType(AppIconButton),
        matching: find.byType(Material),
      ),
    );
    final icon = tester.widget<Icon>(find.byType(Icon).first);
    expect(icon.color, Colors.red);
    expect(material.color, isNot(Colors.red));
  });

  testWidgets('does nothing when disabled', (tester) async {
    await pump(tester);

    await tester.tap(find.byType(AppIconButton), warnIfMissed: false);

    expect(tester.takeException(), isNull);
  });
}
