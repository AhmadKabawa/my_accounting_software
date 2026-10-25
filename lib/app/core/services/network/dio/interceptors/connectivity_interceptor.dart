// ✅ connectivity_interceptor.dart
import 'package:dio/dio.dart';
import 'package:accounting_software/app/core/error/error_handling/exceptions/api_exception.dart';
import 'package:accounting_software/app/core/services/network/network_info/network_info.dart';

class ConnectivityInterceptor extends Interceptor {
  const ConnectivityInterceptor({required NetworkInfo networkInfo})
    : _networkInfo = networkInfo;

  final NetworkInfo _networkInfo;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final hasConnection =
        await _networkInfo.isConnected; // ← يستخدم NetworkInfoImpl

    if (!hasConnection) {
      return handler.reject(
        DioException(
          requestOptions: options,
          type: DioExceptionType.connectionError,
          error: ApiException.noInternet(),
        ),
        true,
      );
    }
    handler.next(options);
  }
}
