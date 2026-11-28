import 'package:equatable/equatable.dart';
import 'season.dart';

class SeasonDraft extends Equatable {
  const SeasonDraft({
    required this.name,
    required this.code,
    this.seasonType,
    this.startDate,
    this.endDate,
    this.isActive,
  });

  final String name;
  final String code;
  final SeasonType? seasonType;
  final DateTime? startDate;
  final DateTime? endDate;
  final bool? isActive;

  @override
  List<Object?> get props => [
    name,
    code,
    seasonType,
    startDate,
    endDate,
    isActive,
  ];
}
