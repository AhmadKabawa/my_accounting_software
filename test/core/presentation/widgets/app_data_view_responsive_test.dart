import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_data_view/app_data_view.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_data_view/app_view_mode.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_skeleton/app_skeleton.dart';
import '../../../helpers/localized_app.dart';

void main() {
  testWidgets('default view mode follows available content width, not device width', (tester) async {
    tester.view.physicalSize = const Size(1600, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    AppViewMode? narrow;
    AppViewMode? wide;
    await tester.pumpWidget(buildTestApp(
      home: Builder(builder: (context) {
        narrow = AppDataView.defaultModeFor(context, availableWidth: 640);
        wide = AppDataView.defaultModeFor(context, availableWidth: 900);
        return const SizedBox.shrink();
      }),
    ));
    expect(narrow, AppViewMode.cards);
    expect(wide, AppViewMode.table);
  });
  testWidgets('loading skeleton follows narrow content width on a desktop viewport', (tester) async {
    tester.view.physicalSize = const Size(1600, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(buildTestApp(home: Scaffold(
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
    )));
    expect(
      find.byWidgetPredicate(
        (widget) => widget is AppSkeleton &&
            widget.variant == AppSkeletonVariant.card,
      ),
      findsNWidgets(5),
    );
    expect(
      find.byWidgetPredicate(
        (widget) => widget is AppSkeleton &&
            widget.variant == AppSkeletonVariant.tableRow,
      ),
      findsNothing,
    );
    expect(tester.takeException(), isNull);
  });
}
