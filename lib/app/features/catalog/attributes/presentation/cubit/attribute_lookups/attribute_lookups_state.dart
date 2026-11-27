import 'package:equatable/equatable.dart';
import 'package:accounting_software/app/core/error/failures/failure.dart';
import 'package:accounting_software/app/features/catalog/attributes/domain/entity/attribute_lookup_choices.dart';

class AttributeLookupsState extends Equatable {
  const AttributeLookupsState({
    this.units = const [],
    this.optionSets = const [],
    this.loading = false,
    this.unitFailure,
    this.optionSetFailure,
  });
  final List<AttributeUnitChoice> units;
  final List<AttributeOptionSetChoice> optionSets;
  final bool loading;
  final Failure? unitFailure;
  final Failure? optionSetFailure;
  AttributeLookupsState copyWith({
    List<AttributeUnitChoice>? units,
    List<AttributeOptionSetChoice>? optionSets,
    bool? loading,
    Failure? unitFailure,
    Failure? optionSetFailure,
    bool clearUnitFailure = false,
    bool clearOptionSetFailure = false,
  }) => AttributeLookupsState(
    units: units ?? this.units,
    optionSets: optionSets ?? this.optionSets,
    loading: loading ?? this.loading,
    unitFailure: clearUnitFailure ? null : unitFailure ?? this.unitFailure,
    optionSetFailure: clearOptionSetFailure
        ? null
        : optionSetFailure ?? this.optionSetFailure,
  );
  @override
  List<Object?> get props => [
    units,
    optionSets,
    loading,
    unitFailure,
    optionSetFailure,
  ];
}
