import 'package:accounting_software/app/features/catalog/size_systems/shared/data/embedded_count.dart';
import 'package:accounting_software/app/features/catalog/size_systems/groups/domain/entity/gender_option.dart';
import 'package:accounting_software/app/features/catalog/size_systems/groups/domain/entity/size_group.dart';

class SizeGroupModel {
  const SizeGroupModel({
    required this.id,
    required this.sizeSystemId,
    this.genderId,
    required this.name,
    required this.code,
    this.description,
    required this.isActive,
    this.sizeCount,
    this.productTypeCount,
    this.productUsageCount,
    this.updatedAt,
  });

  final int id;
  final int sizeSystemId;
  final int? genderId;
  final String name;
  final String code;
  final String? description;
  final bool isActive;
  final int? sizeCount;
  final int? productTypeCount;
  final int? productUsageCount;
  final DateTime? updatedAt;

  factory SizeGroupModel.fromJson(Map<String, dynamic> json) {
    final id = readInt(json['id']);
    final systemId = readInt(json['size_system_id']);
    if (id == null || systemId == null) {
      throw const FormatException('Invalid size group row');
    }
    return SizeGroupModel(
      id: id,
      sizeSystemId: systemId,
      genderId: readInt(json['gender_id']),
      name: json['name'] as String,
      code: json['code'] as String,
      description: json['description'] as String?,
      isActive: json['is_active'] as bool? ?? true,
      sizeCount: readEmbeddedCount(json['sizes']),
      productTypeCount: readEmbeddedCount(json['product_type_size_groups']),
      productUsageCount: readEmbeddedCount(json['product_size_groups']),
      updatedAt: DateTime.tryParse('${json['updated_at'] ?? ''}'),
    );
  }

  SizeGroup toEntity() => SizeGroup(
    id: id,
    sizeSystemId: sizeSystemId,
    genderId: genderId,
    name: name,
    code: code,
    description: description,
    isActive: isActive,
    sizeCount: sizeCount,
    productTypeCount: productTypeCount,
    productUsageCount: productUsageCount,
    updatedAt: updatedAt,
  );
}

class GenderOptionModel {
  const GenderOptionModel({
    required this.id,
    required this.name,
    required this.isActive,
  });

  final int id;
  final String name;
  final bool isActive;

  factory GenderOptionModel.fromJson(Map<String, dynamic> json) {
    final id = readInt(json['id']);
    if (id == null) throw const FormatException('Invalid gender id');
    return GenderOptionModel(
      id: id,
      name: json['name'] as String,
      isActive: json['is_active'] as bool? ?? true,
    );
  }

  GenderOption toEntity() =>
      GenderOption(id: id, name: name, isActive: isActive);
}
