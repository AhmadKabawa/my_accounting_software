import 'package:accounting_software/app/features/catalog/age_groups/domain/entity/age_group.dart';
import 'package:accounting_software/app/features/catalog/size_systems/shared/data/embedded_count.dart';

class AgeGroupModel {
  const AgeGroupModel({
    required this.id,
    required this.name,
    this.minAge,
    this.maxAge,
    required this.isActive,
    required this.sortOrder,
    this.productCount,
  });
  final int id;
  final String name;
  final int? minAge;
  final int? maxAge;
  final bool isActive;
  final int sortOrder;
  final int? productCount;

  factory AgeGroupModel.fromJson(Map<String, dynamic> json) {
    final rawId = json['id'];
    final id = rawId is int ? rawId : int.tryParse('$rawId');
    if (id == null) throw const FormatException('Invalid age group id');
    return AgeGroupModel(
      id: id,
      name: json['name'] as String,
      minAge: (json['min_age'] as num?)?.toInt(),
      maxAge: (json['max_age'] as num?)?.toInt(),
      isActive: json['is_active'] as bool? ?? true,
      sortOrder: (json['sort_order'] as num?)?.toInt() ?? 0,
      productCount: readEmbeddedCount(json['product_age_groups']),
    );
  }
  AgeGroup toEntity() => AgeGroup(
    id: id,
    name: name,
    minAge: minAge,
    maxAge: maxAge,
    isActive: isActive,
    sortOrder: sortOrder,
    productCount: productCount,
  );
}
