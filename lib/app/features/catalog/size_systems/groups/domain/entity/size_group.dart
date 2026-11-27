import 'package:equatable/equatable.dart';

/// A row of `size_groups` (men's shoes, kids' clothes...) inside one system.
class SizeGroup extends Equatable {
  const SizeGroup({
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

  /// Embedded relation counts; null means unknown (never treated as 0).
  final int? sizeCount;
  final int? productTypeCount;
  final int? productUsageCount;
  final DateTime? updatedAt;

  /// Deletion is offered only when every usage count is known and zero.
  bool get canDelete =>
      sizeCount == 0 && productTypeCount == 0 && productUsageCount == 0;

  @override
  List<Object?> get props => [
    id,
    sizeSystemId,
    genderId,
    name,
    code,
    description,
    isActive,
    sizeCount,
    productTypeCount,
    productUsageCount,
    updatedAt,
  ];
}
