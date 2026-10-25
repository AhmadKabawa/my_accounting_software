// ════════════════════════════════════════════════════════════
//  domain/entities/product_entity.dart
//  Pure domain entity — no Flutter, no JSON, no external deps
// ════════════════════════════════════════════════════════════

enum StockStatus { outOfStock, lowStock, inStock }

class ProductEntity {
  const ProductEntity({
    required this.id,
    required this.name,
    this.description,
    required this.price,
    this.salePrice,
    required this.categoryId,
    this.brandId,
    required this.stock,
    required this.images,
    this.thumbnail,
    this.rating = 0,
    this.reviewsCount = 0,
    this.isFeatured = false,
    this.isActive = true,
    this.attributes,
    this.createdAt,
    this.updatedAt,
    this.categoryName,
    this.brandName,
  });

  final String id;
  final String name;
  final String? description;
  final double price;
  final double? salePrice;
  final String categoryId;
  final String? brandId;
  final int stock;
  final List<String> images;
  final String? thumbnail;
  final double rating;
  final int reviewsCount;
  final bool isFeatured;
  final bool isActive;
  final Map<String, dynamic>? attributes;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String? categoryName;
  final String? brandName;

  // ── Computed ─────────────────────────────────────────────

  double get discountPercentage {
    if (salePrice == null || salePrice! >= price) return 0;
    return ((price - salePrice!) / price) * 100;
  }

  bool get hasDiscount => salePrice != null && salePrice! < price;

  double get effectivePrice => salePrice ?? price;

  bool get isInStock => stock > 0;

  StockStatus get stockStatus {
    if (stock <= 0) return StockStatus.outOfStock;
    if (stock <= 5) return StockStatus.lowStock;
    return StockStatus.inStock;
  }
}