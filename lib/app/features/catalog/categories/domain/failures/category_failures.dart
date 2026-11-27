import 'package:accounting_software/app/core/error/failures/failure.dart';
import 'package:accounting_software/app/features/catalog/categories/domain/failures/category_failure_keys.dart';

class CategoryInUseFailure extends Failure {
  const CategoryInUseFailure()
    : super(messageKey: CategoryFailureKeys.inUse, statusCode: 409);
}

class CategoryUsageUnknownFailure extends Failure {
  const CategoryUsageUnknownFailure()
    : super(messageKey: CategoryFailureKeys.usageUnknown, statusCode: 409);
}

class CategorySlugTakenFailure extends Failure {
  const CategorySlugTakenFailure()
    : super(messageKey: CategoryFailureKeys.slugTaken, statusCode: 409);
}

class CategoryInvalidParentFailure extends Failure {
  const CategoryInvalidParentFailure()
    : super(messageKey: CategoryFailureKeys.invalidParent, statusCode: 400);
}

class CategoryTreeTooLargeFailure extends Failure {
  const CategoryTreeTooLargeFailure()
    : super(messageKey: CategoryFailureKeys.tooLarge);
}
