import 'package:accounting_software/app/features/catalog/tags/domain/entity/catalog_tag.dart';

class TagModel {
  const TagModel({
    required this.id,
    required this.name,
    required this.slug,
    required this.isActive,
  });

  final int id;
  final String name;
  final String slug;
  final bool isActive;

  factory TagModel.fromJson(Map<String, dynamic> json) {
    final rawId = json['id'];
    final id = rawId is int ? rawId : int.tryParse(rawId.toString());
    if (id == null) throw const FormatException('Invalid tag id');

    return TagModel(
      id: id,
      name: json['name'] as String,
      slug: json['slug'] as String,
      isActive: json['is_active'] as bool? ?? true,
    );
  }

  CatalogTag toEntity() =>
      CatalogTag(id: id, name: name, slug: slug, isActive: isActive);
}
