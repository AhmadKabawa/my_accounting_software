import 'package:equatable/equatable.dart';
import 'package:accounting_software/app/core/error/failures/failure.dart';
import 'package:accounting_software/app/features/catalog/attributes/domain/entity/attribute_stats.dart';
enum AttributeStatsStatus { initial, loading, ready, failed }
class AttributeStatsState extends Equatable {
  const AttributeStatsState({this.status = AttributeStatsStatus.initial, this.stats, this.failure});
  final AttributeStatsStatus status;
  final AttributeStats? stats;
  final Failure? failure;
  AttributeStatsState copyWith({AttributeStatsStatus? status, AttributeStats? stats, Failure? failure, bool clearFailure = false}) =>
      AttributeStatsState(status: status ?? this.status, stats: stats ?? this.stats, failure: clearFailure ? null : failure ?? this.failure);
  @override
  List<Object?> get props => [status, stats, failure];
}