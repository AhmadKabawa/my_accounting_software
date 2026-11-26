import 'package:accounting_software/app/core/presentation/state_management/base_cubit.dart';
import 'package:accounting_software/app/features/catalog/option_sets/domain/entity/option_set.dart';
import 'package:accounting_software/app/features/catalog/option_sets/domain/entity/option_set_draft.dart';
import 'package:accounting_software/app/features/catalog/option_sets/domain/usecase/get_options_use_case.dart';
import 'package:accounting_software/app/features/catalog/option_sets/domain/usecase/create_option_use_case.dart';
import 'package:accounting_software/app/features/catalog/option_sets/domain/usecase/update_option_use_case.dart';
import 'package:accounting_software/app/features/catalog/option_sets/domain/usecase/set_option_active_use_case.dart';
import 'package:accounting_software/app/features/catalog/option_sets/presentation/cubit/option_set_options/option_set_options_state.dart';

class OptionSetOptionsCubit extends BaseCubit<OptionSetOptionsState, Never> {
  OptionSetOptionsCubit({
    required GetOptionsUseCase getOptions,
    required CreateOptionUseCase createOption,
    required UpdateOptionUseCase updateOption,
    required SetOptionActiveUseCase setOptionActive,
  }) : _getOptions = getOptions,
       _createOption = createOption,
       _updateOption = updateOption,
       _setOptionActive = setOptionActive,
       super(const OptionSetOptionsState());

  final GetOptionsUseCase _getOptions;
  final CreateOptionUseCase _createOption;
  final UpdateOptionUseCase _updateOption;
  final SetOptionActiveUseCase _setOptionActive;
  int? _optionSetId;
  int _requestVersion = 0;

  Future<void> load(int optionSetId) async {
    if (isClosed) return;
    _optionSetId = optionSetId;
    final version = ++_requestVersion;
    emit(state.copyWith(status: OptionSetOptionsStatus.loading, clearFailure: true));
    final result = await _getOptions(GetOptionsParams(optionSetId: optionSetId));
    if (isClosed || version != _requestVersion) return;
    result.fold(
      (failure) => emit(state.copyWith(status: OptionSetOptionsStatus.failed, failure: failure)),
      (options) => emit(state.copyWith(status: OptionSetOptionsStatus.ready, options: options, clearFailure: true)),
    );
  }

  Future<void> saveOption({int? optionId, required CatalogOptionDraft draft}) async {
    final setId = _optionSetId;
    if (setId == null || isClosed || state.status == OptionSetOptionsStatus.saving) return;
    emit(state.copyWith(status: OptionSetOptionsStatus.saving, clearFailure: true));
    final result = optionId == null
        ? await _createOption(CreateOptionParams(optionSetId: setId, draft: draft))
        : await _updateOption(UpdateOptionParams(optionId: optionId, draft: draft));
    if (isClosed) return;
    result.fold(
      (failure) => emit(state.copyWith(status: OptionSetOptionsStatus.failed, failure: failure)),
      (_) {},
    );
    if (result.isRight()) await load(setId);
  }

  Future<void> setActive({required int optionId, required bool isActive}) async {
    final setId = _optionSetId;
    if (setId == null || isClosed) return;
    emit(state.copyWith(status: OptionSetOptionsStatus.saving, clearFailure: true));
    final result = await _setOptionActive(SetOptionActiveParams(optionId: optionId, isActive: isActive));
    if (isClosed) return;
    result.fold(
      (failure) => emit(state.copyWith(status: OptionSetOptionsStatus.failed, failure: failure)),
      (_) {},
    );
    if (result.isRight()) await load(setId);
    );
  }

  @override
  Future<void> close() {
    _requestVersion++;
    return super.close();
  }
}
