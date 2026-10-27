// ════════════════════════════════════════════════════════════
//  domain/entities/category_entity.dart
//  Pure domain entity — no Flutter. Icon and colour are plain values;
//  the presentation layer resolves them (see home_entity_ui.dart).
// ════════════════════════════════════════════════════════════

class CategoryEntity {
  const CategoryEntity({
    required this.id,
    required this.label,
    this.iconKey,
    this.accentColorValue = 0xFF00E5FF,
    this.productCount = 0,
  });

  final String id;
  final String label;
  final String? iconKey;
  final int accentColorValue;
  final int productCount;
}
