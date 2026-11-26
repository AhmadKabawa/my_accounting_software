import 'package:equatable/equatable.dart';
import 'package:accounting_software/app/core/error/failures/failure.dart';
import 'package:accounting_software/app/features/catalog/option_sets/domain/entity/option_set_stats.dart';

enum OptionSetStatsStatus { initial, loading, ready, failed }

class OptionSetStatsState extends Equatable {
  const OptionSetStatsState({
    this.status = OptionSetStatsStatus.initial,
    this.stats,
    this.failure,
  });

  final OptionSetStatsStatus status;
  final OptionSetStats? stats;
  final Failure? failure;

  OptionSetStatsState copyWith({
    OptionSetStatsStatus? status,
    OptionSetStats? stats,
    Failure? failure,
    bool clearFailure = false,
  }) => OptionSetStatsState(
    status: status ?? this.status,
    stats: stats ?? this.stats,
    failure: clearFailure ? null : failure ?? this.failure,
  );

  @override
  List<Object?> get props => [status, stats, failure];
}
