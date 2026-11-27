import 'package:accounting_software/app/core/localization/translations/app_key.dart';
import 'package:accounting_software/app/features/catalog/genders/domain/entity/gender.dart';

sealed class GenderFormEffect {
  const GenderFormEffect();
}

class GenderSavedEffect extends GenderFormEffect {
  const GenderSavedEffect(this.gender);
  final Gender gender;
}

class GenderSaveFailedEffect extends GenderFormEffect {
  const GenderSaveFailedEffect(this.messageKey);
  final AppKey messageKey;
}
