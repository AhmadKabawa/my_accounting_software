import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:accounting_software/app/core/localization/keys/common_keys.dart';
import 'package:accounting_software/app/core/presentation/design_system/theme/app_theme.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_date_picker_field/app_date_picker_field.dart';
import '../../../helpers/localized_app.dart';

void main() {
  setUpAll(() => useTranslations(const Locale('en')));

  testWidgets('opens picker and returns a normalized date', (tester) async {
    DateTime? selected;
    await tester.pumpWidget(buildTestApp(home: Scaffold(body: AppDatePickerField(
      label: CommonKeys.updatedAt, value: DateTime(2026, 11, 1),
      onChanged: (value) => selected = value,
    ))));
    await tester.tap(find.byType(TextFormField));
    await tester.pumpAndSettle();
    await tester.tap(find.text('15').last);
    await tester.pumpAndSettle();
    expect(selected, isNotNull);
    expect(selected!.hour, 0);
    expect(selected!.minute, 0);
  });

  testWidgets('clear action emits null', (tester) async {
    DateTime? selected = DateTime(2026, 11, 27);
    await tester.pumpWidget(buildTestApp(home: Scaffold(body: AppDatePickerField(
      label: CommonKeys.updatedAt, value: selected, clearable: true,
      onChanged: (value) => selected = value,
    ))));
    await tester.tap(find.byTooltip('Clear date'));
    expect(selected, isNull);
  });

  testWidgets('picker receives first and last date bounds', (tester) async {
    await tester.pumpWidget(buildTestApp(home: Scaffold(body: AppDatePickerField(
      label: CommonKeys.updatedAt, value: DateTime(2026, 11, 15),
      firstDate: DateTime(2026, 11, 10), lastDate: DateTime(2026, 11, 20),
      onChanged: (_) {},
    ))));
    await tester.tap(find.byType(TextFormField));
    await tester.pumpAndSettle();
    final dialog = tester.widget<DatePickerDialog>(find.byType(DatePickerDialog));
    expect(dialog.firstDate, DateTime(2026, 11, 10));
    expect(dialog.lastDate, DateTime(2026, 11, 20));
  });

  testWidgets('disabled field does not open picker', (tester) async {
    await tester.pumpWidget(buildTestApp(home: Scaffold(body: AppDatePickerField(
      label: CommonKeys.updatedAt, value: null, enabled: false, onChanged: (_) {},
    ))));
    await tester.tap(find.byType(TextFormField));
    await tester.pumpAndSettle();
    expect(find.byType(DatePickerDialog), findsNothing);
  });

  testWidgets('280px RTL dark layout at 1.5 scale has no overflow', (tester) async {
    tester.view.physicalSize = const Size(280, 700);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(buildTestApp(
      direction: TextDirection.rtl, textScale: 1.5, theme: AppTheme.dark(),
      home: Scaffold(body: AppDatePickerField(
        label: CommonKeys.updatedAt, value: DateTime(2026, 11, 27),
        clearable: true, onChanged: (_) {},
      )),
    ));
    expect(tester.takeException(), isNull);
  });
}
