// ════════════════════════════════════════════════════════════
//  domain/entities/hero_banner_entity.dart
//  Pure domain entity — no Flutter. The accent colour is an ARGB int;
//  the presentation layer converts it (see home_entity_ui.dart).
// ════════════════════════════════════════════════════════════

class HeroBannerEntity {
  const HeroBannerEntity({
    required this.bgImage,
    required this.personImage,
    required this.badge,
    required this.titleLine1,
    required this.titleAccent,
    required this.subtitle,
    required this.statNumber1,
    required this.statLabel1,
    required this.statNumber2,
    required this.statLabel2,
    required this.statNumber3,
    required this.statLabel3,
    this.accentColorValue = 0xFF00E5FF,
  });

  final String bgImage;
  final String personImage;
  final String badge;
  final String titleLine1;
  final String titleAccent;
  final String subtitle;
  final String statNumber1;
  final String statLabel1;
  final String statNumber2;
  final String statLabel2;
  final String statNumber3;
  final String statLabel3;
  final int accentColorValue;
}
