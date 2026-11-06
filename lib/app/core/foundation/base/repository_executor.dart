import 'package:dartz/dartz.dart';
import 'package:accounting_software/app/core/error/exceptions/api_exception.dart';
import 'package:accounting_software/app/core/error/exceptions/app_exception.dart';
import 'package:accounting_software/app/core/error/failures/failure.dart';
import 'package:accounting_software/app/core/error/mappers/exception_mapper.dart';
import 'package:accounting_software/app/core/foundation/utils/logger.dart';

/// The try/catch + `ExceptionMapper` pattern every repository needs, in one
/// place. Mix it into a repository and wrap each call in [execute].
///
/// An unexpected (non-`AppException`) error is logged with its stack trace and
/// mapped to a generic failure: its text is never put in the failure, so no
/// internal detail can reach the UI.
mixin RepositoryExecutor {
  Future<Either<Failure, T>> execute<T>(
    Future<Either<Failure, T>> Function() action,
  ) async {
    try {
      return await action();
    } on AppException catch (e) {
      return Left(ExceptionMapper.map(e));
    } catch (e, st) {
      Logger.error(
        'Unexpected repository error',
        error: e,
        stackTrace: st,
        name: runtimeType.toString(),
      );
      return Left(ExceptionMapper.map(ApiException.unknown()));
    }
  }
}
