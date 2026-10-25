// lib/core/network/interceptors/logger_interceptor.dart

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class LoggerInterceptor extends Interceptor {
  static const _line = '─────────────────────────────────────────';

  @override
  void onRequest(RequestOptions o, RequestInterceptorHandler h) {
    if (kDebugMode) {
      debugPrint('┌$_line');
      debugPrint('│ 🚀 REQUEST  ${o.method}  ${o.uri}');
      if (o.data != null) debugPrint('│ Body    : ${o.data}');
      if (o.queryParameters.isNotEmpty) debugPrint('│ Params  : ${o.queryParameters}');
      debugPrint('└$_line');
    }
    h.next(o);
  }

  @override
  void onResponse(Response r, ResponseInterceptorHandler h) {
    if (kDebugMode) {
      final body = r.data.toString();
      debugPrint('┌$_line');
      debugPrint('│ ✅ RESPONSE [${r.statusCode}]  ${r.requestOptions.uri}');
      debugPrint('│ ${body.substring(0, body.length.clamp(0, 400))}');
      debugPrint('└$_line');
    }
    h.next(r);
  }

  @override
  void onError(DioException e, ErrorInterceptorHandler h) {
    if (kDebugMode) {
      debugPrint('┌$_line');
      debugPrint('│ ❌ ERROR [${e.response?.statusCode}]  ${e.requestOptions.uri}');
      debugPrint('│ ${e.message}');
      if (e.response?.data != null) debugPrint('│ ${e.response?.data}');
      debugPrint('└$_line');
    }
    h.next(e);
  }
}
