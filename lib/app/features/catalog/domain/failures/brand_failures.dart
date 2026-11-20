import 'package:accounting_software/app/core/error/failures/failure.dart';
import 'package:accounting_software/app/core/localization/keys/error_keys.dart';

class BrandDuplicateFailure extends Failure {
  const BrandDuplicateFailure()
    : super(messageKey: ErrorKeys.conflict, statusCode: 409);
}

class BrandInUseFailure extends Failure {
  const BrandInUseFailure()
    : super(messageKey: ErrorKeys.conflict, statusCode: 409);
}
