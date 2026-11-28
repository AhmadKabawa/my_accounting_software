import 'package:dartz/dartz.dart';
import 'package:accounting_software/app/core/error/failures/failure.dart';
import 'package:accounting_software/app/core/foundation/config/app_config.dart';
import 'package:accounting_software/app/core/localization/translations/app_key.dart';
import 'package:accounting_software/app/core/presentation/state_management/paged_list/paged_list_cubit.dart';
import 'package:accounting_software/app/core/presentation/state_management/paged_list/paged_result.dart';
import 'package:accounting_software/app/features/catalog/size_systems/presentation/localization/size_systems_keys.dart';
import 'package:accounting_software/app/features/catalog/size_systems/shared/domain/failures/size_system_failures.dart';
import 'package:accounting_software/app/features/catalog/size_systems/shared/domain/size_status_filter.dart';
import 'package:accounting_software/app/features/catalog/size_systems/systems/domain/entity/size_system.dart';
import 'package:accounting_software/app/features/catalog/size_systems/systems/domain/entity/size_system_list_query.dart';
import 'package:accounting_software/app/features/catalog/size_systems/systems/domain/usecase/size_systems_use_cases.dart';
import 'package:accounting_software/app/features/catalog/size_systems/systems/presentation/cubit/size_systems_list/size_systems_list_effect.dart';

class SizeSystemsListCubit
    extends
        PagedListCubit<SizeSystem, SizeSystemListQuery, SizeSystemsListEffect> {
  SizeSystemsListCubit({
    required GetSizeSystemsUseCase get,
    required SetSizeSystemActiveUseCase setActive,
    required DeleteSizeSystemUseCase delete,
    required super.flashMessages,
  }) : _get = get,
       _setActive = setActive,
       _delete = delete,
       super(
         initialQuery: const SizeSystemListQuery(
           page: AppConfig.defaultPage,
           pageSize: AppConfig.defaultPageSize,
         ),
       );

  final GetSizeSystemsUseCase _get;
  final SetSizeSystemActiveUseCase _setActive;
  final DeleteSizeSystemUseCase _delete;

  @override
  Future<Either<Failure, PagedResult<SizeSystem>>> fetch(
    SizeSystemListQuery query,
  ) => _get(query);

  @override
  Future<Either<Failure, Unit>> deleteItem(SizeSystem item) => _delete(item.id);

  /// An unknown group count is treated as "in use": the FK is the final judge.
  @override
  Failure? beforeDelete(SizeSystem item) =>
      item.canDelete ? null : const SizeSystemInUseFailure();

  @override
  AppKey get deletedMessageKey => SizeSystemsKeys.deleted;

  @override
  SizeSystemsListEffect buildMutationEffect(PagedMutationKind kind) =>
      SizeSystemsMutatedEffect.fromPaged(kind);

  Future<void> setStatus(SizeStatusFilter value) async {
    final query = state.query.withStatus(value);
    if (query != state.query) await applyQueryAndLoad(query);
  }

  Future<void> setSort(SizeSystemSortField field, bool ascending) async {
    final query = state.query.withSort(field, ascending);
    if (query != state.query) await applyQueryAndLoad(query);
  }

  Future<Either<Failure, Unit>> activate(int id) => _toggle(id, true);

  Future<Either<Failure, Unit>> deactivate(int id) => _toggle(id, false);

  Future<Either<Failure, Unit>> _toggle(int id, bool isActive) => runMutation(
    () => _setActive(SetSizeSystemActiveParams(id: id, isActive: isActive)),
    kind: PagedMutationKind.statusChanged,
    successMessage: SizeSystemsKeys.statusUpdated,
    flashFailure: true,
    rowId: id,
  );

  Future<void> onSaved({required bool isNew}) => reloadAfterMutation(
    isNew ? PagedMutationKind.created : PagedMutationKind.updated,
  );
}
