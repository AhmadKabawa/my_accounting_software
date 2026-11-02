part of '../app_enums.dart';

class AppAspectRatio extends ResponsiveToken {
  const AppAspectRatio(super.mobile, super.tablet, super.desktop);

  // ─── Predefined tokens ───────────────────────────────────────────

  /// Banner image — width / height ratio
  /// Mobile: 1:1 | Tablet: 16:10 | Desktop: 16:9
  static const bannerImage = AppAspectRatio(1, 16 / 10, 16 / 9);

  @override
  AppAspectRatio overrideWith({
    double? mobile,
    double? tablet,
    double? desktop,
  }) {
    return AppAspectRatio(
      mobile ?? this.mobile,
      tablet ?? this.tablet,
      desktop ?? this.desktop,
    );
  }
}
