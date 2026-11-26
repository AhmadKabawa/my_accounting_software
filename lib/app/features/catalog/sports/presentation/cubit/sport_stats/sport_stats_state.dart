import 'package:equatable/equatable.dart';
import 'package:accounting_software/app/core/error/failures/failure.dart';
import 'package:accounting_software/app/features/catalog/sports/domain/entity/sport_stats.dart';

enum SportStatsStatus { initial, loading, ready, failed }

class SportStatsState extends Equatable {
  const SportStatsState({
    this.status = SportStatsStatus.initial,
    this.stats,
    this.failure,
  });

  final SportStatsStatus status;
  final SportStats? stats;
  final Failure? failure;

  SportStatsState copyWith({
    SportStatsStatus? status,
    SportStats? stats,
    Failure? failure,
    bool clearFailure = false,
  }) => SportStatsState(
    status: status ?? this.status,
    stats: stats ?? this.stats,
    failure: clearFailure ? null : failure ?? this.failure,
  );

  @override
  List<Object?> get props => [status, stats, failure];
}
