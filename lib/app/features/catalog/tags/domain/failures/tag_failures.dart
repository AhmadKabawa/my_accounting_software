import 'package:accounting_software/app/core/error/failures/failure.dart';
import 'package:accounting_software/app/core/localization/keys/error_keys.dart';
import 'package:accounting_software/app/features/catalog/tags/domain/failures/tag_failure_keys.dart';

class TagInUseFailure extends Failure {
  const TagInUseFailure()
    : super(messageKey: TagFailureKeys.inUse, statusCode: 409);
}

/// The tag name or slug is already used (`tags.name` or `tags.slug` is UNIQUE, SQLSTATE 23505).
class TagDuplicateFailure extends Failure {
  const TagDuplicateFailure()
    : super(messageKey: ErrorKeys.conflict, statusCode: 409);
}
