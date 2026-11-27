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
      name: _requiredString(json, 'name'),
      code: _requiredString(json, 'code'),
      isActive: _boolean(json['is_active'], fallback: true),
      materialType: _parseMaterialType(json['material_type']),
      description: _optionalString(json['description']),
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
 static MaterialType? _parseMaterialType(Object? raw){for(final value in MaterialType.values){if(value.name==raw)return value;}return null;}
}
