// api_result.dart
import 'package:accounting_software/app/core/error/error_handling/exceptions/exceptions.dart';

sealed class ApiResult<T> {
  const ApiResult();
}

class ApiSuccess<T> extends ApiResult<T> {
  final T data;
  const ApiSuccess(this.data);
}

class ApiFailure<T> extends ApiResult<T> {
  final AppException exception; // ← AppException مش (msg, code)
  const ApiFailure(this.exception);
}

extension ApiResultX<T> on ApiResult<T> {
  R when<R>({
    required R Function(T data) success,
    required R Function(AppException exception) failure,
  }) {
    return switch (this) {
      ApiSuccess<T>(:final data) => success(data),
      ApiFailure<T>(:final exception) => failure(exception),
    };
  }
}

extension ApiResultWhenSuccessX<T> on ApiResult<T> {
  void whenSuccess(void Function(T data) action) {
    if (this is ApiSuccess<T>) {
      action((this as ApiSuccess<T>).data);
    }
  }
}
