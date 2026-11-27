import 'package:accounting_software/app/core/foundation/base/use_case.dart';
import 'package:accounting_software/app/core/presentation/state_management/base_cubit.dart';
import 'package:accounting_software/app/features/catalog/attributes/domain/usecase/get_attribute_option_set_choices_use_case.dart';
import 'package:accounting_software/app/features/catalog/attributes/domain/usecase/get_attribute_unit_choices_use_case.dart';
import 'package:accounting_software/app/features/catalog/attributes/presentation/cubit/attribute_lookups/attribute_lookups_state.dart';

class AttributeLookupsCubit extends BaseCubit<AttributeLookupsState, Never> {
  AttributeLookupsCubit({
    required GetAttributeUnitChoicesUseCase getUnits,
    required GetAttributeOptionSetChoicesUseCase getOptionSets,
  }) : _getUnits = getUnits,
       _getOptionSets = getOptionSets,
       super(const AttributeLookupsState());
  final GetAttributeUnitChoicesUseCase _getUnits;
  final GetAttributeOptionSetChoicesUseCase _getOptionSets;
  int _version = 0;
  Future<void> load() async {
    if (isClosed) return;
    final version = ++_version;
    emit(
      state.copyWith(
        loading: true,
        clearUnitFailure: true,
        clearOptionSetFailure: true,
      ),
    );
    final results = await Future.wait([
      _getUnits(NoParams()),
      _getOptionSets(NoParams()),
    ]);
    if (isClosed || version != _version) return;
    final units = results[0];
    final sets = results[1];
    emit(
      state.copyWith(
        loading: false,
        units: units.fold((_) => state.units, (value) => value),
        optionSets: sets.fold((_) => state.optionSets, (value) => value),
        unitFailure: units.fold((failure) => failure, (_) => null),
        optionSetFailure: sets.fold((failure) => failure, (_) => null),
        clearUnitFailure: units.isRight(),
        clearOptionSetFailure: sets.isRight(),
      ),
    );
  }

  @override
  Future<void> close() {
    _version++;
    return super.close();
  }
}
