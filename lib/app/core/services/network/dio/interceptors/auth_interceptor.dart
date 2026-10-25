// lib/core/network/interceptors/auth_interceptor.dart

import 'package:dio/dio.dart';
import 'package:accounting_software/app/core/services/local_storage/secure_storage/token_manager.dart';

class AuthInterceptor extends Interceptor {
  final TokenManager _tokenStorage;
  AuthInterceptor(this._tokenStorage);

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // Skip public endpoints (login, register, forgot-password)
    if (options.extra['requiresAuth'] == false) {
      return handler.next(options);
    }

    final token = await _tokenStorage.getAccessToken();
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }
}
