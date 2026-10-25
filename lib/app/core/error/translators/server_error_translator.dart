// // lib/core/translations/server_error_translator.dart
// //
// // ════════════════════════════════════════════════════════════════
// //  هذا الملف يحل مشكلة ترجمة أخطاء السيرفر
// //
// //  المشكلة:
// //    السيرفر يرجع: "The email has already been taken"
// //    أو:           { "message": "invalid_credentials" }
// //    أو:           { "errors": { "email": ["already exists"] } }
// //
// //  الحل:
// //    1. نحوّل رسالة السيرفر → مفتاح معروف
// //    2. نترجم المفتاح بـ easy_localization
// //    3. لو ما عندنا ترجمة → نرجع رسالة default مترجمة
// // ════════════════════════════════════════════════════════════════

// import 'package:easy_localization/easy_localization.dart';
// import 'package:accounting_software/app/core/foundation/localization/translations/app_keys.dart';

// class ServerErrorTranslator {
//   ServerErrorTranslator._();

//   // ════════════════════════════════════════════════════
//   //  🗺️ خريطة ربط رسائل السيرفر بمفاتيح الترجمة
//   //
//   //  المفتاح:  رسالة السيرفر أو جزء منها (lowercase)
//   //  القيمة:   مفتاح الترجمة من app_translations.dart
//   //
//   //  ← أضف هنا كل رسالة جديدة تأتي من الـ API
//   // ════════════════════════════════════════════════════
//   static const Map<String, String> _serverToKey = {
//     // Email
//     'already been taken': 'server_errors.email_already_exists',
//     'email already exists': 'server_errors.email_already_exists',
//     'email_already_exists': 'server_errors.email_already_exists',
//     'duplicate entry': 'server_errors.email_already_exists',
//     'email not found': 'server_errors.email_not_found',
//     'email_not_found': 'server_errors.email_not_found',

//     // Credentials
//     'invalid credentials': 'server_errors.invalid_credentials',
//     'invalid_credentials': 'server_errors.invalid_credentials',
//     'wrong password': 'server_errors.invalid_credentials',
//     'incorrect password': 'server_errors.invalid_credentials',
//     'these credentials do not': 'server_errors.invalid_credentials',
//     'authentication failed': 'server_errors.invalid_credentials',

//     // Account
//     'account disabled': 'server_errors.account_disabled',
//     'account_disabled': 'server_errors.account_disabled',
//     'account suspended': 'server_errors.account_disabled',
//     'user disabled': 'server_errors.account_disabled',

//     // Rate limiting
//     'too many attempts': 'server_errors.too_many_attempts',
//     'too_many_attempts': 'server_errors.too_many_attempts',
//     'rate limit': 'server_errors.too_many_attempts',
//     'too many requests': 'server_errors.too_many_attempts',

//     // Password
//     'current password': 'server_errors.password_incorrect',
//     'password_incorrect': 'server_errors.password_incorrect',
//     'old password is wrong': 'server_errors.password_incorrect',

//     // Token
//     'token expired': 'server_errors.token_expired',
//     'token_expired': 'server_errors.token_expired',
//     'link expired': 'server_errors.token_expired',
//     'token invalid': 'server_errors.token_invalid',
//     'token_invalid': 'server_errors.token_invalid',
//     'invalid token': 'server_errors.token_invalid',

//     // User
//     'user not found': 'server_errors.user_not_found',
//     'user_not_found': 'server_errors.user_not_found',
//     'no user': 'server_errors.user_not_found',

//     // Phone
//     'phone already': 'server_errors.phone_already_exists',
//     'phone_already_exists': 'server_errors.phone_already_exists',

//     // Auth
//     'unauthenticated': 'server_errors.unauthenticated',
//     'not authenticated': 'server_errors.unauthenticated',
//     'please login': 'server_errors.unauthenticated',

//     // Email verification
//     'email not verified': 'server_errors.unverified_email',
//     'unverified_email': 'server_errors.unverified_email',
//     'verify your email': 'server_errors.unverified_email',
//   };

