import 'package:accounting_software/app/core/error/failures/failure.dart';

class BulkFailure<T> {
  const BulkFailure({required this.item, required this.reason});
  final T item;
  final Failure reason;
}

class BulkResult<T> {
  BulkResult({
    required this.successCount,
    required List<BulkFailure<T>> failures,
  }) : failures = List.unmodifiable(failures);

  final int successCount;
  final List<BulkFailure<T>> failures;
  int get failureCount => failures.length;
  int get totalCount => successCount + failureCount;
  bool get isSuccess => failureCount == 0;
  bool get isFailure => successCount == 0 && failureCount > 0;
}
