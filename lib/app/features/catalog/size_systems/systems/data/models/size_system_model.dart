import 'package:accounting_software/app/features/catalog/size_systems/shared/data/embedded_count.dart';
import 'package:accounting_software/app/features/catalog/size_systems/systems/domain/entity/size_system.dart';

class SizeSystemModel {
  const SizeSystemModel({
    required this.id,
    required this.name,
    required this.code,
    this.description,
    required this.isActive,
    this.groupCount,
    this.updatedAt,
  });

  final int id;
  final String name;
  final String code;
  final String? description;
  final bool isActive;
  final int? groupCount;
  final DateTime? updatedAt;

  factory SizeSystemModel.fromJson(Map<String, dynamic> json) {
    final id = readInt(json['id']);
    if (id == null) throw const FormatException('Invalid size system id');
    return SizeSystemModel(
      id: id,
      name: json['name'] as String,
      code: json['code'] as String,
      description: json['description'] as String?,
      isActive: json['is_active'] as bool? ?? true,
      groupCount: readEmbeddedCount(json['size_groups']),
      updatedAt: DateTime.tryParse('${json['updated_at'] ?? ''}'),
    );
  }

  SizeSystem toEntity() => SizeSystem(
    id: id,
    name: name,
    code: code,
    description: description,
    isActive: isActive,
    groupCount: groupCount,
    updatedAt: updatedAt,
  );
}
