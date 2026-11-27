import 'package:decimal/decimal.dart';
import 'package:accounting_software/app/features/catalog/size_systems/shared/data/embedded_count.dart';
import 'package:accounting_software/app/features/catalog/size_systems/sizes/domain/entity/catalog_size.dart';

class CatalogSizeModel {
  const CatalogSizeModel({
    required this.id,
    required this.sizeGroupId,
    required this.name,
    required this.code,
    this.numericValue,
    required this.sortOrder,
    required this.isActive,
    this.productCount,
    this.updatedAt,
  });

  final int id;
  final int sizeGroupId;
  final String name;
  final String code;
  final Decimal? numericValue;
  final int sortOrder;
  final bool isActive;
  final int? productCount;
  final DateTime? updatedAt;

  factory CatalogSizeModel.fromJson(Map<String, dynamic> json) {
    final id = readInt(json['id']);
    final groupId = readInt(json['size_group_id']);
    if (id == null || groupId == null) {
      throw const FormatException('Invalid size row');
    }
    return CatalogSizeModel(
      id: id,
      sizeGroupId: groupId,
      name: json['name'] as String,
      code: json['code'] as String,
      numericValue: _readDecimal(json['numeric_value']),
      sortOrder: (json['sort_order'] as num?)?.toInt() ?? 0,
      isActive: json['is_active'] as bool? ?? true,
      productCount: readEmbeddedCount(json['product_sizes']),
      updatedAt: DateTime.tryParse('${json['updated_at'] ?? ''}'),
    );
  }

  /// `numeric(8,2)` arrives as a JSON number or string; parsed through its
  /// text so no binary floating point error is introduced.
  static Decimal? _readDecimal(dynamic value) {
    if (value == null) return null;
    if (value is num) return Decimal.tryParse(value.toString());
    if (value is String) return Decimal.tryParse(value);
    return null;
  }

  CatalogSize toEntity() => CatalogSize(
    id: id,
    sizeGroupId: sizeGroupId,
    name: name,
    code: code,
    numericValue: numericValue,
    sortOrder: sortOrder,
    isActive: isActive,
    productCount: productCount,
    updatedAt: updatedAt,
  );
}
