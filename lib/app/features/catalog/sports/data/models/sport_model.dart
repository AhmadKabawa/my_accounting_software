import 'package:accounting_software/app/features/catalog/sports/domain/entity/sport.dart';

class SportModel {
  const SportModel({
    required this.id,
    required this.name,
    required this.code,
    this.description,
    required this.isActive,
    required this.sortOrder,
  });

  final int id;
  final String name;
  final String code;
  final String? description;
  final bool isActive;
  final int sortOrder;

  factory SportModel.fromJson(Map<String, dynamic> json) {
    final rawId = json['id'];
    final id = rawId is int ? rawId : int.tryParse(rawId.toString());
    if (id == null) throw const FormatException('Invalid sport id');

    return SportModel(
      id: id,
      name: json['name'] as String,
      code: json['code'] as String,
      description: json['description'] as String?,
      isActive: json['is_active'] as bool? ?? true,
      sortOrder: (json['sort_order'] as num?)?.toInt() ?? 0,
    );
  }

  Sport toEntity() => Sport(
    id: id,
    name: name,
    code: code,
    description: description,
    isActive: isActive,
    sortOrder: sortOrder,
  );
}
