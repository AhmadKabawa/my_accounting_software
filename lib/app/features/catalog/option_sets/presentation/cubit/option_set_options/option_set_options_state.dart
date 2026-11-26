import 'package:equatable/equatable.dart';
import 'package:accounting_software/app/core/error/failures/failure.dart';
import 'package:accounting_software/app/features/catalog/option_sets/domain/entity/option_set.dart';

enum OptionSetOptionsStatus { initial, loading, ready, saving, failed }

class OptionSetOptionsState extends Equatable {
  const OptionSetOptionsState({
    this.status = OptionSetOptionsStatus.initial,
    this.options = const [],
    this.failure,
  });

  final OptionSetOptionsStatus status;
  final List<CatalogOption> options;
  final Failure? failure;

  OptionSetOptionsState copyWith({
    OptionSetOptionsStatus? status,
    List<CatalogOption>? options,
    Failure? failure,
    bool clearFailure = false,
  }) => OptionSetOptionsState(
    status: status ?? this.status,
    options: options ?? this.options,
    failure: clearFailure ? null : failure ?? this.failure,
  );

  @override
  List<Object?> get props => [status, options, failure];
}
