import 'package:accounting_software/app/core/error/failures/failure.dart';
import 'package:accounting_software/app/core/localization/keys/error_keys.dart';

/// The color code is already used (`colors.code` is UNIQUE, SQLSTATE 23505).
class ColorDuplicateFailure extends Failure {
  const ColorDuplicateFailure()
    : super(messageKey: ErrorKeys.conflict, statusCode: 409);
}