//   // ════════════════════════════════════════════════════
//   //  📌 الدالة الرئيسية
//   //
//   //  تقبل: الرسالة الخام من السيرفر + status code
//   //  ترجع: نص مترجم جاهز للعرض في الـ UI
//   // ════════════════════════════════════════════════════
 
//   static String translate(String? serverMessage, {int? statusCode}) {
//     if (serverMessage == null || serverMessage.isEmpty) {
//       return _fallbackByStatusCode(statusCode);
//     }

//     final normalized = serverMessage.toLowerCase().trim();

//     // ① ابحث عن تطابق في الخريطة
//     for (final entry in _serverToKey.entries) {
//       if (normalized.contains(entry.key)) {
//         return tr(entry.value);
//       }
//     }

//     // ② تحقق لو الرسالة هي مفتاح ترجمة مباشر (مثل: "invalid_credentials")
//     if (_isTranslationKey(serverMessage)) {
//       return tr(serverMessage);
//     }

//     // ③ Fallback حسب الـ status code
//     return _fallbackByStatusCode(statusCode);
//   }

//   // ════════════════════════════════════════════════════
//   //  📌 ترجمة أخطاء الـ validation من السيرفر
//   //
//   //  مثال من Laravel:
//   //  {
//   //    "errors": {
//   //      "email": ["The email has already been taken"],
//   //      "password": ["The password must be at least 8 characters"]
//   //    }
//   //  }
//   //
//   //  ترجع: "هذا البريد الإلكتروني مسجّل مسبقاً"
//   //        (أول خطأ فقط)
//   // ════════════════════════════════════════════════════
//   static String translateValidationErrors(Map<String, dynamic> errorsMap) {
//     if (errorsMap.isEmpty) return tr( AppKeys.errors.validation.toString());

//     // خذ أول field وأول رسالة
//     final firstMessages = errorsMap.values.first;

//     String? firstMsg;
//     if (firstMessages is List && firstMessages.isNotEmpty) {
//       firstMsg = firstMessages.first?.toString();
//     } else if (firstMessages is String) {
//       firstMsg = firstMessages;
//     }

//     return translate(firstMsg);
//   }    

//   // ════════════════════════════════════════════════════
//   //  📌 ترجمة كل validation errors (لعرضها كلها)
//   //
//   //  ترجع: Map<fieldName, translatedMessage>
//   //  مثال: {'email': 'هذا البريد الإلكتروني مسجّل مسبقاً'}
//   // ════════════════════════════════════════════════════
//   static Map<String, String> translateAllValidationErrors(
//     Map<String, dynamic> errorsMap,
//   ) {
//     final result = <String, String>{};
//     for (final entry in errorsMap.entries) {
//       final messages = entry.value;
//       String? msg;
//       if (messages is List && messages.isNotEmpty) {
//         msg = messages.first?.toString();
//       } else if (messages is String) {
//         msg = messages;
//       }
//       if (msg != null) {
//         result[entry.key] = translate(msg);
//       }
//     }
//     return result;
//   }

//   // ── Helpers ───────────────────────────────────────

//   static bool _isTranslationKey(String text) {
//     return RegExp(r'^[a-z][a-z_]+\.[a-z][a-z_]+$').hasMatch(text);
//     // يقبل فقط: "errors.not_found" / "server_errors.email_exists"
//     // يرفض: "user@email.com" / "some text.more text"
//   }

//   static String _fallbackByStatusCode(int? code) {
//     return switch (code) {
//       400 => tr(  AppKeys.errors.validation.toString()),
//       401 => tr( AppKeys.errors.unauthorized.toString()),
//       403 => tr( AppKeys.errors.forbidden.toString()),
//       404 => tr( AppKeys.errors.notFound.toString()),
//       408 => tr( AppKeys.errors.timeout.toString()),
//       409 => tr( AppKeys.errors.conflict.toString()), // ← أضف
//       422 => tr( AppKeys.errors.validation.toString()),
//       429 => tr(AppKeys.server.tooManyAttempts.toString()),
//       500 => tr( AppKeys.errors.server.toString()), // ← أضف
//       503 => tr( AppKeys.errors.serviceUnavailable.toString()), // ← أضف
//       _ => tr( AppKeys.errors.unexpected.toString()),
//     };
//   }
// }
// /**## متى تستخدم كل واحدة
// ```
// السيرفر يرجع message بسيطة
// "invalid_credentials"
//         ↓
//    translate()


