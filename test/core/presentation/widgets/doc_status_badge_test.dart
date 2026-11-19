import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:accounting_software/app/core/localization/keys/badge_keys.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_badge/app_badge.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_badge/doc_status_badge.dart';
import '../helpers/localized_app.dart';

void main() {
  setUpAll(() => useTranslations(const Locale('en')));

  final cases = <(String, String)>[
    ('DRAFT', BadgeKeys.draft.en),
    ('POSTED', BadgeKeys.posted.en),
    ('REVERSED', BadgeKeys.reversed.en),
    ('CANCELLED', BadgeKeys.cancelled.en),
    ('UNPAID', BadgeKeys.unpaid.en),
    ('PARTIAL', BadgeKeys.partial.en),
    ('PAID', BadgeKeys.paid.en),
  ];

  for (final (status, label) in cases) {
    testWidgets('$status displays its translated label', (tester) async {
      await tester.pumpWidget(
        buildTestApp(
          home: DocStatusBadge(status: status),
        ),
      );
      expect(find.text(label), findsOneWidget);
      expect(find.byType(AppBadge), findsOneWidget);
    });
  }

  testWidgets('unknown status displays a neutral fallback without crashing', (
    tester,
  ) async {
    await tester.pumpWidget(
      buildTestApp(home: const DocStatusBadge(status: 'NOT_DOCUMENTED')),
    );
    expect(find.text(BadgeKeys.unknown.en), findsOneWidget);
    expect(find.byType(AppBadge), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('status matching ignores surrounding whitespace and case', (
    tester,
  ) async {
    await tester.pumpWidget(
      buildTestApp(home: const DocStatusBadge(status: '  unpaid  ')),
    );
    expect(find.text(BadgeKeys.unpaid.en), findsOneWidget);
  });
}
