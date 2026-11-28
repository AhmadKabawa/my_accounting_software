import 'package:accounting_software/app/core/foundation/date/date_only.dart';
import 'package:accounting_software/app/features/catalog/collections/domain/entity/collection.dart';

class CollectionModel {
  const CollectionModel({
    required this.id,
    required this.name,
    required this.code,
    required this.isActive,
    this.description,
    this.image,
    this.startDate,
    this.endDate,
  });

  final int id;
  final String name;
  final String code;
  final bool isActive;
  final String? description;
  final String? image;
  final DateTime? startDate;
  final DateTime? endDate;

  factory CollectionModel.fromJson(Map<String, dynamic> json) {
    final rawId = json['id'];
    final id = rawId is int ? rawId : int.tryParse(rawId.toString());
    if (id == null) throw const FormatException('Invalid collection id');
    return CollectionModel(
      id: id,
      name: _requiredString(json, 'name'),
      code: _requiredString(json, 'code'),
      isActive: json['is_active'] is bool ? json['is_active'] as bool : true,
      description: _optionalString(json['description']),
      image: _optionalString(json['image']),
      startDate: DateOnly.fromApiString(json['start_date'] as String?),
      endDate: DateOnly.fromApiString(json['end_date'] as String?),
    );
  }

  CatalogCollection toEntity() => CatalogCollection(
    id: id,
    name: name,
    code: code,
    isActive: isActive,
    description: description,
    image: image,
    startDate: startDate,
    endDate: endDate,
  );

  static String _requiredString(Map<String, dynamic> json, String key) {
    final value = json[key];
    if (value is String && value.trim().isNotEmpty) return value;
    throw FormatException('Invalid $key');
  }

  static String? _optionalString(Object? value) =>
      value is String ? value : null;
}