// السيرفر يرجع errors map وتريد أول خطأ فقط
// {"email": ["taken"], "password": ["short"]}
//         ↓
//    translateValidationErrors()


// السيرفر يرجع errors map وتريد كل الأخطاء تحت كل حقل
// {"email": ["taken"], "password": ["short"]}
//         ↓
//    translateAllValidationErrors() */



//    /**  static const Map<String, AppKey> _serverToKey = {
//     // ───────────── Email ─────────────
//     'already been taken': AppKeys.server.emailAlreadyExists,
//     'email already exists': AppKeys.server.emailAlreadyExists,
//     'email_already_exists': AppKeys.server.emailAlreadyExists,
//     'duplicate entry': AppKeys.server.emailAlreadyExists,
//     'email not found': AppKeys.server.emailNotFound,
//     'email_not_found': AppKeys.server.emailNotFound,

//     // ───────────── Credentials ─────────────
//     'invalid credentials': AppKeys.server.invalidCredentials,
//     'invalid_credentials': AppKeys.server.invalidCredentials,
//     'wrong password': AppKeys.server.invalidCredentials,
//     'incorrect password': AppKeys.server.invalidCredentials,
//     'these credentials do not': AppKeys.server.invalidCredentials,
//     'authentication failed': AppKeys.server.invalidCredentials,

//     // ───────────── Account ─────────────
//     'account disabled': AppKeys.server.accountDisabled,
//     'account_disabled': AppKeys.server.accountDisabled,
//     'account suspended': AppKeys.server.accountDisabled,
//     'user disabled': AppKeys.server.accountDisabled,

//     // ───────────── Rate limiting ─────────────
//     'too many attempts': AppKeys.server.tooManyAttempts,
//     'too_many_attempts': AppKeys.server.tooManyAttempts,
//     'rate limit': AppKeys.server.tooManyAttempts,
//     'too many requests': AppKeys.server.tooManyAttempts,

//     // ───────────── Password ─────────────
//     'current password': AppKeys.server.passwordIncorrect,
//     'password_incorrect': AppKeys.server.passwordIncorrect,
//     'old password is wrong': AppKeys.server.passwordIncorrect,

//     // ───────────── Token ─────────────
//     'token expired': AppKeys.server.tokenExpired,
//     'token_expired': AppKeys.server.tokenExpired,
//     'link expired': AppKeys.server.tokenExpired,
//     'token invalid': AppKeys.server.tokenInvalid,
//     'token_invalid': AppKeys.server.tokenInvalid,
//     'invalid token': AppKeys.server.tokenInvalid,

//     // ───────────── User ─────────────
//     'user not found': AppKeys.server.userNotFound,
//     'user_not_found': AppKeys.server.userNotFound,
//     'no user': AppKeys.server.userNotFound,

//     // ───────────── Phone ─────────────
//     'phone already': AppKeys.server.phoneAlreadyExists,
//     'phone_already_exists': AppKeys.server.phoneAlreadyExists,

//     // ───────────── Auth ─────────────
//     'unauthenticated': AppKeys.server.unauthenticated,
//     'not authenticated': AppKeys.server.unauthenticated,
//     'please login': AppKeys.server.unauthenticated,

//     // ───────────── Email verification ─────────────
//     'email not verified': AppKeys.server.unverifiedEmail,
//     'unverified_email': AppKeys.server.unverifiedEmail,
//     'verify your email': AppKeys.server.unverifiedEmail,
//   };
//  */