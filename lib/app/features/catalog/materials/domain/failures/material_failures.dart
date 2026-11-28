import 'package:accounting_software/app/core/error/failures/failure.dart';
import 'package:accounting_software/app/core/localization/keys/error_keys.dart';
import 'package:accounting_software/app/features/catalog/materials/domain/failures/material_failure_keys.dart';

class MaterialDuplicateFailure extends Failure {
  const MaterialDuplicateFailure()
    : super(messageKey: ErrorKeys.conflict, statusCode: 409);
}

class MaterialInUseFailure extends Failure {
  const MaterialInUseFailure()
    : super(messageKey: MaterialFailureKeys.inUse, statusCode: 409);
}
