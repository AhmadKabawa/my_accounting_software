import 'package:equatable/equatable.dart';
import 'package:accounting_software/app/core/error/failures/failure.dart';
import 'package:accounting_software/app/features/catalog/genders/domain/entity/gender_stats.dart';

enum GenderStatsStatus { initial, loading, ready, failed }

class GenderStatsState extends Equatable {
  const GenderStatsState({
    this.status = GenderStatsStatus.initial,
    this.stats,
    this.failure,
  });
  final GenderStatsStatus status;
  final GenderStats? stats;
  final Failure? failure;
  GenderStatsState copyWith({
    GenderStatsStatus? status,
    GenderStats? stats,
    Failure? failure,
    bool clearFailure = false,
  }) => GenderStatsState(
    status: status ?? this.status,
    stats: stats ?? this.stats,
    failure: clearFailure ? null : failure ?? this.failure,
  );
  @override
  List<Object?> get props => [status, stats, failure];
}
