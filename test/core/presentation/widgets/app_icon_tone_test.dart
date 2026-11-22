import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:accounting_software/app/core/presentation/design_system/theme/app_theme.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_icon/app_icon.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_icon/app_icons.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_icon/app_icon_tone.dart';
import '../../../helpers/localized_app.dart';

double _luminance(Color color) {
  double channel(int value) {
    final v = value / 255;
    return v <= 0.04045 ? v / 12.92 : ((v + 0.055) / 1.055) * ((v + 0.055) / 1.055) * ((v + 0.055) / 1.055);
  }
  return 0.2126 * channel(color.red) + 0.7152 * channel(color.green) + 0.0722 * channel(color.blue);
}
double _ratio(Color a, Color b) {
  final la = _luminance(a), lb = _luminance(b);
  return (la > lb ? la + 0.05 : lb + 0.05) / (la > lb ? lb + 0.05 : la + 0.05);
}
void main() {
  setUpAll(() => useTranslations(const Locale('en')));
  testWidgets('each tone has at least 3:1 contrast on surface in both themes', (tester) async {
    for (final theme in [AppTheme.light(), AppTheme.dark()]) {
      for (final tone in AppIconTone.values) {
        await tester.pumpWidget(buildTestApp(theme: theme, home: const Scaffold(body: AppIcon(AppIcons.add))));
        await tester.pumpWidget(buildTestApp(theme: theme, home: Scaffold(body: AppIcon(AppIcons.add, tone: tone))));
        final icon = tester.widget<Icon>(find.byType(Icon).first);
        final surface = theme.colorScheme.surface;
        expect(_ratio(icon.color!, surface), greaterThanOrEqualTo(3), reason: tone.name);
      }
    }
  });
}
