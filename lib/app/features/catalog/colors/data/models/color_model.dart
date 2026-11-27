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
  });

  final int id;
  final String name;
  final String code;
  final String? hexCode;
  final bool isActive;
  final int sortOrder;
  final DateTime? createdAt;

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
    );
  }

  CatalogColor toEntity() => CatalogColor(
    id: id,
    name: name,
    code: code,
    hexCode: hexCode,
    isActive: isActive,
    sortOrder: sortOrder,
    createdAt: createdAt,
  );
}
