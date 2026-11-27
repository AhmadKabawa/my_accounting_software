import 'package:accounting_software/app/features/catalog/colors/domain/entity/catalog_color.dart';

class ColorModel {
  const ColorModel({
    required this.id,
    required this.name,
    required this.code,
    this.hexCode,
    required this.isActive,
    required this.sortOrder,
    this.createdAt,
    this.productCount,
    this.componentCount,
  });

  final int id;
  final String name;
  final String code;
  final String? hexCode;
  final bool isActive;
  final int sortOrder;
  final DateTime? createdAt;
  final int? productCount;
  final int? componentCount;

  factory ColorModel.fromJson(Map<String, dynamic> json) {
    final rawId = json['id'];
    final id = rawId is int ? rawId : int.tryParse(rawId.toString());
    if (id == null) throw const FormatException('Invalid color id');

    return ColorModel(
      id: id,
      name: json['name'] as String,
      code: json['code'] as String,
      hexCode: json['hex_code'] as String?,
      isActive: json['is_active'] as bool? ?? true,
      sortOrder: (json['sort_order'] as num?)?.toInt() ?? 0,
      createdAt: DateTime.tryParse(json['created_at']?.toString() ?? ''),
      productCount: (json['product_count'] as num?)?.toInt(),
      componentCount: (json['component_count'] as num?)?.toInt(),
    );
  }

  ColorModel withUsage({int? productCount, int? componentCount}) => ColorModel(
    id: id,
    name: name,
    code: code,
    hexCode: hexCode,
    isActive: isActive,
    sortOrder: sortOrder,
    createdAt: createdAt,
    productCount: productCount,
    componentCount: componentCount,
  );

  CatalogColor toEntity() => CatalogColor(
    id: id,
    name: name,
    code: code,
    hexCode: hexCode,
    isActive: isActive,
    sortOrder: sortOrder,
    createdAt: createdAt,
    productCount: productCount,
    componentCount: componentCount,
  );
}
