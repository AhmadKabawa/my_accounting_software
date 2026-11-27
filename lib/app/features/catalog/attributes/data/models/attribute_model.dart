import 'package:accounting_software/app/features/catalog/attributes/domain/entity/catalog_attribute.dart';

class AttributeModel {
  const AttributeModel({
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
  final int? linkedProductTypesCount;
  final int? valueCount;

  factory AttributeModel.fromJson(Map<String, dynamic> json) {
    final rawId = json['id'];
    final id = rawId is int ? rawId : int.tryParse(rawId.toString());
    if (id == null) throw const FormatException('Invalid attribute id');
    final rawType = json['data_type']?.toString();
    final types = AttributeDataType.values.where(
      (item) => item.name == rawType,
    );
    if (types.isEmpty) {
      throw const FormatException('Invalid attribute data type');
    }
    final unit = _firstMap(json['units']);
    final optionSet = _firstMap(json['option_sets']);
    return AttributeModel(
      id: id,
      name: json['name'] as String,
      code: json['code'] as String,
      dataType: types.first,
      unitId: _intOrNull(json['unit_id']),
      unitName: unit?['name'] as String?,
      unitSymbol: unit?['symbol'] as String?,
      optionSetId: _intOrNull(json['option_set_id']),
      optionSetName: optionSet?['name'] as String?,
      optionSetCode: optionSet?['code'] as String?,
      isFilterable: json['is_filterable'] as bool? ?? false,
      isActive: json['is_active'] as bool? ?? true,
      linkedProductTypesCount: _count(json['product_type_attributes']),
      valueCount: _count(json['product_attribute_values']),
    );
  }

  static int? _intOrNull(Object? value) =>
      value is num ? value.toInt() : int.tryParse(value?.toString() ?? '');
  static Map<String, dynamic>? _firstMap(Object? value) {
    if (value is Map<String, dynamic>) return value;
    if (value is List &&
        value.isNotEmpty &&
        value.first is Map<String, dynamic>) {
      return value.first as Map<String, dynamic>;
    }
    return null;
  }

  static int? _count(Object? value) {
    final map = _firstMap(value);
    final count = map?['count'];
    return count is num ? count.toInt() : null;
  }

  CatalogAttribute toEntity() => CatalogAttribute(
    id: id,
    name: name,
    code: code,
    dataType: dataType,
    unitId: unitId,
    unitName: unitName,
    unitSymbol: unitSymbol,
    optionSetId: optionSetId,
    optionSetName: optionSetName,
    optionSetCode: optionSetCode,
    isFilterable: isFilterable,
    isActive: isActive,
    linkedProductTypesCount: linkedProductTypesCount,
    valueCount: valueCount,
  );
}
