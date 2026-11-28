import 'package:equatable/equatable.dart';
import 'package:accounting_software/app/core/error/failures/failure.dart';
import 'package:accounting_software/app/features/catalog/size_systems/systems/domain/entity/size_system_stats.dart';

enum SizeSystemStatsStatus { initial, loading, ready, failed }

class SizeSystemStatsState extends Equatable {
  const SizeSystemStatsState({
    this.status = SizeSystemStatsStatus.initial,
    this.stats,
    this.failure,
  });

  final SizeSystemStatsStatus status;
  final SizeSystemStats? stats;
  final Failure? failure;

  SizeSystemStatsState copyWith({
    SizeSystemStatsStatus? status,
    SizeSystemStats? stats,
    Failure? failure,
    bool clearFailure = false,
  }) => SizeSystemStatsState(
    status: status ?? this.status,
    stats: stats ?? this.stats,
    failure: clearFailure ? null : failure ?? this.failure,
  );

  @override
  List<Object?> get props => [status, stats, failure];
}
