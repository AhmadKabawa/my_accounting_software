import 'package:accounting_software/app/core/presentation/design_system/theme/app_theme.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_empty_state/app_empty_state.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_icon/app_icon.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_icon/app_icons.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_text/app_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import '../../../helpers/localized_app.dart';

import '../../../helpers/test_key.dart';

void main() {
  setUpAll(() => useTranslations(const Locale('en')));

  const title = TestKey('test.empty.title');
  const description = TestKey('test.empty.description');

  Future<void> pumpEmptyState(
    WidgetTester tester, {
    Widget? action,
    bool compact = false,
    Size size = const Size(390, 844),
  }) {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    return tester.pumpWidget(
      buildTestApp(
        theme: AppTheme.light(),
        home: Scaffold(
          body: AppEmptyState(
            icon: AppIcons.info,
            titleKey: title,
            descriptionKey: description,
            action: action,
            compact: compact,
          ),
        ),
      ),
    );
  }

  group('AppEmptyState', () {
    testWidgets('renders AppIcon and localized AppKey copy', (tester) async {
      await pumpEmptyState(tester);

      final titleText = tester.widget<AppText>(
        find.byWidgetPredicate(
          (widget) => widget is AppText && widget.textKey == title,
        ),
      );
      final descriptionText = tester.widget<AppText>(
        find.byWidgetPredicate(
          (widget) => widget is AppText && widget.textKey == description,
        ),
      );

      expect(find.byType(AppIcon), findsOneWidget);
      expect(titleText.textKey, same(title));
      expect(descriptionText.textKey, same(description));
      expect(titleText.rawText, isNull);
      expect(descriptionText.rawText, isNull);
    });

    testWidgets('renders an optional action slot', (tester) async {
      const actionKey = Key('empty-state-action');
      await pumpEmptyState(
        tester,
        action: const SizedBox(key: actionKey, width: 80, height: 40),
      );

      expect(find.byKey(actionKey), findsOneWidget);
    });

    testWidgets('supports compact and regular layouts across widths', (
      tester,
    ) async {
      for (final size in [
        const Size(360, 800),
        const Size(600, 900),
        const Size(900, 900),
        const Size(1200, 900),
      ]) {
        await pumpEmptyState(tester, compact: true, size: size);
        expect(find.byType(AppEmptyState), findsOneWidget);
        expect(tester.takeException(), isNull);
      }
    });
  });
}
