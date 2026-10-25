// ════════════════════════════════════════════════════════════
//  data/models/product_model.dart
//  JSON ↔ Domain mapping. Only the data layer knows about JSON.
// ════════════════════════════════════════════════════════════

import 'package:accounting_software/app/features/home/domain/entity/product_entity.dart';
import 'package:accounting_software/app/features/home/presentation/cubit/home_state.dart';

class ProductModel extends ProductEntity {
  const ProductModel({
    required super.id,
    required super.name,
    super.description,
    required super.price,
    super.salePrice,
    required super.categoryId,
    super.brandId,
    required super.stock,
    required super.images,
    super.thumbnail,
    super.rating,
    super.reviewsCount,
    super.isFeatured,
    super.isActive,
    super.attributes,
    super.createdAt,
    super.updatedAt,
    super.categoryName,
    super.brandName,
  });

  // ── fromJson ─────────────────────────────────────────────

  factory ProductModel.fromJson(Map<String, dynamic> json) => ProductModel(
    id: json['id'] as String,
    name: json['name'] as String,
    description: json['description'] as String?,
    price: (json['price'] as num).toDouble(),
    salePrice: json['sale_price'] != null
        ? (json['sale_price'] as num).toDouble()
        : null,
    categoryId: json['category_id'] as String,
    brandId: json['brand_id'] as String?,
    stock: json['stock'] as int? ?? 0,
    images:
        (json['images'] as List<dynamic>?)?.map((e) => e as String).toList() ??
        [],
    thumbnail: json['thumbnail'] as String?,
    rating: (json['rating'] as num?)?.toDouble() ?? 0,
    reviewsCount: json['reviews_count'] as int? ?? 0,
    isFeatured: json['is_featured'] as bool? ?? false,
    isActive: json['is_active'] as bool? ?? true,
    attributes: json['attributes'] as Map<String, dynamic>?,
    createdAt: json['created_at'] != null
        ? DateTime.tryParse(json['created_at'] as String)
        : null,
    updatedAt: json['updated_at'] != null
        ? DateTime.tryParse(json['updated_at'] as String)
        : null,
    categoryName: json['category_name'] as String?,
    brandName: json['brand_name'] as String?,
  );

  // ── toJson ───────────────────────────────────────────────

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'description': description,
    'price': price,
    'sale_price': salePrice,
    'category_id': categoryId,
    'brand_id': brandId,
    'stock': stock,
    'images': images,
    'thumbnail': thumbnail,
    'rating': rating,
    'reviews_count': reviewsCount,
    'is_featured': isFeatured,
    'is_active': isActive,
    'attributes': attributes,
    'created_at': createdAt?.toIso8601String(),
    'updated_at': updatedAt?.toIso8601String(),
    'category_name': categoryName,
    'brand_name': brandName,
  };
}
