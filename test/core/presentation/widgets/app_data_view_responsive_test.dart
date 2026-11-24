import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_data_view/app_data_view.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_card/app_card.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_skeleton/app_skeleton.dart';
import '../../../helpers/localized_app.dart';

void main() {
  testWidgets(
    'default view mode follows available content width, not device width',
    (tester) async {
      tester.view.physicalSize = const Size(1600, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      AppViewMode? narrow;
      AppViewMode? wide;
      await tester.pumpWidget(
        buildTestApp(
          home: Builder(
            builder: (context) {
              narrow = AppDataView.defaultModeFor(context, availableWidth: 640);
              wide = AppDataView.defaultModeFor(context, availableWidth: 900);
              return const SizedBox.shrink();
            },
          ),
        ),
      );
      expect(narrow, AppViewMode.cards);
      expect(wide, AppViewMode.table);
    },
  );
  testWidgets(
    'loading skeleton follows narrow content width on a desktop viewport',
    (tester) async {
      tester.view.physicalSize = const Size(1600, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(
        buildTestApp(
          home: Scaffold(
            body: Align(
              alignment: AlignmentDirectional.topStart,
              child: SizedBox(
                width: 360,
                child: AppDataView<int>(
                  columns: const [],
                  rows: const [],
                  rowId: (value) => value,
                  loading: true,
                ),
              ),
            ),
          ),
        ),
      );
      expect(
        find.byWidgetPredicate(
          (widget) =>
              widget is AppSkeleton &&
              widget.variant == AppSkeletonVariant.card,
        ),
        findsAtLeastNWidgets(1),
      );
      expect(
        find.byWidgetPredicate(
          (widget) =>
              widget is AppSkeleton &&
              widget.variant == AppSkeletonVariant.tableRow,
        ),
        findsNothing,
      );
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('grid rows fit long content at narrow and wide widths', (
    tester,
  ) async {
    addTearDown(tester.view.reset);
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    final longName = List.filled(12, 'BrandWithoutSpaces').join();
    for (final width in [280.0, 360.0, 700.0, 1400.0]) {
      for (final scale in [1.0, 1.5]) {
        for (final direction in TextDirection.values) {
          tester.view.physicalSize = Size(width, 1000);
          tester.view.devicePixelRatio = 1;
          tester.platformDispatcher.textScaleFactorTestValue = scale;
          await tester.pumpWidget(
            buildTestApp(
              direction: direction,
              home: Scaffold(
                body: AppDataView<String>(
                  columns: const [],
                  rows: [
                    for (var i = 0; i < 6; i++) i.isEven ? 'Short' : longName,
                  ],
                  rowId: (value) => value,
                  mode: AppViewMode.grid,
                  gridItemBuilder: (_, value) => Text(
                    value,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ),
          );
          expect(
            tester.takeException(),
            isNull,
            reason:
                'Grid overflow at width $width, text scale $scale, direction $direction',
          );
        }
      }
    }
  });

  testWidgets('grid tiles with LayoutBuilder content avoid intrinsic sizing', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1400, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    var selected = <Object>{};
    await tester.pumpWidget(
      buildTestApp(
        home: StatefulBuilder(
          builder: (context, setState) => Scaffold(
            body: AppDataView<String>(
              columns: const [],
              rows: const [
                'Short',
                'A much longer name that wraps onto two lines',
              ],
              rowId: (value) => value,
              mode: AppViewMode.grid,
              selectedIds: selected,
              onSelectionChanged: (next) => setState(() => selected = next),
              gridItemBuilder: (_, value) => LayoutBuilder(
                builder: (context, constraints) =>
                    Text('$value ${constraints.maxWidth}'),
              ),
            ),
          ),
        ),
      ),
    );
    final tiles = find.byType(AppCard);
    expect(tiles, findsNWidgets(2));
    final firstHeight = tester.getSize(tiles.at(0)).height;
    final secondHeight = tester.getSize(tiles.at(1)).height;
    expect(firstHeight, greaterThan(0));
    expect(secondHeight, firstHeight);

    await tester.tap(find.byType(Checkbox).first);
    await tester.pump();
    expect(selected, contains('Short'));
    expect(tester.getSize(tiles.at(0)).height, firstHeight);
    expect(tester.getSize(tiles.at(1)).height, secondHeight);
    expect(
      tester.getSize(tiles.at(0)).height,
      tester.getSize(tiles.at(1)).height,
    );
    expect(tester.takeException(), isNull);
  });
}
