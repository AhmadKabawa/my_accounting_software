import 'package:accounting_software/app/features/catalog/fabric_types/domain/entity/fabric_type.dart';

class FabricTypeModel {
  const FabricTypeModel({
    required this.id,
    required this.name,
    required this.code,
    required this.isActive,
    required this.isNamedFabric,
    this.fabricCategory,
    this.description,
  });
  final int id;
  final String name;
  final String code;
  final bool isActive;
  final bool isNamedFabric;
  final FabricCategory? fabricCategory;
  final String? description;
  factory FabricTypeModel.fromJson(Map<String, dynamic> json) {
    final raw = json['id'];
    final id = raw is int ? raw : int.tryParse(raw.toString());
    if (id == null) throw const FormatException('Invalid fabric type id');
    return FabricTypeModel(
      id: id,
      name: _requiredString(json, 'name'),
      code: _requiredString(json, 'code'),
      isActive: _boolean(json['is_active'], fallback: true),
      isNamedFabric: _boolean(json['is_named_fabric'], fallback: false),
      fabricCategory: _parseFabricCategory(json['fabric_category']),
      description: _optionalString(json['description']),
    );
  }
  CatalogFabricType toEntity() => CatalogFabricType(
    id: id,
    name: name,
    code: code,
    isActive: isActive,
    isNamedFabric: isNamedFabric,
    fabricCategory: fabricCategory,
    description: description,
  );
  Map<String, Object?> toJson() => {
    'name': name,
    'code': code,
    'fabric_category': fabricCategory?.name,
    'is_named_fabric': isNamedFabric,
    'description': description,
    'is_active': isActive,
  };
 static String _requiredString(Map<String, dynamic> json, String key) {
    final value = json[key];
    if (value is String && value.trim().isNotEmpty) return value;
    throw FormatException('Invalid $key');
  }
  static String? _optionalString(Object? value) => value is String ? value : null;
  static bool _boolean(Object? value, {required bool fallback}) => value is bool ? value : fallback;
  static FabricCategory? _parseFabricCategory(Object? raw){for(final value in FabricCategory.values){if(value.name==raw)return value;}return null;}
}
