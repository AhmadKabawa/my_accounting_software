import 'package:equatable/equatable.dart';
import 'package:accounting_software/app/core/foundation/base/use_case.dart';
import 'package:accounting_software/app/core/presentation/state_management/base_cubit.dart';
import 'package:accounting_software/app/features/catalog/size_systems/groups/domain/entity/gender_option.dart';
import 'package:accounting_software/app/features/catalog/size_systems/groups/domain/usecase/size_groups_use_cases.dart';

class GenderOptionsState extends Equatable {
  const GenderOptionsState({this.genders = const [], this.loaded = false});

  final List<GenderOption> genders;
  final bool loaded;

  String? nameOf(int? id) {
    if (id == null) return null;
    for (final gender in genders) {
      if (gender.id == id) return gender.name;
    }
    return null;
  }

  @override
  List<Object?> get props => [genders, loaded];
}

/// Loads the read-only genders once for the groups list (filter and editor).
/// A failure or an empty table is not an error: gender is optional.
class GenderOptionsCubit extends BaseCubit<GenderOptionsState, Never> {
  GenderOptionsCubit({required GetGenderOptionsUseCase getGenders})
    : _getGenders = getGenders,
      super(const GenderOptionsState());

  final GetGenderOptionsUseCase _getGenders;

  Future<void> load() async {
    if (isClosed) return;
    final result = await _getGenders(NoParams());
    if (isClosed) return;
    result.fold(
      (_) => emit(const GenderOptionsState(loaded: true)),
      (genders) => emit(GenderOptionsState(genders: genders, loaded: true)),
    );
  }
}
