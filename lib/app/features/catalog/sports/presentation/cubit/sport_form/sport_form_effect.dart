import 'package:accounting_software/app/core/localization/translations/app_key.dart';
import 'package:accounting_software/app/features/catalog/sports/domain/entity/sport.dart';

sealed class SportFormEffect {
  const SportFormEffect();
}

class SportSavedEffect extends SportFormEffect {
  const SportSavedEffect(this.sport);

  final Sport sport;
}

class SportSaveFailedEffect extends SportFormEffect {
  const SportSaveFailedEffect(this.messageKey);

  final AppKey messageKey;
}
