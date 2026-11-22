import 'package:equatable/equatable.dart';
import 'package:accounting_software/app/core/error/failures/failure.dart';
import 'package:accounting_software/app/features/catalog/colors/domain/entity/color_stats.dart';

enum ColorStatsStatus { initial, loading, ready, failed }

class ColorStatsState extends Equatable {
  const ColorStatsState({
    this.status = ColorStatsStatus.initial,
    this.stats,
    this.failure,
  });

  final ColorStatsStatus status;
  final ColorStats? stats;
  final Failure? failure;

  ColorStatsState copyWith({
    ColorStatsStatus? status,
    ColorStats? stats,
    Failure? failure,
    bool clearFailure = false,
  }) => ColorStatsState(
    status: status ?? this.status,
    stats: stats ?? this.stats,
    failure: clearFailure ? null : failure ?? this.failure,
  );

  @override
  List<Object?> get props => [status, stats, failure];
}
