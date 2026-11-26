import 'package:accounting_software/app/core/localization/translations/app_key.dart';

sealed class OptionSetFormEffect {
  const OptionSetFormEffect();
}

class OptionSetSavedEffect extends OptionSetFormEffect {
  const OptionSetSavedEffect(this.id);
  final int id;
}

class OptionSetSaveFailedEffect extends OptionSetFormEffect {
  const OptionSetSaveFailedEffect(this.messageKey);
  final AppKey messageKey;
}
