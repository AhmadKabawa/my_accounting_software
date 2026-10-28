// lib/core/network/interceptors/logger_interceptor.dart

import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

const _masked = '***';

final _sensitiveKey = RegExp(
  r'password|passwd|token|secret|authorization|api[_-]?key|^(code|otp|pin)$',
  caseSensitive: false,
);

/// Returns a copy of [data] safe to print: values under sensitive keys
/// (passwords, tokens, secrets, one-time codes) are masked at any depth.
/// Strings are parsed as JSON when possible; other bodies are not printed.
@visibleForTesting
Object? redactSensitive(Object? data) {
  switch (data) {
    case Map<dynamic, dynamic>():
      return {
        for (final entry in data.entries)
          entry.key: _sensitiveKey.hasMatch('${entry.key}')
              ? _masked
              : redactSensitive(entry.value),
      };
    case List<dynamic>():
      return data.map(redactSensitive).toList();
    case String():
      try {
        return redactSensitive(jsonDecode(data));
      } on FormatException {
        return '<non-JSON body, ${data.length} chars>';
      }
    case null || num() || bool():
      return data;
    default:
      return '<${data.runtimeType}>';
  }
}

Uri _redactUri(Uri uri) => uri.queryParameters.isEmpty
    ? uri
    : uri.replace(
        queryParameters: {
          for (final e in uri.queryParameters.entries)
            e.key: _sensitiveKey.hasMatch(e.key) ? _masked : e.value,
        },
      );

class LoggerInterceptor extends Interceptor {
  static const _line = '─────────────────────────────────────────';

  @override
  void onRequest(RequestOptions o, RequestInterceptorHandler h) {
    if (kDebugMode) {
      debugPrint('┌$_line');
      debugPrint('│ 🚀 REQUEST  ${o.method}  ${_redactUri(o.uri)}');
      if (o.data != null) debugPrint('│ Body    : ${redactSensitive(o.data)}');
      if (o.queryParameters.isNotEmpty) {
        debugPrint('│ Params  : ${redactSensitive(o.queryParameters)}');
      }
      debugPrint('└$_line');
    }
    h.next(o);
  }

  @override
  void onResponse(Response r, ResponseInterceptorHandler h) {
    if (kDebugMode) {
      final body = redactSensitive(r.data).toString();
      debugPrint('┌$_line');
      debugPrint(
        '│ ✅ RESPONSE [${r.statusCode}]  ${_redactUri(r.requestOptions.uri)}',
      );
      debugPrint('│ ${body.substring(0, body.length.clamp(0, 400))}');
      debugPrint('└$_line');
    }
    h.next(r);
  }

  @override
  void onError(DioException e, ErrorInterceptorHandler h) {
    if (kDebugMode) {
      debugPrint('┌$_line');
      debugPrint(
        '│ ❌ ERROR [${e.response?.statusCode}]  ${_redactUri(e.requestOptions.uri)}',
      );
      debugPrint('│ ${e.message}');
      if (e.response?.data != null) {
        debugPrint('│ ${redactSensitive(e.response?.data)}');
      }
      debugPrint('└$_line');
    }
    h.next(e);
  }
}
