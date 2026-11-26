import 'package:accounting_software/app/core/localization/translations/app_key.dart';

sealed class UnitFormEffect {
  const UnitFormEffect();
}

class UnitSavedEffect extends UnitFormEffect {
  const UnitSavedEffect(this.id);
  final int id;
}

class UnitSaveFailedEffect extends UnitFormEffect {
  const UnitSaveFailedEffect(this.messageKey);
  final AppKey messageKey;
}
