import 'package:easy_localization/easy_localization.dart';
import 'package:accounting_software/app/core/error/failures/failure.dart';

class FailureTranslator {
  FailureTranslator._();

  static String translate(Failure failure) {
    return tr(failure.messageKey.tran);
  }
}
