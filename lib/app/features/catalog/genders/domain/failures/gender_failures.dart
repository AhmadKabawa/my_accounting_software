import 'package:accounting_software/app/core/error/failures/failure.dart';
import 'package:accounting_software/app/core/localization/keys/error_keys.dart';
import 'package:accounting_software/app/features/catalog/genders/domain/failures/gender_failure_keys.dart';

class GenderInUseFailure extends Failure {
  const GenderInUseFailure()
      : super(messageKey: GenderFailureKeys.inUse, statusCode: 409);
}

class GenderUsageUnknownFailure extends Failure {
  const GenderUsageUnknownFailure()
      : super(messageKey: GenderFailureKeys.usageUnknown, statusCode: 409);
}

class GenderDuplicateFailure extends Failure {
  const GenderDuplicateFailure()
      : super(messageKey: ErrorKeys.conflict, statusCode: 409);
}
