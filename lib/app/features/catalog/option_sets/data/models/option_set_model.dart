import 'package:accounting_software/app/features/catalog/option_sets/domain/entity/option_set.dart';

class OptionSetModel {
  const OptionSetModel({
    required this.id,
    required this.name,
    required this.code,
    required this.selectionType,
    required this.isActive,
    required this.options,
    required this.usageCount,
  });
  final int id;
  final String name;
  final String code;
  final OptionSelectionType selectionType;
  final bool isActive;
  final List<CatalogOption> options;
  final int? usageCount;

  factory OptionSetModel.fromJson(Map<String, dynamic> json) {
    final rawId = json['id'];
    final id = rawId is int ? rawId : int.tryParse(rawId.toString());
    if (id == null) throw const FormatException('Invalid option set id');
    final rawType = json['selection_type']?.toString();
    final types = OptionSelectionType.values.where(
      (item) => item.name == rawType,
    );
    if (types.isEmpty)
      throw const FormatException('Invalid option selection type');
    final attributes = _count(json['attributes']);
    final typeLinks = _count(json['product_type_option_sets']);
    final rawOptions = json['options'];
    final options = rawOptions is List
        ? rawOptions
              .whereType<Map<String, dynamic>>()
              .map(CatalogOptionModel.fromJson)
              .map((item) => item.toEntity())
              .toList()
        : <CatalogOption>[];
    return OptionSetModel(
      id: id,
      name: json['name'] as String,
      code: json['code'] as String,
      selectionType: types.first,
      isActive: json['is_active'] as bool? ?? true,
      options: options,
      usageCount: attributes == null || typeLinks == null
          ? null
          : attributes + typeLinks,
    );
  }

  static int? _count(Object? value) {
    if (value is List &&
        value.isNotEmpty &&
        value.first is Map<String, dynamic>) {
      final count = (value.first as Map<String, dynamic>)['count'];
      return count is num ? count.toInt() : null;
    }
    if (value is Map<String, dynamic>) {
      final count = value['count'];
      return count is num ? count.toInt() : null;
    }
    return null;
  }

  OptionSet toEntity() => OptionSet(
    id: id,
    name: name,
    code: code,
    selectionType: selectionType,
    isActive: isActive,
    options: options,
    usageCount: usageCount,
  );
}

class CatalogOptionModel {
  const CatalogOptionModel({
    required this.id,
    required this.name,
    required this.code,
    required this.sortOrder,
    required this.isActive,
  });
  final int id;
  final String name;
  final String code;
  final int sortOrder;
  final bool isActive;
  factory CatalogOptionModel.fromJson(Map<String, dynamic> json) {
    final rawId = json['id'];
    final id = rawId is int ? rawId : int.tryParse(rawId.toString());
    if (id == null) throw const FormatException('Invalid option id');
    return CatalogOptionModel(
      id: id,
      name: json['name'] as String,
      code: json['code'] as String,
      sortOrder: (json['sort_order'] as num?)?.toInt() ?? 0,
      isActive: json['is_active'] as bool? ?? true,
    );
  }
  CatalogOption toEntity() => CatalogOption(
    id: id,
    name: name,
    code: code,
    sortOrder: sortOrder,
    isActive: isActive,
  );
}
