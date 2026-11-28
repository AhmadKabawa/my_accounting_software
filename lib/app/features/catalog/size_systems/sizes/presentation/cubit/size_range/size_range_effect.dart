import 'package:accounting_software/app/core/localization/translations/app_key.dart';

sealed class SizeRangeEffect {
  const SizeRangeEffect();
}

class SizeRangeSavedEffect extends SizeRangeEffect {
  const SizeRangeSavedEffect(this.count);
  final int count;
}

class SizeRangeFailedEffect extends SizeRangeEffect {
  const SizeRangeFailedEffect(this.messageKey);
  final AppKey messageKey;
}
