import 'package:accounting_software/app/core/error/failures/failure.dart';
import 'package:accounting_software/app/features/catalog/categories/domain/failures/category_failure_keys.dart';

/// Delete rejected by a foreign key (SQLSTATE 23503): products or children.
class CategoryInUseFailure extends Failure {
  const CategoryInUseFailure()
    : super(messageKey: CategoryFailureKeys.inUse, statusCode: 409);
}

/// The embedded product count was unavailable, so deletion is blocked safely.
class CategoryUsageUnknownFailure extends Failure {
  const CategoryUsageUnknownFailure()
    : super(messageKey: CategoryFailureKeys.usageUnknown, statusCode: 409);
}

/// `categories.slug` is UNIQUE (SQLSTATE 23505).
class CategorySlugTakenFailure extends Failure {
  const CategorySlugTakenFailure()
    : super(messageKey: CategoryFailureKeys.slugTaken, statusCode: 409);
}

/// The chosen parent is the category itself or one of its descendants.
class CategoryInvalidParentFailure extends Failure {
  const CategoryInvalidParentFailure()
    : super(messageKey: CategoryFailureKeys.invalidParent);
}

/// More rows than the loader accepts (D-CAT-2): the tree needs another design.
class CategoryTreeTooLargeFailure extends Failure {
  const CategoryTreeTooLargeFailure()
    : super(messageKey: CategoryFailureKeys.tooLarge);
}
