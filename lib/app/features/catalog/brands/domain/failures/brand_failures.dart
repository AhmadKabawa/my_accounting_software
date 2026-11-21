import 'package:accounting_software/app/core/error/failures/failure.dart';
import 'package:accounting_software/app/core/localization/keys/error_keys.dart';
import 'package:accounting_software/app/features/catalog/brands/domain/failures/brand_failure_keys.dart';

class BrandDuplicateFailure extends Failure {
  const BrandDuplicateFailure()
    : super(messageKey: ErrorKeys.conflict, statusCode: 409);
}

class BrandInUseFailure extends Failure {
  const BrandInUseFailure()
    : super(messageKey: BrandFailureKeys.brandInUse, statusCode: 409);
}

/// Raised locally (no request is made) when the product count is unknown, so
/// it has no HTTP status.
class BrandUsageUnknownFailure extends Failure {
  const BrandUsageUnknownFailure()
    : super(messageKey: BrandFailureKeys.brandUsageUnknown);
}
