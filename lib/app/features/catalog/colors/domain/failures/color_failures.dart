import 'package:accounting_software/app/core/error/failures/failure.dart';
import 'package:accounting_software/app/core/localization/keys/error_keys.dart';
import 'package:accounting_software/app/features/catalog/colors/domain/failures/color_failure_keys.dart';

class ColorInUseFailure extends Failure {
  const ColorInUseFailure() : super(messageKey: ColorFailureKeys.inUse, statusCode: 409);
}

/// The color code is already used (`colors.code` is UNIQUE, SQLSTATE 23505).
class ColorDuplicateFailure extends Failure {
  const ColorDuplicateFailure()
    : super(messageKey: ErrorKeys.conflict, statusCode: 409);
}
