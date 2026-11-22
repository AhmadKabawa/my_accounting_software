import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:accounting_software/app/core/presentation/design_system/theme/app_theme.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_badge/app_badge.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_icon/app_icon.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_stat_card/app_stat_card.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_stats_bar/list_stats_bar.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_stats_bar/stat_item.dart';
import '../../../helpers/localized_app.dart';
import '../../../helpers/test_key.dart';

void main() {
  setUpAll(() => useTranslations(const Locale('en')));

  testWidgets('keeps every card equal-width and narrower than the row', (
    tester,
  ) async {
    for (final width in [360.0, 600.0, 1200.0]) {
      for (var count = 1; count <= 6; count++) {
        tester.view.physicalSize = Size(width, 900);
        tester.view.devicePixelRatio = 1;
        await tester.pumpWidget(
          buildTestApp(
            theme: AppTheme.light(),
            home: Scaffold(
              body: ListStatsBar<int>(
                items: [
                  for (var index = 0; index < count; index++)
                    StatItem<int>(
                      labelKey: TestKey('stat.$index'),
                      value: '$index',
                      icon: AppIcons.info,
                      tone: AppBadgeTone.info,
                      filter: index,
                    ),
                ],
                selected: 0,
                onSelected: (_) {},
              ),
            ),
          ),
        );

        final cards = find.byType(AppStatCard);
        expect(cards, findsNWidgets(count), reason: '$count cards at $width');
        final cardWidths = [
          for (var index = 0; index < count; index++)
            tester.getSize(cards.at(index)).width,
        ];
        expect(cardWidths.every((value) => value < width), isTrue);
        for (final cardWidth in cardWidths.skip(1)) {
          expect(cardWidth, closeTo(cardWidths.first, 0.01));
        }
        expect(tester.takeException(), isNull);
      }
    }
    addTearDown(tester.view.reset);
  });

  testWidgets('loading preserves card count and uses skeleton state', (
    tester,
  ) async {
    await tester.pumpWidget(
      buildTestApp(
        home: Scaffold(
          body: ListStatsBar<int>(
            items: [
              for (var index = 0; index < 4; index++)
                StatItem<int>(
                  labelKey: TestKey('stat.$index'),
                  value: '$index',
                  icon: AppIcons.info,
                  tone: AppBadgeTone.info,
                  filter: index,
                ),
            ],
            selected: null,
            onSelected: (_) {},
            loading: true,
          ),
        ),
      ),
    );

    expect(find.byType(AppStatCard), findsNWidgets(4));
    expect(
      tester.widgetList<AppStatCard>(find.byType(AppStatCard)).every(
        (card) => card.loading && card.value == null && !card.selected,
      ),
      isTrue,
    );
  });
}
