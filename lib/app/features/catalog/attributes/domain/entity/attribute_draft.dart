import 'package:equatable/equatable.dart';
import 'package:accounting_software/app/features/catalog/attributes/domain/entity/catalog_attribute.dart';

class AttributeDraft extends Equatable {
  const AttributeDraft({
    required this.name,
    required this.code,
    required this.dataType,
    this.unitId,
    this.optionSetId,
    required this.isFilterable,
    this.isActive,
  });
  final String name;
  final String code;
  final AttributeDataType dataType;
  final int? unitId;
  final int? optionSetId;
  final bool isFilterable;
  final bool? isActive;
  @override
  List<Object?> get props => [name, code, dataType, unitId, optionSetId, isFilterable, isActive];
}
