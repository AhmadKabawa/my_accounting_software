import 'package:accounting_software/app/core/error/failures/failure.dart';
import 'package:accounting_software/app/features/catalog/age_groups/domain/failures/age_group_failure_keys.dart';

class AgeGroupInUseFailure extends Failure {
  const AgeGroupInUseFailure()
    : super(messageKey: AgeGroupFailureKeys.inUse, statusCode: 409);
}
class AgeGroupUsageUnknownFailure extends Failure {
  const AgeGroupUsageUnknownFailure()
    : super(messageKey: AgeGroupFailureKeys.usageUnknown, statusCode: 409);
}
class AgeGroupDuplicateFailure extends Failure {
  const AgeGroupDuplicateFailure()
    : super(messageKey: AgeGroupFailureKeys.duplicate, statusCode: 409);
}
/// PostgreSQL SQLSTATE 23514 from age_groups_check (min_age <= max_age).
class AgeGroupInvalidRangeFailure extends Failure {
  const AgeGroupInvalidRangeFailure()
    : super(messageKey: AgeGroupFailureKeys.invalidRange, statusCode: 422);
}
