import 'package:dartz/dartz.dart';
import 'package:accounting_software/app/core/error/failures/failure.dart';
import 'package:accounting_software/app/core/foundation/config/app_config.dart';
import 'package:accounting_software/app/core/localization/translations/app_key.dart';
import 'package:accounting_software/app/core/presentation/state_management/paged_list/paged_list_cubit.dart';
import 'package:accounting_software/app/core/presentation/state_management/paged_list/paged_result.dart';
import 'package:accounting_software/app/features/catalog/age_groups/domain/entity/age_group.dart';
import 'package:accounting_software/app/features/catalog/age_groups/domain/entity/age_group_list_query.dart';
import 'package:accounting_software/app/features/catalog/age_groups/domain/failures/age_group_failures.dart';
import 'package:accounting_software/app/features/catalog/age_groups/domain/usecase/age_groups_use_cases.dart';
import 'package:accounting_software/app/features/catalog/age_groups/presentation/cubit/age_groups_list/age_groups_list_effect.dart';
import 'package:accounting_software/app/features/catalog/age_groups/presentation/localization/age_groups_keys.dart';

class AgeGroupsListCubit
    extends PagedListCubit<AgeGroup, AgeGroupListQuery, AgeGroupsListEffect> {
  AgeGroupsListCubit({
    required GetAgeGroupsUseCase get,
    required SetAgeGroupActiveUseCase setActive,
    required DeleteAgeGroupUseCase delete,
    required super.flashMessages,
  }) : _get = get,
       _active = setActive,
       _delete = delete,
       super(
         initialQuery: const AgeGroupListQuery(
           page: AppConfig.defaultPage,
           pageSize: AppConfig.defaultPageSize,
         ),
       );
  final GetAgeGroupsUseCase _get;
  final SetAgeGroupActiveUseCase _active;
  final DeleteAgeGroupUseCase _delete;
  @override
  Future<Either<Failure, PagedResult<AgeGroup>>> fetch(AgeGroupListQuery q) =>
      _get(q);
  @override
  Future<Either<Failure, Unit>> deleteItem(AgeGroup item) => _delete(item.id);
  @override
  Failure? beforeDelete(AgeGroup item) {
    if (item.productCount == null) return const AgeGroupUsageUnknownFailure();
    if (item.productCount! > 0) return const AgeGroupInUseFailure();
    return null;
  }

  @override
  AppKey get deletedMessageKey => AgeGroupsKeys.deleted;
  @override
  AgeGroupsListEffect buildMutationEffect(PagedMutationKind kind) =>
      AgeGroupsMutatedEffect.fromPaged(kind);
  Future<void> setStatus(AgeGroupStatusFilter value) async {
    if (state.query.status != value)
      await applyQueryAndLoad(state.query.withStatus(value));
  }

  Future<void> setSort(AgeGroupSortField field, bool ascending) async {
    final q = state.query.withSort(field, ascending);
    if (q != state.query) await applyQueryAndLoad(q);
  }

  Future<Either<Failure, Unit>> activate(int id) => runMutation(
    () => _active(SetAgeGroupActiveParams(id: id, isActive: true)),
    kind: PagedMutationKind.statusChanged,
    successMessage: AgeGroupsKeys.statusUpdated,
    flashFailure: true,
    rowId: id,
  );
  Future<Either<Failure, Unit>> deactivate(int id) => runMutation(
    () => _active(SetAgeGroupActiveParams(id: id, isActive: false)),
    kind: PagedMutationKind.statusChanged,
    successMessage: AgeGroupsKeys.statusUpdated,
    flashFailure: true,
    rowId: id,
  );
  Future<void> onAgeGroupSaved({required bool isNew}) => reloadAfterMutation(
    isNew ? PagedMutationKind.created : PagedMutationKind.updated,
  );
}
