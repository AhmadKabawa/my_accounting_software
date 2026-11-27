import 'package:equatable/equatable.dart';

/// A catalog product type and the usage projections needed for safe deletion.
class ProductType extends Equatable {
  const ProductType({
    required this.id,
    required this.name,
    required this.code,
    this.description,
    required this.sortOrder,
    required this.isActive,
    this.productCount,
    this.sizeGroupCount,
    this.attributeCount,
    this.optionSetCount,
    this.careInstructionCount,
    this.updatedAt,
  });

  final int id;
  final String name;
  final String code;
  final String? description;
  final int sortOrder;
  final bool isActive;
  final int? productCount;
  final int? sizeGroupCount;
  final int? attributeCount;
  final int? optionSetCount;
  final int? careInstructionCount;
  final DateTime? updatedAt;

  /// A null count is unknown, never equivalent to zero.
  bool get usageKnown =>
      productCount != null &&
      sizeGroupCount != null &&
      attributeCount != null &&
      optionSetCount != null &&
      careInstructionCount != null;

  bool get hasUsage =>
      !usageKnown ||
      productCount! > 0 ||
      sizeGroupCount! > 0 ||
      attributeCount! > 0 ||
      optionSetCount! > 0 ||
      careInstructionCount! > 0;

  bool get canDelete => usageKnown && !hasUsage;

  /// Code is immutable when any relationship is present or usage is unknown.
  bool get codeLocked => !usageKnown || hasUsage;

  @override
  List<Object?> get props => [
    id,
    name,
    code,
    description,
    sortOrder,
    isActive,
    productCount,
    sizeGroupCount,
    attributeCount,
    optionSetCount,
    careInstructionCount,
    updatedAt,
  ];
}
