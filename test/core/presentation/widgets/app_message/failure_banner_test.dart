import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:accounting_software/app/core/error/exceptions/api_exception.dart';
import 'package:accounting_software/app/core/error/failures/failure.dart';
import 'package:accounting_software/app/core/error/mappers/exception_mapper.dart';
import 'package:accounting_software/app/core/localization/keys/error_keys.dart';
import 'package:accounting_software/app/core/localization/keys/erp_error_keys.dart';
import 'package:accounting_software/app/core/localization/keys/message_keys.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_inline_banner/inline_banner.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_message/message_view_widgets.dart';

import '../../../../helpers/localized_app.dart';

/// Fragments that must never reach the screen: SQL, table names, internals.
const _leaks = [
  'SQL',
  'relation',
  'constraint',
  'duplicate key',
  'public.',
  'invoices',
  'products',
  'Key (',
  'NoSuchMethodError',
  'package:',
];

Future<void> _pump(WidgetTester tester, Failure failure, {Locale? locale}) {
  useTranslations(locale ?? const Locale('ar'));
  setScreenSize(tester, const Size(360, 800));
  return tester.pumpWidget(
    buildTestApp(
      home: Scaffold(
        body: Column(children: [MessageViewWidgets.failureBanner(failure)]),
      ),
    ),
  );
}

String _allText(WidgetTester tester) =>
    tester.widgetList<Text>(find.byType(Text)).map((t) => t.data ?? '').join();

void main() {
  group('input errors are told apart from system errors', () {
    test('a validation / business-rule failure gets the validation title', () {
      final banner = MessageViewWidgets.failureBanner(
        const ValidationFailure(messageKey: ErpErrorKeys.periodClosed),
      );

      expect(banner.titleKey, MessageKeys.validationTitle);
      expect(banner.messageKey, ErpErrorKeys.periodClosed);
      expect(banner.variant, InlineBannerVariant.error);
    });

    for (final failure in const <Failure>[
      NetworkFailure(),
      ServerFailure(),
      UnexpectedFailure(),
      CacheFailure(),
    ]) {
      test('${failure.runtimeType} gets the system title', () {
        final banner = MessageViewWidgets.failureBanner(failure);

        expect(banner.titleKey, MessageKeys.systemTitle);
        expect(banner.messageKey, failure.messageKey);
      });
    }

    for (final failure in const <Failure>[
      UnauthorizedFailure(),
      PermissionFailure(),
      NotFoundFailure(),
    ]) {
      test('${failure.runtimeType} has no title: the text alone', () {
        final banner = MessageViewWidgets.failureBanner(failure);

        expect(banner.titleKey, isNull);
        expect(banner.messageKey, failure.messageKey);
      });
    }

    test('onDismiss is passed to the banner', () {
      var closed = 0;
      final banner = MessageViewWidgets.failureBanner(
        const ServerFailure(),
        onDismiss: () => closed++,
      );

      banner.onDismiss!();
      expect(closed, 1);
    });
  });

  group('raw server text never reaches the screen', () {
    final cases = <String, ApiException>{
      'business rule with SQL in its message and details': ApiException.erp(
        errorCode: 'ERP08',
        serverMessage:
            'new row violates check constraint "periods_chk" on table '
            'public.products',
        details: 'Key (sku)=(A1) already exists in public.invoices',
      ),
      'unknown business rule code': ApiException.erp(
        errorCode: 'ERP99',
        serverMessage: 'duplicate key value violates unique constraint',
      ),
      'server error naming a relation': ApiException.server(
        statusCode: 500,
        serverMessage:
            'ERROR: relation "public.invoices" does not exist (SQLSTATE 42P01)',
      ),
      'internal exception text': ApiException.unknown(
        serverMessage: 'NoSuchMethodError at package:app/products.dart:12',
      ),
    };

    for (final locale in const [Locale('ar'), Locale('en')]) {
      for (final entry in cases.entries) {
        testWidgets('${entry.key} (${locale.languageCode})', (tester) async {
          final failure = ExceptionMapper.map(entry.value);
          await _pump(tester, failure, locale: locale);

          final english = locale.languageCode == 'en';
          final expected = english
              ? failure.messageKey.en
              : failure.messageKey.ar;
          expect(find.text(expected), findsOneWidget);

          final shown = _allText(tester);
          for (final leak in _leaks) {
            expect(shown, isNot(contains(leak)), reason: 'leaked: $leak');
          }
        });
      }
    }
  });

  testWidgets('a rule failure shows the title and its translated text', (
    tester,
  ) async {
    await _pump(
      tester,
      const ValidationFailure(messageKey: ErpErrorKeys.periodClosed),
    );

    expect(find.text(MessageKeys.validationTitle.ar), findsOneWidget);
    expect(find.text(ErpErrorKeys.periodClosed.ar), findsOneWidget);
  });

  testWidgets('a system failure shows the system title', (tester) async {
    await _pump(tester, const ServerFailure(messageKey: ErrorKeys.server));

    expect(find.text(MessageKeys.systemTitle.ar), findsOneWidget);
    expect(find.text(ErrorKeys.server.ar), findsOneWidget);
    expect(find.text(MessageKeys.validationTitle.ar), findsNothing);
  });
}
