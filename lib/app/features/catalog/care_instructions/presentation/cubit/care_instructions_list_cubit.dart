import 'package:dartz/dartz.dart';
import 'package:accounting_software/app/core/error/failures/failure.dart';
import 'package:accounting_software/app/core/foundation/config/app_config.dart';
import 'package:accounting_software/app/core/localization/translations/app_key.dart';
import 'package:accounting_software/app/core/presentation/state_management/paged_list/paged_list_cubit.dart';
import 'package:accounting_software/app/core/presentation/state_management/paged_list/paged_result.dart';
import 'package:accounting_software/app/features/catalog/care_instructions/domain/entity/care_instruction.dart';
import 'package:accounting_software/app/features/catalog/care_instructions/domain/entity/care_instruction_list_query.dart';
import 'package:accounting_software/app/features/catalog/care_instructions/domain/usecase/get_care_instructions_use_case.dart';
import 'package:accounting_software/app/features/catalog/care_instructions/domain/usecase/set_care_instruction_active_use_case.dart';
import 'package:accounting_software/app/features/catalog/care_instructions/domain/usecase/delete_care_instruction_use_case.dart';
import 'package:accounting_software/app/features/catalog/care_instructions/presentation/localization/care_instructions_keys.dart';
import 'package:accounting_software/app/features/catalog/care_instructions/presentation/cubit/care_instructions_list_effect.dart';

class CareInstructionsListCubit extends PagedListCubit<CareInstruction, CareInstructionListQuery, CareInstructionsListEffect> {
  CareInstructionsListCubit({
    required GetCareInstructionsUseCase getItems,
    required SetCareInstructionActiveUseCase setActive,
    required DeleteCareInstructionUseCase deleteItem,
    required super.flashMessages,
  }) : _get = getItems, _set = setActive, _delete = deleteItem,
       super(initialQuery: const CareInstructionListQuery(
         page: AppConfig.defaultPage, pageSize: AppConfig.defaultPageSize,
       ));

  final GetCareInstructionsUseCase _get;
  final SetCareInstructionActiveUseCase _set;
  final DeleteCareInstructionUseCase _delete;

  @override
  Future<Either<Failure, PagedResult<CareInstruction>>> fetch(CareInstructionListQuery query) => _get(query);

  @override
  Future<Either<Failure, Unit>> deleteItem(CareInstruction item) =>
      _delete(DeleteCareInstructionParams(item.id));

  @override
  AppKey get deletedMessageKey => CareInstructionsKeys.deleted;

  @override
  CareInstructionsListEffect buildMutationEffect(PagedMutationKind kind) =>
      CareInstructionsMutatedEffect(switch (kind) {
        PagedMutationKind.created => CareInstructionsMutationKind.created,
        PagedMutationKind.updated => CareInstructionsMutationKind.updated,
        PagedMutationKind.statusChanged => CareInstructionsMutationKind.statusChanged,
        PagedMutationKind.deleted => CareInstructionsMutationKind.deleted,
      });

  Future<void> setStatus(CareInstructionStatusFilter value) =>
      applyQueryAndLoad(state.query.copyWith(status: value, page: 1));

  Future<void> setCareType(CareType? value) =>
      applyQueryAndLoad(state.query.copyWith(careType: value, clearCareType: value == null, page: 1));

  Future<Either<Failure, Unit>> activate(int id) => runMutation(
    () => _set(SetCareInstructionActiveParams(id: id, isActive: true)),
    kind: PagedMutationKind.statusChanged,
    successMessage: CareInstructionsKeys.statusUpdated,
    flashFailure: true, rowId: id,
  );

  Future<Either<Failure, Unit>> deactivate(int id) => runMutation(
    () => _set(SetCareInstructionActiveParams(id: id, isActive: false)),
    kind: PagedMutationKind.statusChanged,
    successMessage: CareInstructionsKeys.statusUpdated,
    flashFailure: true, rowId: id,
  );

  Future<void> onSaved({required bool isNew}) => reloadAfterMutation(
    isNew ? PagedMutationKind.created : PagedMutationKind.updated,
  );
}
