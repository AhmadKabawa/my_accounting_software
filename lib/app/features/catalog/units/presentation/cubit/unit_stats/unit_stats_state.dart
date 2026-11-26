import 'package:equatable/equatable.dart';
import 'package:accounting_software/app/core/error/failures/failure.dart';
import 'package:accounting_software/app/features/catalog/units/domain/entity/unit_stats.dart';

enum UnitStatsStatus { initial, loading, ready, failed }

class UnitStatsState extends Equatable {
  const UnitStatsState({
    this.status = UnitStatsStatus.initial,
    this.stats,
    this.failure,
  });
  final UnitStatsStatus status;
  final UnitStats? stats;
  final Failure? failure;

  UnitStatsState copyWith({
    UnitStatsStatus? status,
    UnitStats? stats,
    Failure? failure,
    bool clearFailure = false,
  }) => UnitStatsState(
    status: status ?? this.status,
    stats: stats ?? this.stats,
    failure: clearFailure ? null : failure ?? this.failure,
  );

  @override
  List<Object?> get props => [status, stats, failure];
}
