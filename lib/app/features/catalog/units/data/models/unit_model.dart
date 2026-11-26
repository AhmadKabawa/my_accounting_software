import 'package:accounting_software/app/features/catalog/units/domain/entity/catalog_unit.dart';

class UnitModel {
  const UnitModel({required this.id, required this.name, required this.symbol, required this.type, required this.isActive, required this.usageCount});
  final int id;
  final String name;
  final String symbol;
  final UnitType type;
  final bool isActive;
  final int? usageCount;

  factory UnitModel.fromJson(Map<String, dynamic> json) {
    final rawId = json['id'];
    final id = rawId is int ? rawId : int.tryParse(rawId.toString());
    if (id == null) throw const FormatException('Invalid unit id');
    final typeName = json['unit_type']?.toString();
    final matchingTypes = UnitType.values.where((item) => item.name == typeName);
    if (matchingTypes.isEmpty) throw const FormatException('Invalid unit type');
    final products = _readCount(json['product_variants']);
    final attributes = _readCount(json['attributes']);
    return UnitModel(
      id: id,
      name: json['name'] as String,
      symbol: json['symbol'] as String,
      type: matchingTypes.first,
      isActive: json['is_active'] as bool? ?? true,
      usageCount: products == null || attributes == null ? null : products + attributes,
    );
  }

  static int? _readCount(Object? value) {
    if (value is List && value.isNotEmpty && value.first is Map<String, dynamic>) {
      final count = (value.first as Map<String, dynamic>)['count'];
      return count is num ? count.toInt() : null;
    }
    if (value is Map<String, dynamic>) {
      final count = value['count'];
      return count is num ? count.toInt() : null;
    }
    return null;
  }

  CatalogUnit toEntity() => CatalogUnit(id: id, name: name, symbol: symbol, type: type, isActive: isActive, usageCount: usageCount);
}
