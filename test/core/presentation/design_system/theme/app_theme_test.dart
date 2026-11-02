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

    test('keeps letter spacing at 0 so Arabic letters stay joined', () {
      expect(AppTheme.light().textTheme.bodyMedium!.letterSpacing, 0);
      expect(AppTheme.dark().textTheme.bodyMedium!.letterSpacing, 0);
    });
  });
}
