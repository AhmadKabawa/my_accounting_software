import 'package:accounting_software/app/core/error/failures/failure.dart';import 'package:accounting_software/app/core/localization/keys/error_keys.dart';
import 'package:accounting_software/app/features/catalog/fabric_types/domain/failures/fabric_type_failure_keys.dart';class FabricTypeDuplicateFailure extends Failure{const FabricTypeDuplicateFailure():super(messageKey:ErrorKeys.conflict,statusCode:409);}
class FabricTypeInUseFailure extends Failure{const FabricTypeInUseFailure():super(messageKey:FabricTypeFailureKeys.inUse,statusCode:409);}
