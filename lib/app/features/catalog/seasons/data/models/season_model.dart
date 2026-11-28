import 'package:accounting_software/app/core/foundation/date/date_only.dart';
import 'package:accounting_software/app/features/catalog/seasons/domain/entity/season.dart';

class SeasonModel {
  const SeasonModel({
    required this.id,
    required this.name,
    required this.code,
    required this.isActive,
    this.seasonType,
    this.startDate,
    this.endDate,
  });

  final int id;
  final String name;
  final String code;
  final bool isActive;
  final SeasonType? seasonType;
  final DateTime? startDate;
  final DateTime? endDate;

  factory SeasonModel.fromJson(Map<String, dynamic> json) {
    final rawId = json['id'];
    final id = rawId is int ? rawId : int.tryParse(rawId.toString());
    if (id == null) throw const FormatException('Invalid season id');
    return SeasonModel(
      id: id,
      name: _requiredString(json, 'name'),
      code: _requiredString(json, 'code'),
      isActive: json['is_active'] is bool ? json['is_active'] as bool : true,
      seasonType: _parseType(json['season_type']),
      startDate: DateOnly.fromApiString(json['start_date'] as String?),
      endDate: DateOnly.fromApiString(json['end_date'] as String?),
    );
  }

  CatalogSeason toEntity() => CatalogSeason(
    id: id,
    name: name,
    code: code,
    isActive: isActive,
    seasonType: seasonType,
    startDate: startDate,
    endDate: endDate,
  );

  static String _requiredString(Map<String, dynamic> json, String key) {
    final value = json[key];
    if (value is String && value.trim().isNotEmpty) return value;
    throw FormatException('Invalid $key');
  }

  static SeasonType? _parseType(Object? raw) {
    for (final value in SeasonType.values) {
      if (value.name == raw) return value;
    }
    return null;
  }
}
