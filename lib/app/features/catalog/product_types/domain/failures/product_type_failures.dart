import 'package:accounting_software/app/core/error/failures/failure.dart';
import 'package:accounting_software/app/features/catalog/product_types/domain/failures/product_type_failure_keys.dart';

class ProductTypeInUseFailure extends Failure {
  const ProductTypeInUseFailure()
    : super(messageKey: ProductTypeFailureKeys.inUse, statusCode: 409);
}

class ProductTypeUsageUnknownFailure extends Failure {
  const ProductTypeUsageUnknownFailure()
    : super(messageKey: ProductTypeFailureKeys.usageUnknown);
}

class ProductTypeDuplicateFailure extends Failure {
  const ProductTypeDuplicateFailure()
    : super(messageKey: ProductTypeFailureKeys.duplicate, statusCode: 409);
}

class ProductTypeDefaultSizeGroupConflictFailure extends Failure {
  const ProductTypeDefaultSizeGroupConflictFailure()
    : super(messageKey: ProductTypeFailureKeys.defaultSizeGroupConflict);
}
