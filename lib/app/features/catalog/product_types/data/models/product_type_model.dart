import 'package:accounting_software/app/features/catalog/product_types/domain/entity/product_type.dart';

class ProductTypeModel {
  const ProductTypeModel({
    required this.id,
    required this.name,
    required this.code,
    this.description,
    required this.sortOrder,
    required this.isActive,
    this.productCount,
    this.sizeGroupCount,
    this.attributeCount,
    this.optionSetCount,
    this.careInstructionCount,
    this.updatedAt,
  });

  final int id;
  final String name;
  final String code;
  final String? description;
  final int sortOrder;
  final bool isActive;
  final int? productCount;
  final int? sizeGroupCount;
  final int? attributeCount;
  final int? optionSetCount;
  final int? careInstructionCount;
  final DateTime? updatedAt;

  factory ProductTypeModel.fromJson(Map<String, dynamic> json) {
    final rawId = json['id'];
    final id = rawId is int ? rawId : int.tryParse('$rawId');
    if (id == null) throw const FormatException('Invalid product type id');
    return ProductTypeModel(
      id: id,
      name: json['name'] as String,
      code: json['code'] as String,
      description: json['description'] as String?,
      sortOrder: (json['sort_order'] as num?)?.toInt() ?? 0,
      isActive: json['is_active'] as bool? ?? true,
      productCount: _readCount(json['products']),
      sizeGroupCount: _readCount(json['product_type_size_groups']),
      attributeCount: _readCount(json['product_type_attributes']),
      optionSetCount: _readCount(json['product_type_option_sets']),
      careInstructionCount: _readCount(json['product_type_care_instructions']),
      updatedAt: DateTime.tryParse(json['updated_at']?.toString() ?? ''),
    );
  }

  static int? _readCount(dynamic value) {
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

  ProductType toEntity() => ProductType(
    id: id,
    name: name,
    code: code,
    description: description,
    sortOrder: sortOrder,
    isActive: isActive,
    productCount: productCount,
    sizeGroupCount: sizeGroupCount,
    attributeCount: attributeCount,
    optionSetCount: optionSetCount,
    careInstructionCount: careInstructionCount,
    updatedAt: updatedAt,
  );
}
