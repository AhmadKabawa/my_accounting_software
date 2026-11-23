import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_data_view/app_data_view.dart';
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
}
