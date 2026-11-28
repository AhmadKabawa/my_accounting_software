import 'package:accounting_software/app/core/localization/translations/app_key.dart';
import 'package:accounting_software/app/features/catalog/care_instructions/domain/entity/care_instruction.dart';
import 'package:accounting_software/app/features/catalog/care_instructions/presentation/localization/care_instructions_keys.dart';

AppKey careTypeLabel(CareType type) => switch (type) {
  CareType.washing => CareInstructionsKeys.washing,
  CareType.drying => CareInstructionsKeys.drying,
  CareType.ironing => CareInstructionsKeys.ironing,
  CareType.bleaching => CareInstructionsKeys.bleaching,
  CareType.dryCleaning => CareInstructionsKeys.dryCleaning,
};
