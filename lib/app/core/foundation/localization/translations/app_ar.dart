/// lib/core/localization/translations/ar_EG.dart

import 'package:accounting_software/app/core/foundation/localization/translations/app_keys.dart'
    show AppKeys;
import 'package:accounting_software/app/core/foundation/localization/translations/app_key.dart';

/// يجمع كل الترجمات العربية (مصر)
final TranslationMap arSA = {
  ..._arAuth,
  ..._arFields,
  ..._arValidation,
  ..._arErrors,
  ..._arServerErrors,
  ..._arCommon,
  ..._arProfile,
  ..._arSuccess,
  ..._arOnBoarding,
  AppKeys.home: "الرئيسية",
  AppKeys.chat: "محادثة",
  AppKeys.favorite: "مفضل",
  AppKeys.person: "ملف شخصي",
};

final TranslationMap _arAuth = {
  AppKeys.auth.rememberMe: "تذكرني",
  AppKeys.auth.forgotPassword: "نسيت كلمة المرور؟",
  AppKeys.auth.signIn: "تسجيل الدخول",
  AppKeys.auth.createAccount: "إنشاء حساب",
  AppKeys.auth.sendMessage: "إرسال رسالة إلى البريد الإلكتروني",
  AppKeys.auth.continueGoogle: "المتابعة باستخدام Google",
  AppKeys.auth.orSignInWith: "أو سجل الدخول بواسطة",
  AppKeys.auth.orSignUpWith: "أو اشترك بواسطة",
  AppKeys.auth.forgetPassword: "نسيت كلمة المرور",
  AppKeys.auth.resendEmail: "إعادة إرسال البريد الإلكتروني",
  AppKeys.auth.registerTitle: "إنشاء حساب جديد",
  AppKeys.auth.registerSubtitle: "أدخل بياناتك للبدء",
};

final TranslationMap _arCommon = {
  AppKeys.common.retry: "إعادة المحاولة",
  AppKeys.common.cancel: "إلغاء",
  AppKeys.common.confirm: "تأكيد",
  AppKeys.common.save: "حفظ",
  AppKeys.common.loading: "جاري التحميل...",
  AppKeys.common.success: "تم بنجاح",
  AppKeys.common.unknownError: "حدث خطأ غير متوقع",
  AppKeys.common.optional: "اختياري",
};

final TranslationMap _arValidation = {
  AppKeys.valid.required: "هذا الحقل مطلوب",
  AppKeys.valid.emailRequired: "البريد الإلكتروني مطلوب",
  AppKeys.valid.emailInvalid: "بريد إلكتروني غير صالح",
  AppKeys.valid.passwordRequired: "كلمة المرور مطلوبة",
  AppKeys.valid.passwordMinLength:
      "يجب أن تكون كلمة المرور @length أحرف على الأقل",
  AppKeys.valid.passwordNeedsUpper: "يجب أن تحتوي على حرف كبير واحد على الأقل",
  AppKeys.valid.passwordNeedsNumber: "يجب أن تحتوي على رقم واحد على الأقل",
  AppKeys.valid.passwordNeedsSpecial: "يجب أن تحتوي على رمز خاص واحد على الأقل",
  AppKeys.valid.passwordsNotMatch: "كلمتا المرور غير متطابقتين",
  AppKeys.valid.nameRequired: "الاسم مطلوب",
  AppKeys.valid.nameMinLength: "يجب أن يكون الاسم @length أحرف على الأقل",
  AppKeys.valid.phoneInvalid: "رقم هاتف غير صالح",
  AppKeys.valid.fieldMinLength: "يجب أن يكون @length أحرف على الأقل",
  AppKeys.valid.fieldMaxLength: "يجب ألا يتجاوز @length حرفاً",
};

