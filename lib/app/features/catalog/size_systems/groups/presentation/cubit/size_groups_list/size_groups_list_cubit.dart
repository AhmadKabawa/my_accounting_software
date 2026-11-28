import 'package:dartz/dartz.dart';
import 'package:accounting_software/app/core/error/failures/failure.dart';
import 'package:accounting_software/app/core/foundation/config/app_config.dart';
import 'package:accounting_software/app/core/localization/translations/app_key.dart';
import 'package:accounting_software/app/core/presentation/state_management/paged_list/paged_list_cubit.dart';
import 'package:accounting_software/app/core/presentation/state_management/paged_list/paged_result.dart';
import 'package:accounting_software/app/features/catalog/size_systems/groups/domain/entity/size_group.dart';
import 'package:accounting_software/app/features/catalog/size_systems/groups/domain/entity/size_group_list_query.dart';
import 'package:accounting_software/app/features/catalog/size_systems/groups/domain/usecase/size_groups_use_cases.dart';
import 'package:accounting_software/app/features/catalog/size_systems/groups/presentation/cubit/size_groups_list/size_groups_list_effect.dart';
import 'package:accounting_software/app/features/catalog/size_systems/presentation/localization/size_systems_keys.dart';
import 'package:accounting_software/app/features/catalog/size_systems/shared/domain/failures/size_system_failures.dart';
import 'package:accounting_software/app/features/catalog/size_systems/shared/domain/size_status_filter.dart';

class SizeGroupsListCubit
    extends
        PagedListCubit<SizeGroup, SizeGroupListQuery, SizeGroupsListEffect> {
  SizeGroupsListCubit({
    required int sizeSystemId,
    required GetSizeGroupsUseCase get,
    required SetSizeGroupActiveUseCase setActive,
    required DeleteSizeGroupUseCase delete,
    required super.flashMessages,
  }) : _get = get,
       _setActive = setActive,
       _delete = delete,
       super(
         initialQuery: SizeGroupListQuery(
           sizeSystemId: sizeSystemId,
           page: AppConfig.defaultPage,
           pageSize: AppConfig.defaultPageSize,
         ),
       );

  final GetSizeGroupsUseCase _get;
  final SetSizeGroupActiveUseCase _setActive;
  final DeleteSizeGroupUseCase _delete;

  @override
  Future<Either<Failure, PagedResult<SizeGroup>>> fetch(
    SizeGroupListQuery query,
  ) => _get(query);

  @override
  Future<Either<Failure, Unit>> deleteItem(SizeGroup item) => _delete(item.id);

  /// Any unknown usage count is treated as "in use": the FK is the final judge.
  @override
  Failure? beforeDelete(SizeGroup item) =>
      item.canDelete ? null : const SizeGroupInUseFailure();

  @override
  AppKey get deletedMessageKey => SizeSystemsKeys.deleted;

  @override
  SizeGroupsListEffect buildMutationEffect(PagedMutationKind kind) =>
      SizeGroupsMutatedEffect.fromPaged(kind);

  Future<void> setStatus(SizeStatusFilter value) async {
    final query = state.query.withStatus(value);
    if (query != state.query) await applyQueryAndLoad(query);
  }

  Future<void> setGender(int? genderId) async {
    final query = state.query.withGender(genderId);
    if (query != state.query) await applyQueryAndLoad(query);
  }

  Future<void> setSort(SizeGroupSortField field, bool ascending) async {
    final query = state.query.withSort(field, ascending);
    if (query != state.query) await applyQueryAndLoad(query);
  }

  Future<Either<Failure, Unit>> activate(int id) => _toggle(id, true);

  Future<Either<Failure, Unit>> deactivate(int id) => _toggle(id, false);

  Future<Either<Failure, Unit>> _toggle(int id, bool isActive) => runMutation(
    () => _setActive(SetSizeGroupActiveParams(id: id, isActive: isActive)),
    kind: PagedMutationKind.statusChanged,
    successMessage: SizeSystemsKeys.statusUpdated,
    flashFailure: true,
    rowId: id,
  );

  Future<void> onSaved({required bool isNew}) => reloadAfterMutation(
    isNew ? PagedMutationKind.created : PagedMutationKind.updated,
  );
}
