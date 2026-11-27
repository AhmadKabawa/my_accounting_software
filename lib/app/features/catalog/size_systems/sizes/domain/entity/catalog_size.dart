import 'package:decimal/decimal.dart';
import 'package:equatable/equatable.dart';

/// A row of `sizes` inside one size group (named `CatalogSize` to avoid the
/// Flutter `Size` type).
class CatalogSize extends Equatable {
  const CatalogSize({
    required this.id,
    required this.sizeGroupId,
    required this.name,
    required this.code,
    this.numericValue,
    required this.sortOrder,
    required this.isActive,
    this.productCount,
    this.updatedAt,
  });

  final int id;
  final int sizeGroupId;
  final String name;
  final String code;
  final Decimal? numericValue;
  final int sortOrder;
  final bool isActive;

  /// Embedded `product_sizes(count)`; null means unknown (never 0).
  final int? productCount;
  final DateTime? updatedAt;

  /// Deletion is offered only when the usage count is known and zero.
  bool get canDelete => productCount == 0;

  @override
  List<Object?> get props => [
    id,
    sizeGroupId,
    name,
    code,
    numericValue,
    sortOrder,
    isActive,
    productCount,
    updatedAt,
  ];
}
