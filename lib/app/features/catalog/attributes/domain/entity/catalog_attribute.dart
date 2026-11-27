import 'package:equatable/equatable.dart';

enum AttributeDataType { text, number, boolean, date, json, option }

class CatalogAttribute extends Equatable {
  const CatalogAttribute({
    required this.id,
    required this.name,
    required this.code,
    required this.dataType,
    required this.unitId,
    required this.unitName,
    required this.unitSymbol,
    required this.optionSetId,
    required this.optionSetName,
    required this.optionSetCode,
    required this.isFilterable,
    required this.isActive,
    required this.linkedProductTypesCount,
    required this.valueCount,
  });
  final int id;
  final String name;
  final String code;
  final AttributeDataType dataType;
  final int? unitId;
  final String? unitName;
  final String? unitSymbol;
  final int? optionSetId;
  final String? optionSetName;
  final String? optionSetCode;
  final bool isFilterable;
  final bool isActive;

  /// Null means the relationship count is unknown.
  final int? linkedProductTypesCount;

  /// Null means the relationship count is unknown.
  final int? valueCount;
  bool get isInUse =>
      linkedProductTypesCount == null ||
      valueCount == null ||
      linkedProductTypesCount! > 0 ||
      valueCount! > 0;
  bool get canDelete => !isInUse;
  bool get canChangeType => !isInUse;
  @override
  List<Object?> get props => [
    id,
    name,
    code,
    dataType,
    unitId,
    unitName,
    unitSymbol,
    optionSetId,
    optionSetName,
    optionSetCode,
    isFilterable,
    isActive,
    linkedProductTypesCount,
    valueCount,
  ];
}
