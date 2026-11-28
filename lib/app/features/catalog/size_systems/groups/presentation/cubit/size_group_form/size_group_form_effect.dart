import 'package:accounting_software/app/core/localization/translations/app_key.dart';
import 'package:accounting_software/app/features/catalog/size_systems/groups/domain/entity/size_group.dart';

sealed class SizeGroupFormEffect {
  const SizeGroupFormEffect();
}

class SizeGroupSavedEffect extends SizeGroupFormEffect {
  const SizeGroupSavedEffect(this.group);
  final SizeGroup group;
}

class SizeGroupSaveFailedEffect extends SizeGroupFormEffect {
  const SizeGroupSaveFailedEffect(this.messageKey);
  final AppKey messageKey;
}
