import 'package:accounting_software/app/core/error/failures/failure.dart';
import 'package:accounting_software/app/core/localization/keys/error_keys.dart';
import 'package:accounting_software/app/features/catalog/brands/presentation/localization/brands_keys.dart';

class BrandDuplicateFailure extends Failure {
  const BrandDuplicateFailure()
    : super(messageKey: ErrorKeys.conflict, statusCode: 409);
}

class BrandInUseFailure extends Failure {
  const BrandInUseFailure()
    : super(messageKey: BrandsKeys.brandInUse, statusCode: 409);
}

class BrandUsageUnknownFailure extends Failure {
  const BrandUsageUnknownFailure()
    : super(messageKey: BrandsKeys.brandUsageUnknown, statusCode: 409);
}
