import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:accounting_software/app/core/localization/keys/catalog_ui_keys.dart';
import 'package:accounting_software/app/core/presentation/design_system/theme/app_theme.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_badge/app_badge.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_card/app_card.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_icon/app_icon.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_skeleton/app_skeleton.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_stat_card/app_stat_card.dart';
import '../../../helpers/localized_app.dart';

void main() {
  setUpAll(() => useTranslations(const Locale('en')));

  Future<void> pump(
    WidgetTester tester,
    Widget card, {
    bool dark = false,
    TextDirection direction = TextDirection.ltr,
    Size size = const Size(390, 800),
  }) async {
    setScreenSize(tester, size);
    await tester.pumpWidget(
      buildTestApp(
        direction: direction,
        theme: dark ? AppTheme.dark() : AppTheme.light(),
        home: Scaffold(body: Center(child: card)),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('shows title, value and optional description', (tester) async {
    await pump(
      tester,
      const AppStatCard(
        titleKey: CatalogUiKeys.filters,
        value: '42',
        icon: AppIcons.brands,
        tone: AppBadgeTone.success,
        descriptionKey: CatalogUiKeys.search,
      ),
    );
    expect(find.text('Filters'), findsOneWidget);
    expect(find.text('42'), findsOneWidget);
    expect(find.text('Search'), findsOneWidget);
    expect(find.byType(AppIcon), findsOneWidget);
  });

  testWidgets('the value is visually stronger than the title', (tester) async {
    await pump(
      tester,
      const AppStatCard(titleKey: CatalogUiKeys.filters, value: '42'),
    );
    final value = tester.widget<Text>(find.text('42'));
    final title = tester.widget<Text>(find.text('Filters'));
    expect(value.style!.fontSize!, greaterThan(title.style!.fontSize!));
  });

  testWidgets('loading shows placeholders and ignores taps', (tester) async {
    var taps = 0;
    await pump(
      tester,
      AppStatCard(
        titleKey: CatalogUiKeys.filters,
        value: '42',
        loading: true,
        onTap: () => taps++,
      ),
    );
    expect(find.byType(AppSkeleton), findsWidgets);
    expect(find.text('42'), findsNothing);
    await tester.tap(find.byType(AppCard), warnIfMissed: false);
    expect(taps, 0);
  });

  testWidgets('null value is the empty state (a dash)', (tester) async {
    await pump(
      tester,
      const AppStatCard(titleKey: CatalogUiKeys.filters, value: null),
    );
    expect(find.text('—'), findsOneWidget);
  });

  testWidgets('selected adds the semantic flag and a primary border', (
    tester,
  ) async {
    await pump(
      tester,
      AppStatCard(
        titleKey: CatalogUiKeys.filters,
        value: '1',
        selected: true,
        onTap: () {},
      ),
    );
    expect(tester.widget<AppCard>(find.byType(AppCard)).selected, isTrue);
  });

  testWidgets('onTap fires', (tester) async {
    var taps = 0;
    await pump(
      tester,
      AppStatCard(
        titleKey: CatalogUiKeys.filters,
        value: '1',
        onTap: () => taps++,
      ),
    );
    await tester.tap(find.byType(AppStatCard));
    expect(taps, 1);
  });

  testWidgets('a card without a filter is informational, not a button', (
    tester,
  ) async {
    await pump(
      tester,
      const AppStatCard(
        titleKey: CatalogUiKeys.filters,
        value: '42',
        selected: true,
      ),
    );
    expect(tester.widget<AppCard>(find.byType(AppCard)).selected, isFalse);
    expect(find.byType(InkWell), findsNothing);
    expect(
      find.byWidgetPredicate(
        (widget) => widget is Semantics && widget.properties.button == true,
      ),
      findsNothing,
    );
  });


  testWidgets('renders in every tone, theme and direction without errors', (
    tester,
  ) async {
    for (final tone in AppBadgeTone.values) {
      for (final dark in [false, true]) {
        for (final dir in TextDirection.values) {
          await pump(
            tester,
            AppStatCard(
              titleKey: CatalogUiKeys.filters,
              value: '1,234',
              icon: AppIcons.info,
              tone: tone,
            ),
            dark: dark,
            direction: dir,
            size: const Size(360, 800),
          );
          expect(tester.takeException(), isNull);
        }
      }
    }
  });
}
