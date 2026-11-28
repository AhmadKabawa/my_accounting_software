import 'package:accounting_software/app/core/error/failures/failure.dart';
import 'package:accounting_software/app/core/localization/keys/error_keys.dart';
import 'package:accounting_software/app/features/catalog/collections/domain/failures/collection_failure_keys.dart';

class CollectionDuplicateFailure extends Failure {
  const CollectionDuplicateFailure()
    : super(messageKey: ErrorKeys.conflict, statusCode: 409);
}

class CollectionInUseFailure extends Failure {
  const CollectionInUseFailure()
    : super(messageKey: CollectionFailureKeys.inUse, statusCode: 409);
}
