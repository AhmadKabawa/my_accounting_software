import 'package:accounting_software/app/features/catalog/materials/domain/entity/material.dart';

class MaterialModel {
  const MaterialModel({
    required this.id,
    required this.name,
    required this.code,
    required this.isActive,
    this.materialType,
    this.description,
  });
  final int id;
  final String name;
  final String code;
  final bool isActive;
  final MaterialType? materialType;
  final String? description;
  factory MaterialModel.fromJson(Map<String, dynamic> json) {
    final raw = json['id'];
    final id = raw is int ? raw : int.tryParse(raw.toString());
    if (id == null) throw const FormatException('Invalid material id');
    return MaterialModel(
      id: id,
      name: json['name'] as String,
      code: json['code'] as String,
      isActive: json['is_active'] as bool? ?? true,
      materialType: MaterialType.values
          .where((e) => e.name == json['material_type'])
          .firstOrNull,
      description: json['description'] as String?,
    );
  }
  CatalogMaterial toEntity() => CatalogMaterial(
    id: id,
    name: name,
    code: code,
    isActive: isActive,
    materialType: materialType,
    description: description,
  );
  Map<String, Object?> toJson() => {
    'name': name,
    'code': code,
    'material_type': materialType?.name,
    'description': description,
    'is_active': isActive,
  };
}
