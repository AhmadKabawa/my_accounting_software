import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:accounting_software/app/core/localization/keys/common_keys.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_switch/app_switch.dart';
import '../../../../helpers/localized_app.dart';

Future<void> _pump(
  WidgetTester tester, {
  required bool loading,
  required VoidCallback onChanged,
}) => tester.pumpWidget(
  buildTestApp(
    home: Scaffold(
      body: AppSwitch(
        value: false,
        semanticsKey: CommonKeys.save,
        loading: loading,
        onChanged: (_) => onChanged(),
      ),
    ),
  ),
);

void main() {
  setUp(() => useTranslations(const Locale('en')));

  testWidgets('loading shows a spinner and ignores taps', (tester) async {
    var changes = 0;
    await _pump(tester, loading: true, onChanged: () => changes++);

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    await tester.tap(find.byType(Switch));
    await tester.pump();

    expect(changes, 0);
  });

  testWidgets('idle shows no spinner and reports the change', (tester) async {
    var changes = 0;
    await _pump(tester, loading: false, onChanged: () => changes++);

    expect(find.byType(CircularProgressIndicator), findsNothing);
    await tester.tap(find.byType(Switch));
    await tester.pump();

    expect(changes, 1);
  });
}
