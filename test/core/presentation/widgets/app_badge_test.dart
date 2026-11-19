import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:accounting_software/app/core/localization/keys/badge_keys.dart';
import 'package:accounting_software/app/core/presentation/design_system/responsive/engine/app_density_scope.dart';
import 'package:accounting_software/app/core/presentation/design_system/responsive/engine/app_enums.dart';
import 'package:accounting_software/app/core/presentation/design_system/theme/app_theme.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_badge/app_badge.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_badge/app_badge_style.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_icon/app_icon.dart';
import '../../../helpers/localized_app.dart';
import '../../../helpers/test_key.dart';

double _contrast(Color foreground, Color background) {
  final a = foreground.computeLuminance();
  final b = background.computeLuminance();
  final lighter = a > b ? a : b;
  final darker = a > b ? b : a;
  return (lighter + 0.05) / (darker + 0.05);
}

void main() {
  setUpAll(() => useTranslations(const Locale('en')));

  for (final theme in [AppTheme.light(), AppTheme.dark()]) {
    for (final density in AppDensity.values) {
      for (final direction in [TextDirection.ltr, TextDirection.rtl]) {
        for (final width in [360.0, 600.0]) {
          testWidgets(
            'renders tones and sizes with optional icon '
            '(${theme.brightness}, $density, $direction, $width)',
            (tester) async {
              tester.view.physicalSize = Size(width, 900);
              tester.view.devicePixelRatio = 1;
              addTearDown(tester.view.reset);
              await tester.pumpWidget(
                buildTestApp(
                  theme: theme,
                  direction: direction,
                  home: AppDensityScope(
                    density: density,
                    child: SizedBox(
                      width: width,
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          for (final tone in AppBadgeTone.values)
                            for (final size in AppBadgeSize.values)
                              AppBadge(
                                label: BadgeKeys.sample,
                                tone: tone,
                                size: size,
                              ),
                          for (final tone in AppBadgeTone.values)
                            AppBadge(
                              label: BadgeKeys.sample,
                              tone: tone,
                              icon: AppIcons.check,
                            ),
                          const AppBadge(label: BadgeKeys.longLabel),
                        ],
                      ),
                    ),
                  ),
                ),
              );
              await tester.pumpAndSettle();
              expect(find.byType(AppBadge), findsNWidgets(16));
              expect(tester.takeException(), isNull);
            },
          );
        }
      }
    }
  }

  testWidgets('semantic text contrast meets WCAG AA in light and dark', (
    tester,
  ) async {
    for (final theme in [AppTheme.light(), AppTheme.dark()]) {
      await tester.pumpWidget(
        buildTestApp(
          theme: theme,
          home: Builder(
            builder: (context) {
              for (final tone in AppBadgeTone.values) {
                final visual = AppBadgeStyle(context).resolve(
                  tone,
                  AppBadgeSize.medium,
                );
                expect(
                  _contrast(visual.foreground, visual.background),
                  greaterThanOrEqualTo(4.5),
                  reason: '$tone on ${theme.brightness}',
                );
              }
              return const AppBadge(label: BadgeKeys.sample);
            },
          ),
        ),
      );
      await tester.pumpAndSettle();
    }
  });

  group('removable badge', () {
    const removeLabel = TestKey('test.badge.remove');

    Future<void> pumpRemovable(
      WidgetTester tester, {
      required Size size,
      required VoidCallback onRemove,
    }) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(
        buildTestApp(
          // InkWell needs a Material ancestor.
          home: Scaffold(
            body: Align(
              alignment: AlignmentDirectional.topStart,
              child: AppBadge(
                label: BadgeKeys.sample,
                size: AppBadgeSize.small,
                onRemove: onRemove,
                removeLabel: removeLabel,
              ),
            ),
          ),
        ),
      );
    }

    testWidgets('remove control reports the tap', (tester) async {
      var removed = 0;
      await pumpRemovable(
        tester,
        size: const Size(360, 800),
        onRemove: () => removed++,
      );
      await tester.tap(find.byType(InkWell));
      expect(removed, 1);
    });

    testWidgets('badge text is announced once, remove is its own button', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      addTearDown(handle.dispose);
      await pumpRemovable(
        tester,
        size: const Size(360, 800),
        onRemove: () {},
      );

      expect(find.bySemanticsLabel('Document status'), findsOneWidget);
      final remove = find.bySemanticsLabel('test.badge.remove');
      expect(remove, findsOneWidget);
      expect(
        tester.getSemantics(remove).hasAction(SemanticsAction.tap),
        isTrue,
      );
    });

    testWidgets('remove target reaches the hit area on phones', (tester) async {
      await pumpRemovable(
        tester,
        size: const Size(360, 800),
        onRemove: () {},
      );
      final target = tester.getSize(find.byType(InkWell));
      expect(target.width, greaterThanOrEqualTo(44));
      expect(target.height, greaterThanOrEqualTo(44));
    });
  });
}
