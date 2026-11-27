import 'package:accounting_software/app/core/localization/translations/app_key.dart';
import 'package:accounting_software/app/features/catalog/age_groups/domain/entity/age_group.dart';

sealed class AgeGroupFormEffect {
  const AgeGroupFormEffect();
}

class AgeGroupSavedEffect extends AgeGroupFormEffect {
  const AgeGroupSavedEffect(this.ageGroup);
  final AgeGroup ageGroup;
}

class AgeGroupSaveFailedEffect extends AgeGroupFormEffect {
  const AgeGroupSaveFailedEffect(this.messageKey);
  final AppKey messageKey;
}
