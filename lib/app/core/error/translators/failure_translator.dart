import 'package:accounting_software/app/core/error/failures/failure.dart';
import 'package:accounting_software/app/core/localization/translations/app_key.dart';

/// Turns a [Failure] into display text, translating exactly once.
///
/// Prefer passing `failure.messageKey` (an [AppKey]) to a message/AppText so
/// the translation happens at display time and follows the current language.
/// Use this only where a ready `String` is required.
class FailureTranslator {
  FailureTranslator._();

  static String translate(Failure failure) => failure.messageKey.tran;
}
