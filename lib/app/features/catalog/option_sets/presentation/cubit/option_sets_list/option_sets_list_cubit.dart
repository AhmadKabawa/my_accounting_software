import 'package:dartz/dartz.dart';
import 'package:accounting_software/app/core/error/failures/failure.dart';
import 'package:accounting_software/app/core/foundation/config/app_config.dart';
import 'package:accounting_software/app/core/localization/translations/app_key.dart';
import 'package:accounting_software/app/core/presentation/state_management/paged_list/paged_list_cubit.dart';
import 'package:accounting_software/app/core/presentation/state_management/paged_list/paged_result.dart';
import 'package:accounting_software/app/features/catalog/option_sets/domain/entity/option_set.dart';
import 'package:accounting_software/app/features/catalog/option_sets/domain/entity/option_set_list_query.dart';
import 'package:accounting_software/app/features/catalog/option_sets/domain/usecase/delete_option_set_use_case.dart';
import 'package:accounting_software/app/features/catalog/option_sets/domain/usecase/get_option_sets_use_case.dart';
import 'package:accounting_software/app/features/catalog/option_sets/domain/usecase/set_option_set_active_use_case.dart';
import 'package:accounting_software/app/features/catalog/option_sets/presentation/cubit/option_sets_list/option_sets_list_effect.dart';
import 'package:accounting_software/app/features/catalog/option_sets/presentation/localization/option_sets_keys.dart';

class OptionSetsListCubit extends PagedListCubit<OptionSet, OptionSetListQuery, OptionSetsListEffect> {
  OptionSetsListCubit({
    required GetOptionSetsUseCase getOptionSets,
    required SetOptionSetActiveUseCase setActive,
    required DeleteOptionSetUseCase deleteOptionSet,
    required super.flashMessages,
  }) : _getOptionSets = getOptionSets,
       _setActive = setActive,
       _deleteOptionSet = deleteOptionSet,
       super(initialQuery: const OptionSetListQuery(
         page: AppConfig.defaultPage,
         pageSize: AppConfig.defaultPageSize,
       ));

  final GetOptionSetsUseCase _getOptionSets;
  final SetOptionSetActiveUseCase _setActive;
  final DeleteOptionSetUseCase _deleteOptionSet;

  @override
  Future<Either<Failure, PagedResult<OptionSet>>> fetch(OptionSetListQuery query) =>
      _getOptionSets(query);

  @override
  Future<Either<Failure, Unit>> deleteItem(OptionSet item) =>
      _deleteOptionSet(item.id);

  @override
  Failure? beforeDelete(OptionSet item) => item.canDelete
      ? null
      : const ValidationFailure(messageKey: OptionSetsKeys.deleteBlocked);

  @override
  AppKey get deletedMessageKey => OptionSetsKeys.deleted;

  @override
  OptionSetsListEffect buildMutationEffect(PagedMutationKind kind) =>
      OptionSetsMutatedEffect.fromPaged(kind);

  Future<void> _loadIfChanged(OptionSetListQuery query) async {
    if (state.query == query) return;
    await applyQueryAndLoad(query);
  }

  Future<void> setStatus(OptionSetStatusFilter status) =>
      _loadIfChanged(state.query.copyWith(status: status, page: 1));

  Future<void> setSort(bool ascending) =>
      _loadIfChanged(state.query.withSort(ascending));

  Future<Either<Failure, Unit>> activate(int id) => runMutation(
    () => _setActive(SetOptionSetActiveParams(id: id, isActive: true)),
    kind: PagedMutationKind.statusChanged,
    successMessage: OptionSetsKeys.statusUpdated,
    flashFailure: true,
    rowId: id,
  );

  Future<Either<Failure, Unit>> deactivate(int id) => runMutation(
    () => _setActive(SetOptionSetActiveParams(id: id, isActive: false)),
    kind: PagedMutationKind.statusChanged,
    successMessage: OptionSetsKeys.statusUpdated,
    flashFailure: true,
    rowId: id,
  );

  Future<void> onSaved({required bool isNew}) => reloadAfterMutation(
    isNew ? PagedMutationKind.created : PagedMutationKind.updated,
  );
}
