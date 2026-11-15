import 'package:flutter_test/flutter_test.dart';
import 'package:accounting_software/app/core/presentation/design_system/responsive/engine/app_enums.dart';
import 'package:accounting_software/app/core/presentation/design_system/theme/app_theme.dart';

void main() {
  group('theme without a BuildContext', () {
    test('AppTheme builds with the mobile baseline sizes', () {
      final theme = AppTheme.light();

      expect(theme.textTheme.bodyMedium!.fontSize, AppFontSize.base.mobile);
      expect(theme.textTheme.bodyLarge!.fontSize, AppFontSize.md.mobile);
      expect(theme.navigationBarTheme.height, AppSpacing.xl.mobile);
    });

    test('dark theme uses the same baseline sizes', () {
      expect(
        AppTheme.dark().textTheme.bodyMedium!.fontSize,
        AppFontSize.base.mobile,
      );
    });

    test('the smallest theme text is 12 and body text has 1.5 line height', () {
      for (final theme in [AppTheme.light(), AppTheme.dark()]) {
        final t = theme.textTheme;
        for (final style in [
          t.displayLarge, t.displayMedium, t.displaySmall, t.headlineLarge,
          t.headlineMedium, t.headlineSmall, t.titleLarge, t.titleMedium,
          t.titleSmall, t.bodyLarge, t.bodyMedium, t.bodySmall, t.labelLarge,
          t.labelMedium, t.labelSmall,
        ]) {
          expect(style!.fontSize, greaterThanOrEqualTo(12));
        }
        expect(t.bodyMedium!.height, 1.5);
      }
    });

    test('keeps letter spacing at 0 so Arabic letters stay joined', () {
      expect(AppTheme.light().textTheme.bodyMedium!.letterSpacing, 0);
      expect(AppTheme.dark().textTheme.bodyMedium!.letterSpacing, 0);
    });
  });
}
