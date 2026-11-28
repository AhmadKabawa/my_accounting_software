import 'package:accounting_software/app/core/error/failures/failure.dart';
import 'package:accounting_software/app/core/localization/keys/error_keys.dart';
import 'package:accounting_software/app/features/catalog/care_instructions/domain/failures/care_instruction_failure_keys.dart';

class CareInstructionDuplicateFailure extends Failure {
  const CareInstructionDuplicateFailure()
      : super(messageKey: ErrorKeys.conflict, statusCode: 409);
}

class CareInstructionInUseFailure extends Failure {
  const CareInstructionInUseFailure()
      : super(messageKey: CareInstructionFailureKeys.inUse, statusCode: 409);
}
