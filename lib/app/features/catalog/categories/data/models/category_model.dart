import 'package:accounting_software/app/features/catalog/categories/domain/entity/category.dart';

class CategoryModel {
  const CategoryModel({
    required this.id,
    this.parentId,
    required this.name,
    required this.slug,
    this.description,
    this.image,
    required this.sortOrder,
    required this.isActive,
    this.productCount = 0,
  });

  final int id;
  final int? parentId;
  final String name;
  final String slug;
  final String? description;
  final String? image;
  final int sortOrder;
  final bool isActive;
  final int productCount;

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    final id = _readInt(json['id']);
    if (id == null) throw const FormatException('Invalid category id');
    return CategoryModel(
      id: id,
      parentId: _readInt(json['parent_id']),
      name: json['name'] as String,
      slug: json['slug'] as String,
      description: json['description'] as String?,
      image: json['image'] as String?,
      sortOrder: (json['sort_order'] as num?)?.toInt() ?? 0,
      isActive: json['is_active'] as bool? ?? true,
      productCount: _readCount(json['product_categories']),
    );
  }

  static int? _readInt(dynamic value) =>
      value is int ? value : int.tryParse('$value');

  /// PostgREST returns the embedded count as `[{count: n}]`; a write response
  /// has no embed, so a missing value means 0 (a new category has no products).
  static int _readCount(dynamic value) {
    if (value is num) return value.toInt();
    if (value is Map<String, dynamic>) {
      final count = value['count'];
      return count is num ? count.toInt() : 0;
    }
    if (value is List && value.isNotEmpty) {
      final first = value.first;
      if (first is Map<String, dynamic>) {
        final count = first['count'];
        return count is num ? count.toInt() : 0;
      }
    }
    return 0;
  }

  Category toEntity() => Category(
    id: id,
    parentId: parentId,
    name: name,
    slug: slug,
    description: description,
    image: image,
    sortOrder: sortOrder,
    isActive: isActive,
    productCount: productCount,
  );
}
