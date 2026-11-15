import 'package:flutter_test/flutter_test.dart';
import 'package:accounting_software/app/core/presentation/design_system/responsive/engine/app_enums.dart';

void main() {
  group('AppRadius follows the design scale', () {
    test('phone values: none 0, xs 4, sm 6, md 8, lg 12, xl 16', () {
      expect(AppRadius.none.mobile, 0);
      expect(AppRadius.xs.mobile, 4);
      expect(AppRadius.sm.mobile, 6);
      expect(AppRadius.md.mobile, 8);
      expect(AppRadius.lg.mobile, 12);
      expect(AppRadius.xl.mobile, 16);
    });

    test('values never shrink from phone to tablet to desktop', () {
      for (final r in [
        AppRadius.xs,
        AppRadius.sm,
        AppRadius.md,
        AppRadius.lg,
        AppRadius.xl,
      ]) {
        expect(r.tablet, greaterThanOrEqualTo(r.mobile));
        expect(r.desktop, greaterThanOrEqualTo(r.tablet));
      }
    });
  });

  group('other tokens match the design', () {
    test('spacing', () {
      expect(AppSpacing.md.mobile, 16);
      expect(AppSpacing.md.tablet, 20);
      expect(AppSpacing.md.desktop, 24);
      expect(AppSpacing.giant.desktop, 112);
    });

    test('component sizes', () {
      expect(AppComponentSize.small.mobile, 36);
      expect(AppComponentSize.hitArea.mobile, 44);
      expect(AppComponentSize.large.mobile, 48);
      expect(AppComponentSize.avatar.desktop, 56);
    });

    test('elevation', () {
      expect(AppElevation.md.mobile, 4);
      expect(AppElevation.lg.desktop, 16);
    });

    test('border widths: thin 1, thick 2 on every device', () {
      for (final w in [AppBorderWidth.thin]) {
        expect([w.mobile, w.tablet, w.desktop], [1, 1, 1]);
      }
      for (final w in [AppBorderWidth.thick]) {
        expect([w.mobile, w.tablet, w.desktop], [2, 2, 2]);
      }
    });
  });

  group('AppGrid', () {
    test('columns / margin / gutter per device class', () {
      expect(AppGrid.mobile.columns, 4);
      expect(AppGrid.mobile.margin, 16);
      expect(AppGrid.mobile.gutter, 12);
      expect(AppGrid.tablet.columns, 8);
      expect(AppGrid.tablet.margin, 24);
      expect(AppGrid.tablet.gutter, 16);
      expect(AppGrid.desktop.columns, 12);
      expect(AppGrid.desktop.margin, 32);
      expect(AppGrid.desktop.gutter, 24);
    });

    test('forType picks the matching grid', () {
      expect(AppGrid.forType(ScreenType.mobile), AppGrid.mobile);
      expect(AppGrid.forType(ScreenType.tablet), AppGrid.tablet);
      expect(AppGrid.forType(ScreenType.desktop), AppGrid.desktop);
    });
  });

  group('AppDensity', () {
    test('comfortable: row 48, header 40, field 44', () {
      expect(AppDensity.comfortable.row, 48);
      expect(AppDensity.comfortable.header, 40);
      expect(AppDensity.comfortable.field, 44);
    });

    test('compact: row 36, header 32, field 36', () {
      expect(AppDensity.compact.row, 36);
      expect(AppDensity.compact.header, 32);
      expect(AppDensity.compact.field, 36);
    });

    test('compact keeps the 44 touch target on a phone only', () {
      expect(AppDensity.compact.rowHeight(ScreenType.mobile), 44);
      expect(AppDensity.compact.fieldHeight(ScreenType.mobile), 44);
      expect(AppDensity.compact.headerHeight(ScreenType.mobile), 44);
      expect(AppDensity.compact.rowHeight(ScreenType.desktop), 36);
      expect(AppDensity.compact.fieldHeight(ScreenType.tablet), 36);
      expect(AppDensity.comfortable.rowHeight(ScreenType.mobile), 48);
    });
  });
}
