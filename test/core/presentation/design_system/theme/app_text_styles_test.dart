import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:accounting_software/app/core/presentation/design_system/responsive/extension/ui_extension.dart';
import 'package:accounting_software/app/core/presentation/design_system/theme/app_text_styles.dart';
import 'package:accounting_software/app/core/presentation/design_system/theme/app_theme.dart';

void main() {
  group('font size tokens', () {
    test('there is no tiny size and the smallest text is 12 on a phone', () {
      expect(AppFontSize.xs.mobile, 12);
      expect(AppFontSize.xs.tablet, 12);
      expect(AppFontSize.xs.desktop, 13);
      expect(AppFontSize.sm.forType(ScreenType.mobile), 13);
    });

    test('every role is at least 12 on a phone and keeps zero spacing', () {
      for (final type in AppTextType.values) {
        final baseline = type.descriptor.baseline;
        expect(baseline.fontSize, greaterThanOrEqualTo(12), reason: '$type');
        expect(baseline.letterSpacing, 0, reason: '$type');
      }
    });
  });

  group('roles follow the design (phone values)', () {
    TextStyle of(AppTextType type) => type.descriptor.baseline;

    test('display, headline, title, body, label and button sizes', () {
      expect(of(AppTextType.displayLarge).fontSize, 40);
      expect(of(AppTextType.displayMedium).fontSize, 28);
      expect(of(AppTextType.displaySmall).fontSize, 24);
      expect(of(AppTextType.headlineLarge).fontSize, 20);
      expect(of(AppTextType.headlineMedium).fontSize, 18);
      expect(of(AppTextType.headlineSmall).fontSize, 16);
      expect(of(AppTextType.titleLarge).fontSize, 16);
      expect(of(AppTextType.titleMedium).fontSize, 14);
      expect(of(AppTextType.titleSmall).fontSize, 12);
      expect(of(AppTextType.bodyLarge).fontSize, 16);
      expect(of(AppTextType.bodyMedium).fontSize, 14);
      expect(of(AppTextType.bodySmall).fontSize, 12);
      expect(of(AppTextType.labelLarge).fontSize, 14);
      expect(of(AppTextType.labelMedium).fontSize, 13);
      expect(of(AppTextType.labelSmall).fontSize, 12);
      expect(of(AppTextType.buttonText).fontSize, 14);
      expect(of(AppTextType.buttonTextSmall).fontSize, 12);
    });

    test('weights and line heights', () {
      expect(of(AppTextType.displayLarge).fontWeight, FontWeight.w700);
      expect(of(AppTextType.headlineMedium).fontWeight, FontWeight.w600);
      expect(of(AppTextType.titleMedium).fontWeight, FontWeight.w500);
      expect(of(AppTextType.bodyMedium).fontWeight, FontWeight.w400);
      expect(of(AppTextType.buttonText).fontWeight, FontWeight.w500);
      expect(of(AppTextType.bodyMedium).height, 1.5);
      expect(of(AppTextType.displayLarge).height, 1.2);
      expect(of(AppTextType.buttonText).height, 1.2);
    });

    test('amount roles: sizes, weights and tabular lining figures', () {
      expect(of(AppTextType.amountKpi).fontSize, 28);
      expect(of(AppTextType.amountKpi).fontWeight, FontWeight.w700);
      expect(of(AppTextType.amountLg).fontSize, 20);
      expect(of(AppTextType.amountLg).fontWeight, FontWeight.w600);
      expect(of(AppTextType.amountTable).fontSize, 14);
      expect(of(AppTextType.amountTable).fontWeight, FontWeight.w500);
      expect(of(AppTextType.docCode).fontSize, 13);
      expect(of(AppTextType.tableHeader).fontSize, 12);
      expect(of(AppTextType.tableHeader).fontWeight, FontWeight.w600);

      for (final type in [
        AppTextType.amountKpi,
        AppTextType.amountLg,
        AppTextType.amountTable,
        AppTextType.docCode,
      ]) {
        final features = of(type).fontFeatures!;
        expect(features, contains(const FontFeature.tabularFigures()));
        expect(features, contains(const FontFeature.liningFigures()));
      }
    });

    test('monospace is only for codes', () {
      expect(of(AppTextType.codeMono).fontFamily, AppFontFamily.mono);
      expect(of(AppTextType.codeMono).fontSize, 13);
      for (final type in AppTextType.values) {
        if (type == AppTextType.codeMono) continue;
        expect(of(type).fontFamily, isNull, reason: '$type');
      }
    });
  });

  group('theme', () {
    test('uses IBM Plex Sans Arabic', () {
      expect(AppFontFamily.sans, 'IBM Plex Sans Arabic');
      expect(
        AppTheme.light().textTheme.bodyMedium!.fontFamily,
        contains(AppFontFamily.sans),
      );
    });

    testWidgets(
      'amount roles keep tabular figures and the primary text color',
      (tester) async {
        late TextStyle amount;
        late TextStyle header;
        await tester.pumpWidget(
          MaterialApp(
            theme: AppTheme.light(),
            home: Builder(
              builder: (context) {
                amount = context.ui.text.of(AppTextType.amountTable);
                header = context.ui.text.of(AppTextType.tableHeader);
                return const SizedBox();
              },
            ),
          ),
        );

        final scheme = AppTheme.light().colorScheme;
        expect(
          amount.fontFeatures,
          contains(const FontFeature.tabularFigures()),
        );
        expect(amount.color, scheme.onSurface);
        expect(header.color, scheme.onSurfaceVariant);
        expect(amount.letterSpacing, 0);
      },
    );
  });
}
