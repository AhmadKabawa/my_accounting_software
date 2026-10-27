// api_result.dart
import 'package:dartz/dartz.dart';
import 'package:accounting_software/app/core/error/error_handling/exceptions/exceptions.dart';
import 'package:accounting_software/app/core/error/error_handling/failure/failure.dart';
import 'package:accounting_software/app/core/error/error_handling/mapper/exception_mapper.dart';

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

/// الجسر الوحيد بين نتيجة طبقة البيانات (ApiResult) وعقد الـ domain
/// (Either<Failure, T>). يحوّل الاستثناء إلى Failure في مكان واحد.
extension ApiResultEitherX<T> on ApiResult<T> {
  Either<Failure, T> toEither() => when<Either<Failure, T>>(
    success: (data) => Right(data),
    failure: (exception) => Left(ExceptionMapper.map(exception)),
  );

  /// مثل [toEither] مع خطوة غير متزامنة عند النجاح (مثل حفظ الجلسة).
  Future<Either<Failure, R>> toEitherAsync<R>(
    Future<R> Function(T data) onSuccess,
  ) async => switch (this) {
    ApiSuccess<T>(:final data) => Right<Failure, R>(await onSuccess(data)),
    ApiFailure<T>(:final exception) => Left<Failure, R>(
      ExceptionMapper.map(exception),
    ),
  };
}
