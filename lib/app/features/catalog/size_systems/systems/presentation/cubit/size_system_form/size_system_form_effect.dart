import 'package:accounting_software/app/core/localization/translations/app_key.dart';
import 'package:accounting_software/app/features/catalog/size_systems/systems/domain/entity/size_system.dart';

sealed class SizeSystemFormEffect {
  const SizeSystemFormEffect();
}

class SizeSystemSavedEffect extends SizeSystemFormEffect {
  const SizeSystemSavedEffect(this.system);
  final SizeSystem system;
}

class SizeSystemSaveFailedEffect extends SizeSystemFormEffect {
  const SizeSystemSaveFailedEffect(this.messageKey);
  final AppKey messageKey;
}
