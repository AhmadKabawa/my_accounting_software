import 'package:accounting_software/app/features/catalog/brands/domain/entity/brand.dart';

class BrandModel {
  const BrandModel({
    required this.id,
    required this.name,
    required this.slug,
    this.logo,
    this.description,
    required this.isActive,
    this.productCount,
  });

  final int id;
  final String name;
  final String slug;
  final String? logo;
  final String? description;
  final bool isActive;
  final int? productCount;

  factory BrandModel.fromJson(Map<String, dynamic> json) {
    final rawId = json['id'];
    final id = rawId is int ? rawId : int.tryParse(rawId.toString());
    if (id == null) throw const FormatException('Invalid brand id');

    return BrandModel(
      id: id,
      name: json['name'] as String,
      slug: json['slug'] as String,
      logo: json['logo'] as String?,
      description: json['description'] as String?,
      isActive: json['is_active'] as bool? ?? true,
      productCount: _readProductCount(json['products']),
    );
  }

  static int? _readProductCount(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toInt();
    if (value is Map<String, dynamic>) {
      final count = value['count'];
      return count is num ? count.toInt() : null;
    }
    if (value is List) {
      if (value.isEmpty) return 0;
      final first = value.first;
      if (first is Map<String, dynamic>) {
        final count = first['count'];
        return count is num ? count.toInt() : null;
      }
    }
    return null;
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'slug': slug,
    'logo': logo,
    'description': description,
    'is_active': isActive,
    if (productCount != null) 'products': {'count': productCount},
  };

  Brand toEntity() => Brand(
    id: id,
    name: name,
    slug: slug,
    logo: logo,
    description: description,
    isActive: isActive,
    productCount: productCount,
  );
}
