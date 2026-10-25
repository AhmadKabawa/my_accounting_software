// No Flutter import needed — pure Dart constants.

abstract final class SpacingTokens {
  static const double s0 = 0;
  static const double s4 = 4;
  static const double s8 = 8;
  static const double s12 = 12;
  static const double s16 = 16;
  static const double s20 = 20;
  static const double s24 = 24;
  static const double s32 = 32;
  static const double s40 = 40;
  static const double s48 = 48;
  static const double s56 = 56;  // ✅ إضافة
  static const double s64 = 64;
  static const double s72 = 72;  // ✅ إضافة
  static const double s80 = 80;
  static const double s96 = 96;  // ✅ إضافة
  static const double s112 = 112; // ✅ إضافة
}

abstract final class RadiusTokens {
  static const double r0 = 0;
  static const double r4 = 4;
  static const double r8 = 8;
  static const double r12 = 12;
  static const double r16 = 16;
  static const double r20 = 20;
  static const double r24 = 24;
  static const double r32 = 32;
  static const double r40 = 40;
  static const double r48 = 48;
  static const double r56 = 56;  // ✅ إضافة
  static const double r64 = 64;  // ✅ إضافة
  static const double r999 = 999;
}

abstract final class FontTokens {
  static const double f8 = 8;    // ✅ إضافة لـ tiny
  static const double f10 = 10;
  static const double f12 = 12;
  static const double f14 = 14;
  static const double f16 = 16;
  static const double f18 = 18;
  static const double f20 = 20;
  static const double f22 = 22;  // ✅ إضافة
  static const double f24 = 24;
  static const double f26 = 26;  // ✅ إضافة
  static const double f28 = 28;
  static const double f30 = 30;  // ✅ إضافة
  static const double f32 = 32;
  static const double f36 = 36;
  static const double f40 = 40;
  static const double f44 = 44;  // ✅ إضافة
  static const double f48 = 48;
}

abstract final class IconTokens {
  static const double i16 = 16;
  static const double i18 = 18;  // ✅ إضافة
  static const double i20 = 20;
  static const double i22 = 22;  // ✅ إضافة
  static const double i24 = 24;
  static const double i28 = 28;
  static const double i32 = 32;
  static const double i36 = 36;  // ✅ إضافة
  static const double i40 = 40;
  static const double i44 = 44;  // ✅ إضافة
  static const double i48 = 48;
  static const double i52 = 52;  // ✅ إضافة
  static const double i56 = 56;
}

abstract final class ElevationTokens {
  static const double e0 = 0;
  static const double e1 = 1;
  static const double e2 = 2;
  static const double e3 = 3;   // ✅ إضافة
  static const double e4 = 4;
  static const double e6 = 6;   // ✅ إضافة
  static const double e8 = 8;
  static const double e12 = 12;
  static const double e16 = 16;
  static const double e20 = 20; // ✅ إضافة
  static const double e24 = 24; // ✅ إضافة
}

abstract final class SizeTokens {
  static const double s0 = 0;
  static const double s20 = 20;
  static const double s24 = 24;
  static const double s28 = 28;
  static const double s32 = 32;
  static const double s36 = 36;
  static const double s40 = 40;
  static const double s44 = 44;  // ✅ إضافة
  static const double s48 = 48;
  static const double s52 = 52;  // ✅ إضافة
  static const double s56 = 56;
  static const double s60 = 60;  // ✅ إضافة
  static const double s64 = 64;
  static const double s72 = 72;
  static const double s80 = 80;
  static const double s96 = 96;
  static const double s112 = 112;
  static const double s128 = 128;
  static const double s144 = 144;
  static const double s160 = 160;
  static const double s192 = 192;
  static const double s224 = 224;
  static const double s256 = 256;
  static const double s280 = 280;
  static const double s320 = 320;
  static const double s360 = 360;
  static const double s384 = 384;
  static const double s448 = 448;
  static const double s512 = 512;

  // Breakpoints
  static const double breakpointMobile = 600;
  static const double breakpointTablet = 1024;
  static const double breakpointDesktop = 1440;

  // Max widths
  static const double maxWidthMobile = 540;
  static const double maxWidthTablet = 960;
  static const double maxWidthDesktop = 1280;
  static const double maxWidthWide = 1600;
}