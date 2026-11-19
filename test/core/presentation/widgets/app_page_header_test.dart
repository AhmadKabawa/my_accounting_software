import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:accounting_software/app/core/localization/keys/template_keys.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_page_header/app_page_header.dart';
import '../../../helpers/localized_app.dart';

void main() {
  setUpAll(() => useTranslations(const Locale('en')));
  testWidgets('narrow width stacks the action below the heading', (
    tester,
  ) async {
    await tester.pumpWidget(
      buildTestApp(
        home: Scaffold(
          body: Center(
            child: SizedBox(
              width: 240,
              child: AppPageHeader(
                titleKey: TemplateKeys.defaultError,
                primaryAction: const Text('Action'),
              ),
            ),
          ),
        ),
      ),
    );
    expect(
      tester.getTopLeft(find.text('Action')).dy,
      greaterThanOrEqualTo(
        tester.getBottomLeft(find.text(TemplateKeys.defaultError.en)).dy,
      ),
    );
  });

  testWidgets('wide width keeps the action beside the heading', (tester) async {
    await tester.pumpWidget(
      buildTestApp(
        home: Scaffold(
          body: SizedBox(
            width: 1000,
            child: AppPageHeader(
              titleKey: TemplateKeys.defaultError,
              primaryAction: const Text('Action'),
            ),
          ),
        ),
      ),
    );
    expect(
      tester.getTopLeft(find.text('Action')).dy,
      lessThan(
        tester.getBottomLeft(find.text(TemplateKeys.defaultError.en)).dy + 1,
      ),
    );
  });

  testWidgets('count is isolated and may be omitted', (tester) async {
    await tester.pumpWidget(
      buildTestApp(
        home: const Scaffold(
          body: Column(
            children: [
              AppPageHeader(titleKey: TemplateKeys.save, count: 12),
              AppPageHeader(titleKey: TemplateKeys.defaultError),
            ],
          ),
        ),
      ),
    );
    expect(find.text('\u2068(12)\u2069'), findsOneWidget);
    expect(find.text('()'), findsNothing);
  });
}
