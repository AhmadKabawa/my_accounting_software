import 'package:accounting_software/app/core/localization/translations/app_key.dart';

/// Texts of the `auth` section: one entry = key + Arabic + English.
///
/// Add a text by adding one entry; the key is `<prefix>.<name>` (derived),
/// so it cannot be mistyped or duplicated inside the section.
enum AuthKeys implements AppKey {
  rememberMe(ar: 'تذكرني', en: 'Remember me'),
  forgotPassword(ar: 'نسيت كلمة المرور؟', en: 'Forgot password?'),
  signIn(ar: 'تسجيل الدخول', en: 'Sign In'),
  contactAdmin(
    ar: 'نسيت كلمة المرور؟ تواصل مع مدير النظام',
    en: 'Forgot your password? Contact your system administrator',
  ),
  createAccount(ar: 'إنشاء حساب', en: 'Create Account'),
  sendMessageToEmail(
    ar: 'إرسال رسالة إلى البريد الإلكتروني',
    en: 'Send message to email',
  ),
  continueGoogle(ar: 'المتابعة باستخدام Google', en: 'Continue with Google'),
  orSignInWith(ar: 'أو سجل الدخول بواسطة', en: 'Or sign in with'),
  orSignUpWith(ar: 'أو اشترك بواسطة', en: 'Or sign up with'),
  forgotPasswordTitle(ar: 'نسيت كلمة المرور', en: 'Forget password'),
  resendEmail(ar: 'إعادة إرسال البريد الإلكتروني', en: 'Resend email'),
  registerTitle(ar: 'إنشاء حساب جديد', en: 'Create new account'),
  registerSubtitle(
    ar: 'أدخل بياناتك للبدء',
    en: 'Enter your details to get started',
  ),
  loginTitle(ar: 'مرحباً بعودتك', en: 'Welcome back'),
  loginSubtitle(
    ar: 'أدخل اسم المستخدم وكلمة المرور للمتابعة',
    en: 'Enter your username and password to continue',
  ),
  haveAccount(
    ar: 'لديك حساب؟ سجّل الدخول',
    en: 'Already have an account? Sign in',
  ),
  noAccount(
    ar: 'ليس لديك حساب؟ أنشئ حساباً',
    en: 'Don\'t have an account? Create one',
  ),
  sendCode(ar: 'إرسال الرمز', en: 'Send code'),
  forgotPasswordSubtitle(
    ar: 'أدخل بريدك الإلكتروني وسنرسل لك رمزاً لإعادة تعيين كلمة المرور',
    en: 'Enter your email and we will send you a code to reset your password',
  ),
  resetPasswordTitle(ar: 'تعيين كلمة مرور جديدة', en: 'Set a new password'),
  resetPasswordSubtitle(
    ar: 'أدخل الرمز الذي وصلك على بريدك واختر كلمة مرور جديدة',
    en: 'Enter the code we emailed you and choose a new password',
  ),
  resetPassword(ar: 'إعادة تعيين كلمة المرور', en: 'Reset password'),
  forceChangePasswordTitle(
    ar: 'تغيير كلمة المرور مطلوب',
    en: 'Password change required',
  ),
  forceChangePasswordSubtitle(
    ar: 'يجب تعيين كلمة مرور جديدة قبل متابعة استخدام النظام',
    en: 'Set a new password before continuing to the system',
  ),
  selectBranchTitle(ar: 'اختر الفرع', en: 'Choose a branch'),
  selectBranchSubtitle(
    ar: 'اختر الفرع الذي ستعمل عليه الآن',
    en: 'Choose the branch you will work on',
  ),
  continueAction(ar: 'متابعة', en: 'Continue'),
  signOut(ar: 'تسجيل الخروج', en: 'Sign out'),
  showPassword(ar: 'إظهار كلمة المرور', en: 'Show password'),
  hidePassword(ar: 'إخفاء كلمة المرور', en: 'Hide password'),
  signInSuccess(ar: 'تم تسجيل الدخول بنجاح', en: 'Successfully signed in'),
  signUpSuccess(
    ar: 'تم إنشاء الحساب بنجاح',
    en: 'Account created successfully',
  ),
  signOutSuccess(ar: 'تم تسجيل الخروج بنجاح', en: 'Successfully signed out'),
  emailSent(
    ar: 'تم إرسال رسالة إلى بريدك الإلكتروني',
    en: 'We\'ve sent you a message to your email',
  ),
  passwordResetSuccess(
    ar: 'تم تغيير كلمة المرور بنجاح',
    en: 'Password changed successfully',
  );

  const AuthKeys({required this.ar, required this.en});

  @override
  final String ar;
  @override
  final String en;

  @override
  String get key => 'auth.$name';
}