final TranslationMap _arErrors = {
  AppKeys.errors.network: "لا يوجد اتصال بالإنترنت",
  AppKeys.errors.timeout: "انتهت مهلة الطلب، يرجى المحاولة مرة أخرى",
  AppKeys.errors.server: "خطأ في الخادم، يرجى المحاولة مرة أخرى",
  AppKeys.errors.unauthorized: "انتهت جلستك، يرجى تسجيل الدخول مرة أخرى",
  AppKeys.errors.forbidden: "ليس لديك صلاحية لهذا الإجراء",
  AppKeys.errors.notFound: "المورد المطلوب غير موجود",
  AppKeys.errors.validation: "يرجى التحقق من المدخلات",
  AppKeys.errors.cache: "خطأ في ذاكرة التخزين المؤقت",
  AppKeys.errors.permission: "ليس لديك صلاحية لهذا الإجراء",
  AppKeys.errors.unexpected: "حدث خطأ غير متوقع",
  AppKeys.errors.cancelled: "تم إلغاء العملية",
  AppKeys.errors.googleSignIn: "فشل تسجيل الدخول بواسطة Google",
  AppKeys.errors.badRequest: "طلب غير صالح",
  AppKeys.errors.conflict: "تضارب في البيانات",
  AppKeys.errors.serviceUnavailable: "الخدمة غير متاحة",
  AppKeys.errors.unknown: "خطأ غير معروف",
};

final TranslationMap _arServerErrors = {
  AppKeys.server.emailAlreadyExists: "البريد الإلكتروني موجود بالفعل",
  AppKeys.server.emailNotFound: "البريد الإلكتروني غير موجود",
  AppKeys.server.invalidCredentials: "بريد إلكتروني أو كلمة مرور غير صحيحة",
  AppKeys.server.accountDisabled: "الحساب معطل، يرجى الاتصال بالدعم",
  AppKeys.server.tooManyAttempts: "محاولات كثيرة جداً، حاول مرة أخرى لاحقاً",
  AppKeys.server.passwordIncorrect: "كلمة المرور الحالية غير صحيحة",
  AppKeys.server.tokenExpired: "رابط إعادة التعيين انتهت صلاحيته",
  AppKeys.server.tokenInvalid: "رابط إعادة تعيين غير صالح",
  AppKeys.server.userNotFound: "المستخدم غير موجود",
  AppKeys.server.phoneAlreadyExists: "رقم الهاتف موجود بالفعل",
  AppKeys.server.unauthenticated: "يرجى تسجيل الدخول",
  AppKeys.server.unverifiedEmail: "يرجى التحقق من بريدك الإلكتروني أولاً",
};

final TranslationMap _arFields = {
  AppKeys.fields.email: "البريد الإلكتروني",
  AppKeys.fields.firstName: "الاسم الأول",
  AppKeys.fields.lastName: "اسم العائلة",
  AppKeys.fields.password: "كلمة المرور",
  AppKeys.fields.confirmPassword: "تأكيد كلمة المرور",
  AppKeys.fields.fullName: "الاسم الكامل",
  AppKeys.fields.phone: "رقم الهاتف",
  AppKeys.fields.bio: "السيرة الذاتية",
  AppKeys.fields.currentPassword: "كلمة المرور الحالية",
  AppKeys.fields.newPassword: "كلمة المرور الجديدة",
};

final TranslationMap _arProfile = {
  AppKeys.profile.title: "الملف الشخصي",
  AppKeys.profile.edit: "تعديل الملف الشخصي",
  AppKeys.profile.saveChanges: "حفظ التغييرات",
  AppKeys.profile.changePassword: "تغيير كلمة المرور",
  AppKeys.profile.updateButton: "تحديث",
  AppKeys.profile.userNumber: "مستخدم رقم @number",
};

final TranslationMap _arOnBoarding = {
  AppKeys.onBoarding.title1: "اختر منتجك",
  AppKeys.onBoarding.title2: "اختر طريقة الدفع",
  AppKeys.onBoarding.title3: "نوصّل إلى باب منزلك",
  AppKeys.onBoarding.subTitle1:
      "مرحبًا بك في عالم من الخيارات اللامحدودة - منتجك المثالي بانتظارك!",
  AppKeys.onBoarding.subTitle2:
      "لمعاملات سلسة، اختر طريقة الدفع المناسبة - راحتك أولويتنا!",
  AppKeys.onBoarding.subTitle3:
      "من بابنا إلى بابك - توصيل سريع وآمن وبدون تلامس!",
};

final TranslationMap _arSuccess = {
  AppKeys.success.signin: "تم تسجيل الدخول بنجاح",
  AppKeys.success.signup: "تم إنشاء الحساب بنجاح",
  AppKeys.success.signout: "تم تسجيل الخروج بنجاح",
  AppKeys.success.sendMessageToEmail: "تم إرسال رسالة إلى بريدك الإلكتروني",
};
