import 'package:accounting_software/app/features/catalog/genders/domain/entity/gender.dart';

class GenderModel {
  const GenderModel({
    required this.id,
    required this.name,
    required this.code,
    required this.isActive,
    required this.sortOrder,
    required this.sizeGroupCount,
  });

  final int id;
  final int sortOrder;
  final String name;
  final String code;
  final bool isActive;
  final int? sizeGroupCount;

  factory GenderModel.fromJson(Map<String, dynamic> json) {
    final rawId = json['id'];
    final id = rawId is int ? rawId : int.tryParse(rawId.toString());
    if (id == null) throw const FormatException('Invalid gender id');
    final relation = json['size_groups'];
    int? usage;
    if (relation is List && relation.isNotEmpty) {
      final count = relation.first;
      if (count is Map && count['count'] is num) {
        usage = (count['count'] as num).toInt();
      }
    }
    return GenderModel(
      id: id,
      name: json['name'] as String,
      code: json['code'] as String,
      isActive: json['is_active'] as bool? ?? true,
      sortOrder: (json['sort_order'] as num?)?.toInt() ?? 0,
      sizeGroupCount: usage,
    );
  }

  Gender toEntity() => Gender(
    id: id,
    name: name,
    code: code,
    isActive: isActive,
    sortOrder: sortOrder,
    sizeGroupCount: sizeGroupCount,
  );
}
