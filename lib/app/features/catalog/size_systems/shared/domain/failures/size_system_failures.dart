import 'package:accounting_software/app/core/error/failures/failure.dart';
import 'package:accounting_software/app/core/localization/keys/error_keys.dart';
import 'package:accounting_software/app/features/catalog/size_systems/shared/domain/failures/size_system_failure_keys.dart';

class SizeSystemInUseFailure extends Failure {
  const SizeSystemInUseFailure()
    : super(messageKey: SizeSystemFailureKeys.systemInUse, statusCode: 409);
}

class SizeGroupInUseFailure extends Failure {
  const SizeGroupInUseFailure()
    : super(messageKey: SizeSystemFailureKeys.groupInUse, statusCode: 409);
}

class SizeInUseFailure extends Failure {
  const SizeInUseFailure()
    : super(messageKey: SizeSystemFailureKeys.sizeInUse, statusCode: 409);
}

/// A UNIQUE code was repeated (SQLSTATE 23505 / HTTP 409): system and group
/// codes are globally unique, size codes are unique inside their group.
class SizeCodeDuplicateFailure extends Failure {
  const SizeCodeDuplicateFailure()
    : super(messageKey: ErrorKeys.conflict, statusCode: 409);
}
