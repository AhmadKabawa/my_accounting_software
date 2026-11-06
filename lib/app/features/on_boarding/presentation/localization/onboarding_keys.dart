import 'package:accounting_software/app/core/localization/translations/app_key.dart';

/// Texts of the `onboarding` section: one entry = key + Arabic + English.
///
/// Add a text by adding one entry; the key is `<prefix>.<name>` (derived),
/// so it cannot be mistyped or duplicated inside the section.
enum OnboardingKeys implements AppKey {
  title1(ar: 'اختر منتجك', en: 'Choose your product'),
  title2(ar: 'اختر طريقة الدفع', en: 'Select Payment Method'),
  title3(ar: 'نوصّل إلى باب منزلك', en: 'Deliver at your door step'),
  subTitle1(
    ar: 'مرحبًا بك في عالم من الخيارات اللامحدودة - منتجك المثالي بانتظارك!',
    en: 'Welcome to a World of Limitless Choices - Your Perfect Product Awaits!',
  ),
  subTitle2(
    ar: 'لمعاملات سلسة، اختر طريقة الدفع المناسبة - راحتك أولويتنا!',
    en: 'For Seamless Transactions, Choose Your Payment Path - Your Convenience, Our Priority!',
  ),
  subTitle3(
    ar: 'من بابنا إلى بابك - توصيل سريع وآمن وبدون تلامس!',
    en: 'From Our Doorstep to Yours - Swift, Secure, and Contactless Delivery!',
  );

  const OnboardingKeys({required this.ar, required this.en});

  @override
  final String ar;
  @override
  final String en;

  @override
  String get key => 'onboarding.$name';
}
