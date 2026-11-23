import 'package:dartz/dartz.dart';
import 'package:accounting_software/app/core/error/failures/failure.dart';
import 'package:accounting_software/app/core/foundation/types/bulk_result.dart';

/// Executes per-record mutations sequentially when no server bulk endpoint
/// exists. Each failure is retained and does not stop later records.
class BulkMutationUseCase<T> {
  Future<BulkResult<T>> execute(
    Iterable<T> items,
    Future<Either<Failure, Unit>> Function(T item) action, {
    bool Function()? shouldStop,
  }) async {
    var succeeded = 0;
    final failures = <BulkFailure<T>>[];
    for (final item in items) {
      if (shouldStop?.call() ?? false) break;
      final result = await action(item);
      result.fold(
        (failure) => failures.add(BulkFailure(item: item, reason: failure)),
        (_) => succeeded++,
      );
      if (shouldStop?.call() ?? false) break;
    }
    return BulkResult<T>(successCount: succeeded, failures: failures);
  }
}
