// lib/core/network/interceptors/logger_interceptor.dart

import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

const _masked = '***';

/// Keys whose values must never reach the console. Matches as a substring
/// (so `access_token`, `refreshToken`, `sessionId`, `Set-Cookie` are covered).
/// The short, ambiguous words `code`, `otp` and `pin` are masked only as a
/// whole key or when prefixed by a credential word (`verification_code`,
/// `reset_pin`, `sms_otp`), so harmless keys such as `error_code`, `zipcode`
/// or `option` stay readable in the logs.
final _sensitiveKey = RegExp(
  r'password|passwd|passcode|token|secret|authorization|auth|session'
  r'|refresh|access|jwt|cookie|api[_-]?key'
  r'|^(code|otp|pin)$'
  r'|(verification|verify|reset|confirm|security|sms|login)[_-]?(code|otp|pin)',
  caseSensitive: false,
);

/// Path segments that look like credentials (a JWT, a long opaque token) are
/// masked in logged URLs, e.g. `/auth/v1/verify/<token>`. UUIDs are resource
/// ids, not secrets, and stay readable.
final _jwtLike = RegExp(
  r'^[A-Za-z0-9_-]{8,}\.[A-Za-z0-9_-]{8,}\.[A-Za-z0-9_-]{8,}$',
);
final _uuid = RegExp(
  r'^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$',
  caseSensitive: false,
);
final _opaqueToken = RegExp(r'^[A-Za-z0-9_-]{32,}$');

bool _looksSensitiveSegment(String segment) =>
    _jwtLike.hasMatch(segment) ||
    (!_uuid.hasMatch(segment) && _opaqueToken.hasMatch(segment));

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

/// Masks sensitive query values and credential-looking path segments.
@visibleForTesting
Uri redactUri(Uri uri) {
  final segments = uri.pathSegments;
  final maskPath = segments.any(_looksSensitiveSegment);
  if (uri.queryParameters.isEmpty && !maskPath) return uri;
  return uri.replace(
    pathSegments: maskPath
        ? [for (final s in segments) _looksSensitiveSegment(s) ? _masked : s]
        : null,
    queryParameters: uri.queryParameters.isEmpty
        ? null
        : {
            for (final e in uri.queryParameters.entries)
              e.key: _sensitiveKey.hasMatch(e.key) ? _masked : e.value,
          },
  );
}

class LoggerInterceptor extends Interceptor {
  static const _line = '─────────────────────────────────────────';

  @override
  void onRequest(RequestOptions o, RequestInterceptorHandler h) {
    if (kDebugMode) {
      debugPrint('┌$_line');
      debugPrint('│ 🚀 REQUEST  ${o.method}  ${redactUri(o.uri)}');
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
        '│ ✅ RESPONSE [${r.statusCode}]  ${redactUri(r.requestOptions.uri)}',
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
        '│ ❌ ERROR [${e.response?.statusCode}]  ${redactUri(e.requestOptions.uri)}',
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
