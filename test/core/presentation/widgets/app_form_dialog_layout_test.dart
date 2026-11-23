import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:accounting_software/app/core/localization/keys/common_keys.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_form_dialog/app_form_dialog.dart';

import '../../../helpers/localized_app.dart';

void main() {
  setUpAll(() => useTranslations(const Locale('en')));

  testWidgets('desktop dialog wraps short form content', (tester) async {
    setScreenSize(tester, const Size(1440, 900));
    await tester.pumpWidget(_appWithDialogContent(const SizedBox(height: 72)));

    await tester.tap(find.text('Open dialog'));
    await tester.pumpAndSettle();

    expect(find.byType(Dialog), findsOneWidget);
    // `Dialog` itself is the full-screen centering wrapper; measure the form.
    expect(tester.getSize(find.byType(AppFormDialog)).height, lessThan(500));
    expect(tester.takeException(), isNull);
  });

  testWidgets('desktop dialog scrolls long form content without overflow', (
    tester,
  ) async {
    setScreenSize(tester, const Size(1440, 900));
    await tester.pumpWidget(
      _appWithDialogContent(const SizedBox(height: 1400)),
    );

    await tester.tap(find.text('Open dialog'));
    await tester.pumpAndSettle();

    expect(find.byType(Dialog), findsOneWidget);
    expect(find.byType(SingleChildScrollView), findsOneWidget);
    expect(find.text('Cancel'), findsOneWidget);
    expect(find.text('Save').last, findsOneWidget);
    await tester.drag(
      find.byType(SingleChildScrollView),
      const Offset(0, -600),
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    '800x400 landscape keeps sheet actions fixed while content scrolls',
    (tester) async {
      setScreenSize(tester, const Size(800, 400));
      await tester.pumpWidget(
        _appWithDialogContent(
          Column(
            children: [
              const SizedBox(height: 1200),
              const Text('End of long form'),
            ],
          ),
        ),
      );

      await tester.tap(find.text('Open dialog'));
      await tester.pumpAndSettle();

      expect(find.byType(BottomSheet), findsOneWidget);
      expect(find.byType(SingleChildScrollView), findsOneWidget);
      final cancel = tester.getRect(find.text('Cancel'));
      final save = tester.getRect(find.text('Save').last);
      final endOfForm = find.text('End of long form');
      expect(cancel.top, greaterThanOrEqualTo(0));
      expect(save.bottom, lessThanOrEqualTo(400));
      expect(tester.getRect(endOfForm).top, greaterThan(400));

      await tester.drag(
        find.byType(SingleChildScrollView),
        const Offset(0, -1000),
      );
      await tester.pumpAndSettle();

      expect(tester.getRect(endOfForm).bottom, lessThanOrEqualTo(400));
      expect(tester.getRect(find.text('Save').last), save);
      expect(tester.takeException(), isNull);
    },
  );
  testWidgets(
    'short desktop dialog keeps actions fixed while content scrolls',
    (tester) async {
      setScreenSize(tester, const Size(1200, 400));
      await tester.pumpWidget(
        _appWithDialogContent(
          Column(
            children: [
              const SizedBox(height: 1200),
              const Text('End of long form'),
            ],
          ),
        ),
      );

      await tester.tap(find.text('Open dialog'));
      await tester.pumpAndSettle();

      expect(find.byType(Dialog), findsOneWidget);
      expect(find.byType(SingleChildScrollView), findsOneWidget);
      final cancel = tester.getRect(find.text('Cancel'));
      final save = tester.getRect(find.text('Save').last);
      final endOfForm = find.text('End of long form');
      expect(cancel.top, greaterThanOrEqualTo(0));
      expect(save.bottom, lessThanOrEqualTo(400));
      expect(tester.getRect(endOfForm).top, greaterThan(400));

      await tester.drag(
        find.byType(SingleChildScrollView),
        const Offset(0, -1000),
      );
      await tester.pumpAndSettle();

      expect(tester.getRect(endOfForm).bottom, lessThanOrEqualTo(400));
      expect(tester.getRect(find.text('Save').last), save);
      expect(tester.takeException(), isNull);
    },
  );
}

Widget _appWithDialogContent(Widget content) => buildTestApp(
  direction: TextDirection.ltr,
  home: Builder(
    builder: (context) => Scaffold(
      body: Center(
        child: TextButton(
          onPressed: () {
            showAppFormDialog<void>(
              context,
              (_) => AppFormDialog(
                titleKey: CommonKeys.save,
                child: content,
                onSave: () async {},
              ),
            );
          },
          child: const Text('Open dialog'),
        ),
      ),
    ),
  ),
);
