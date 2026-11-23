import 'dart:io';

import 'package:accounting_software/app/core/error/exceptions/api_exception.dart';
import 'package:accounting_software/app/core/error/failures/failure.dart';
import 'package:accounting_software/app/core/error/mappers/exception_mapper.dart';
import 'package:accounting_software/app/core/error/translators/failure_translator.dart';
import 'package:accounting_software/app/core/foundation/types/api_result.dart';
import 'package:accounting_software/app/core/localization/keys/erp_error_keys.dart';
import 'package:accounting_software/app/core/localization/translations/asset_loader.dart';
import 'package:accounting_software/app/core/network/api_end_points.dart';
import 'package:accounting_software/app/core/network/dio/api_client.dart';
import 'package:accounting_software/app/core/network/dio/dio_service.dart';
import 'package:accounting_software/app/core/platform/platform_capabilities.dart';
import 'package:accounting_software/app/core/network/dio/interceptors/language_interceptor.dart';
import 'package:accounting_software/app/core/network/network_info/network_info.dart';
import 'package:accounting_software/app/core/storage/secure/token_manager.dart';
import 'package:accounting_software/app/localization/key_registry.dart';
// ignore: implementation_imports
import 'package:easy_localization/src/localization.dart';
// ignore: implementation_imports
import 'package:easy_localization/src/translations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/memory_storage.dart';
import '../network/fake_adapter.dart';

class _Online implements NetworkInfo {
  @override
  Future<bool> get isConnected async => true;
}

class _Lang implements LanguageProvider {
  @override
  String get currentLocale => 'ar';
}

const _endpoint = AppEndpoint('/rest/v1/rpc/post_invoice');

ApiClient _clientFor(int status, String body) {
  final service = DioService(
    tokenManager: TokenManager(storage: MemoryStorage()),
    networkInfoImpl: _Online(),
    languageProvider: _Lang(),
    refreshEndpoint: const AppEndpoint('/auth/v1/token'),
    requestSendTimeoutCapability: const PlatformRequestSendTimeoutCapability(),
  );
  service.dio.httpClientAdapter = RoutedAdapter(
    (_) async => RoutedAdapter.json(status, body),
  );
  return ApiClient(dioService: service);
}

Future<Failure> _failureOf(int status, String body) async {
  final result = await _clientFor(
    status,
    body,
  ).post<Map<String, dynamic>>(_endpoint, fromJson: (j) => j);
  return ExceptionMapper.map((result as ApiFailure).exception);
}

Future<void> _useLocale(Locale locale) async {
  final translations = await MyDartLoader(allKeys).load('', locale);
  Localization.load(locale, translations: Translations(translations));
}

void main() {
  group('ErpErrorKeys', () {
    test('covers every code of DATA_MODEL section 5 with ar and en', () {
      final doc = File('docs/backend/DATA_MODEL.md').readAsStringSync();
      final codes = RegExp(
        r'^\| (ERP\d\d) \|',
        multiLine: true,
      ).allMatches(doc).map((m) => m.group(1)!).toSet();

      expect(codes.length, 29);
      final known = ErpErrorKeys.values.map((k) => k.code).whereType<String>();
      expect(known.toSet(), codes);
      for (final k in ErpErrorKeys.values) {
        expect(k.ar.trim(), isNotEmpty);
        expect(k.en.trim(), isNotEmpty);
      }
    });

    test('an unknown well-formed code gives the generic text', () {
      expect(ErpErrorKeys.fromCode('ERP99'), ErpErrorKeys.unknown);
      expect(ErpErrorKeys.fromCode(null), ErpErrorKeys.unknown);
    });

    test('only ERP + two digits is a business-rule code', () {
      expect(ErpErrorKeys.isErpCode('ERP22'), isTrue);
      expect(ErpErrorKeys.isErpCode('ERP2'), isFalse);
      expect(ErpErrorKeys.isErpCode('ERP222'), isFalse);
      expect(ErpErrorKeys.isErpCode('erp22'), isFalse);
      expect(ErpErrorKeys.isErpCode('23505'), isFalse);
      expect(ErpErrorKeys.isErpCode(null), isFalse);
    });
  });

  group('from a PostgREST response to the failure', () {
    const body =
        '{"code":"ERP04","message":"raw server text","details":"item=7","hint":null}';

    test('a business-rule error keeps its code and details', () async {
      final result = await _clientFor(
        400,
        body,
      ).post<Map<String, dynamic>>(_endpoint, fromJson: (j) => j);
      final e = (result as ApiFailure).exception as ApiException;

      expect(e.type, ApiExceptionType.businessRule);
      expect(e.errorCode, 'ERP04');
      expect(e.details, 'item=7');
      expect(e.message, 'raw server text');
      expect(e.toString(), contains('ERP04'));
    });

    test('is mapped to the translated key, not the server text', () async {
      final failure = await _failureOf(400, body);

      expect(failure, isA<ValidationFailure>());
      expect(failure.messageKey, ErpErrorKeys.insufficientStock);
    });

    test('ERP16 is a permission failure', () async {
      final failure = await _failureOf(
        400,
        '{"code":"ERP16","message":"x","details":null}',
      );

      expect(failure, isA<PermissionFailure>());
      expect(failure.messageKey, ErpErrorKeys.permissionDenied);
    });

    test('an unknown ERP code never shows the raw text', () async {
      final failure = await _failureOf(
        400,
        '{"code":"ERP99","message":"raw server text"}',
      );

      expect(failure.messageKey, ErpErrorKeys.unknown);
    });

    test('a non-ERP database error keeps the old mapping', () async {
      final result = await _clientFor(
        409,
        '{"code":"23505","message":"duplicate key value"}',
      ).post<Map<String, dynamic>>(_endpoint, fromJson: (j) => j);
      final e = (result as ApiFailure).exception as ApiException;

      expect(e.type, ApiExceptionType.conflict);
      expect(e.errorCode, '23505');
    });

    for (final locale in const [Locale('ar'), Locale('en')]) {
      test('shows the ${locale.languageCode} text to the user', () async {
        await _useLocale(locale);
        final failure = await _failureOf(400, body);

        expect(
          FailureTranslator.translate(failure),
          locale.languageCode == 'ar'
              ? ErpErrorKeys.insufficientStock.ar
              : ErpErrorKeys.insufficientStock.en,
        );
      });
    }
  });
}
