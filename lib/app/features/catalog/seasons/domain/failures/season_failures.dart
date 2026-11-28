import 'package:accounting_software/app/core/error/failures/failure.dart';
import 'package:accounting_software/app/core/localization/keys/error_keys.dart';
import 'package:accounting_software/app/features/catalog/seasons/domain/failures/season_failure_keys.dart';

class SeasonDuplicateFailure extends Failure {
  const SeasonDuplicateFailure()
    : super(messageKey: ErrorKeys.conflict, statusCode: 409);
}

class SeasonInUseFailure extends Failure {
  const SeasonInUseFailure()
    : super(messageKey: SeasonFailureKeys.inUse, statusCode: 409);
}
