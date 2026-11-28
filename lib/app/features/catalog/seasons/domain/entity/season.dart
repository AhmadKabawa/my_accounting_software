import 'package:equatable/equatable.dart';

enum SeasonType { summer, winter, spring, autumn }

class CatalogSeason extends Equatable {
  const CatalogSeason({
    required this.id,
    required this.name,
    required this.code,
    this.seasonType,
    this.startDate,
    this.endDate,
    required this.isActive,
  });

  final int id;
  final String name;
  final String code;
  final SeasonType? seasonType;
  final DateTime? startDate;
  final DateTime? endDate;
  final bool isActive;

  @override
  List<Object?> get props => [
    id,
    name,
    code,
    seasonType,
    startDate,
    endDate,
    isActive,
  ];
}
