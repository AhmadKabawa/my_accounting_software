import 'package:equatable/equatable.dart';
import 'package:accounting_software/app/core/error/failures/failure.dart';
import 'package:accounting_software/app/features/catalog/tags/domain/entity/tag_stats.dart';

enum TagStatsStatus { initial, loading, ready, failed }

class TagStatsState extends Equatable {
  const TagStatsState({
    this.status = TagStatsStatus.initial,
    this.stats,
    this.failure,
  });

  final TagStatsStatus status;
  final TagStats? stats;
  final Failure? failure;

  TagStatsState copyWith({
    TagStatsStatus? status,
    TagStats? stats,
    Failure? failure,
    bool clearFailure = false,
  }) => TagStatsState(
    status: status ?? this.status,
    stats: stats ?? this.stats,
    failure: clearFailure ? null : failure ?? this.failure,
  );

  @override
  List<Object?> get props => [status, stats, failure];
}
