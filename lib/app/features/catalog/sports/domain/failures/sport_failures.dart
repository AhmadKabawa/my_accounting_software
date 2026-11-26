import 'package:accounting_software/app/core/error/failures/failure.dart';
import 'package:accounting_software/app/core/localization/keys/error_keys.dart';
import 'package:accounting_software/app/features/catalog/sports/domain/failures/sport_failure_keys.dart';

class SportInUseFailure extends Failure {
  const SportInUseFailure()
    : super(messageKey: SportFailureKeys.inUse, statusCode: 409);
}

/// The sport code is already used (`sports.code` is UNIQUE, SQLSTATE 23505).
class SportDuplicateFailure extends Failure {
  const SportDuplicateFailure()
    : super(messageKey: ErrorKeys.conflict, statusCode: 409);
}
