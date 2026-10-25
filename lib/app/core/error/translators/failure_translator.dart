import 'package:easy_localization/easy_localization.dart';
import 'package:accounting_software/app/core/error/error_handling/failure/failure.dart';

class FailureTranslator {
  FailureTranslator._();

  static String translate(Failure failure) {
    return tr(failure.messageKey.tran);
  }
}
// class FailureTranslator {
//   FailureTranslator._();

//   static String translate(Failure failure) {
//     return switch (failure) {
//       // ── أخطاء ثابتة — لا تحتاج ServerErrorTranslator ──
//       NetworkFailure() => tr(AppKeys.errors.network.toString()),
//       NotFoundFailure() => tr(AppKeys.errors.notFound.toString()),
//       CacheFailure() => tr(AppKeys.errors.cache.toString()),
//       PermissionFailure() => tr(AppKeys.errors.permission.toString()),
//       GoogleSignInFailure() => tr(AppKeys.errors.googleSignIn.toString()),

//       // ── أخطاء فيها messageKey من السيرفر ──────────────
//       // ✅ هنا فقط يُستخدم ServerErrorTranslator
//       UnauthorizedFailure() => ServerErrorTranslator.translate(
//         failure.messageKey,
//         statusCode: 401,
//       ),
//       ValidationFailure() => ServerErrorTranslator.translate(
//         failure.messageKey,
//         statusCode: 422,
//       ),
//       ServerFailure() => ServerErrorTranslator.translate(
//         failure.messageKey,
//         statusCode: failure.statusCode,
//       ), // الافضل ارجاع رسالة ثابت
//       UnexpectedFailure() => ServerErrorTranslator.translate(
//         failure.messageKey,
//       ),

//       _ => tr(AppKeys.errors.unexpected),
//     };
//   }
// }
