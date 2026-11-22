import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:accounting_software/app/core/localization/keys/catalog_ui_keys.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_button/app_icon_button.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_icon/app_icon.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_row_actions/app_row_actions.dart';
import '../../../helpers/localized_app.dart';

void main() {
  setUpAll(() => useTranslations(const Locale('en')));

  testWidgets('primary actions are icon buttons that fire; overflow in menu', (
    tester,
  ) async {
    var edited = 0;
    var restored = 0;
    await tester.pumpWidget(
      buildTestApp(
        home: Scaffold(
          body: AppRowActions(
            primary: [
              AppRowAction(
                icon: AppIcons.edit,
                labelKey: CatalogUiKeys.retry,
                onPressed: () => edited++,
              ),
            ],
            overflow: [
              AppRowAction(
                icon: AppIcons.restore,
                labelKey: CatalogUiKeys.apply,
                onPressed: () => restored++,
              ),
            ],
          ),
        ),
      ),
    );

    expect(find.byType(AppIconButton), findsOneWidget);
    expect(find.text('Retry'), findsNothing); // icon only, no text label
    await tester.tap(find.byType(AppIconButton));
    expect(edited, 1);

    await tester.tap(find.byTooltip('More actions'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Apply'));
    await tester.pumpAndSettle();
    expect(restored, 1);
  });

  testWidgets(
    'at most two inline icons; extra primary actions go to the menu',
    (tester) async {
      AppRowAction action(AppIconData icon, int i) => AppRowAction(
        icon: icon,
        labelKey: CatalogUiKeys.retry,
        onPressed: () {},
      );
      await tester.pumpWidget(
        buildTestApp(
          home: Scaffold(
            body: AppRowActions(
              primary: [
                action(AppIcons.edit, 1),
                action(AppIcons.block, 2),
                action(AppIcons.restore, 3),
              ],
              overflow: [action(AppIcons.delete, 4)],
            ),
          ),
        ),
      );
      // Two inline icon buttons plus the "more" menu button.
      expect(find.byType(AppIconButton), findsNWidgets(2));
      expect(find.byTooltip('More actions'), findsOneWidget);
    },
  );
}
