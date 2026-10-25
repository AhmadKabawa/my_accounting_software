class AppPathImages {
  static const AppPathImage banner = AppPathImage(
    "banner_back.png",
    isRtl: false,
  );
  static const AppPathImage bannerB = AppPathImage("image.jpg", isRtl: false);

  static const AppPathImage banner1 = AppPathImage("banner.png", isRtl: true);
  static const AppPathImage banner2 = AppPathImage("banner2.png", isRtl: true);
  static const AppPathImage sports1 = AppPathImage("sports.png", isRtl: true);
  static const AppPathImage sports2 = AppPathImage("sports2.png", isRtl: true);
  static const AppPathImage pngegg = AppPathImage("pngegg.png", isRtl: true);
  static const AppPathImage pngegg2 = AppPathImage("pngegg2.png", isRtl: true);
  static const AppPathImage delete = AppPathImage("delete.png", isRtl: true);
  static const AppPathImage swim = AppPathImage("swim.png", isRtl: true);
  static const AppPathImage yoga = AppPathImage("yoga.png", isRtl: true);
  static const AppPathImage yoga2 = AppPathImage(
    "sunset-yoga-pose-stockcake.webp",
    isRtl: true,
  );

  // -- Animations
  static const String deliveredEmailIllustration =
      "assets/images/sammy-line-come-back-later.png";
  static const String staticSuccessIllustration =
      "assets/images/sammy-line-success.png";

  // -- OnBoarding Texts
  static const String facebook = "assets/images/Frame_1.svg";

  static const String google = "assets/images/ph_google-logo-bold.svg";

  static const String apple = "assets/images/Frame_2.svg";
  // -- OnBoarding Texts
  static const String onBoardingImage1 =
      "assets/images/on_boarding_images/sammy-line-searching.gif";
  static const String onBoardingImage2 =
      "assets/images/on_boarding_images/sammy-line-shopping.gif";
  static const String onBoardingImage3 =
      "assets/images/on_boarding_images/sammy-line-delivery.gif";
  // -- App Logos
  static const String darkAppLogo =
      "assets/images/t-store-splash-logo-black.png";
  static const String lightAppLogo =
      "assets/images/t-store-splash-logo-white.png";
}

class AppPathImage {
  final String? _path;
  final String _name;
  final bool isRtl;
  const AppPathImage(
    this._name, {
    String path = "assets/images/",
    this.isRtl = false,
  }) : _path = path;
  String get path => _path! + _name;
}
