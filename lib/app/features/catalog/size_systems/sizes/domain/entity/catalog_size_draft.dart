import 'package:decimal/decimal.dart';
import 'package:equatable/equatable.dart';

class CatalogSizeDraft extends Equatable {
  const CatalogSizeDraft({
    required this.sizeGroupId,
    required this.name,
    required this.code,
    this.numericValue,
    this.sortOrder = 0,
    this.isActive = true,
  });

  /// Fixed by the route context, never edited in the form.
  final int sizeGroupId;
  final String name;
  final String code;
  final Decimal? numericValue;
  final int sortOrder;
  final bool isActive;

  @override
  List<Object?> get props => [
    sizeGroupId,
    name,
    code,
    numericValue,
    sortOrder,
    isActive,
  ];
}
