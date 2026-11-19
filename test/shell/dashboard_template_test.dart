import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:accounting_software/app/core/localization/keys/template_keys.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_empty_state/app_empty_state.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_inline_banner/inline_banner.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_page_template/app_page_templates.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_skeleton/app_skeleton.dart';
import '../helpers/localized_app.dart';

void main() {
  setUpAll(() => useTranslations(const Locale('en')));
  Future<void> pump(
    WidgetTester tester,
    AppPageState state, {
    List<Widget> cards = const [],
  }) async {
    await tester.pumpWidget(
      buildTestApp(
        home: Scaffold(
          body: DashboardTemplate(
            titleKey: TemplateKeys.defaultError,
            state: state,
            cards: cards,
          ),
        ),
      ),
    );
    expect(tester.takeException(), isNull);
  }

  testWidgets('loading state renders skeleton', (tester) async {
    await pump(tester, AppPageState.loading);
    expect(find.byType(AppSkeleton), findsWidgets);
  });
  testWidgets('empty state renders empty content', (tester) async {
    await pump(tester, AppPageState.empty);
    expect(find.byType(AppEmptyState), findsOneWidget);
  });
  testWidgets('error state renders the default error banner', (tester) async {
    await pump(tester, AppPageState.error);
    expect(find.byType(InlineBanner), findsOneWidget);
  });
  testWidgets('content state renders a card grid', (tester) async {
    await pump(
      tester,
      AppPageState.content,
      cards: const [
        ColoredBox(color: Colors.red),
        ColoredBox(color: Colors.blue),
      ],
    );
    expect(find.byType(GridView), findsOneWidget);
  });
}
