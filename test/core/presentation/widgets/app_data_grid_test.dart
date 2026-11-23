import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_card/app_card.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_data_view/app_data_grid.dart';
import '../../../helpers/localized_app.dart';

Future<void> _pump(
  WidgetTester tester, {
  Size size = const Size(1280, 800),
  Set<Object>? selected,
}) async {
  setScreenSize(tester, size);
  await tester.pumpWidget(
    buildTestApp(
      home: Scaffold(
        body: AppDataGrid<String>(
          rows: const ['short', 'a very long record name\nwith\nthree\nlines'],
          rowId: (row) => row,
          gridItemBuilder: (_, row) => Text(row),
          selectedIds: selected ?? const {},
          onSelectionChanged: selected == null ? null : (_) {},
          rowActionsBuilder: (_, _) => Row(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Icon(Icons.edit),
              Icon(Icons.copy),
              Icon(Icons.delete),
              Icon(Icons.toggle_on),
            ],
          ),
        ),
      ),
    ),
  );
}

void main() {
  setUp(() => useTranslations(const Locale('en')));

  testWidgets('tiles in one row share the tallest tile height', (tester) async {
    await _pump(tester);

    final cards = find.byType(AppCard);
    expect(cards, findsNWidgets(2));
    expect(
      tester.getSize(cards.at(0)).height,
      tester.getSize(cards.at(1)).height,
    );
  });

  testWidgets('selection mode keeps equal and unchanged heights', (
    tester,
  ) async {
    await _pump(tester);
    final before = tester.getSize(find.byType(AppCard).first).height;

    await _pump(tester, selected: {'short'});

    final cards = find.byType(AppCard);
    expect(tester.getSize(cards.at(0)).height, before);
    expect(
      tester.getSize(cards.at(0)).height,
      tester.getSize(cards.at(1)).height,
    );
  });

  testWidgets('checkbox and actions do not overlap on a narrow tile', (
    tester,
  ) async {
    await _pump(tester, size: const Size(280, 800), selected: {});

    final checkbox = tester.getRect(find.byType(Checkbox).first);
    final actions = tester.getRect(find.byIcon(Icons.edit).first);
    expect(checkbox.overlaps(actions), isFalse);
    expect(tester.takeException(), isNull);
  });
}
