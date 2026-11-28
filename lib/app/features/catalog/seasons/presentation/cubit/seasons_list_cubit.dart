import 'package:dartz/dartz.dart';
import 'package:accounting_software/app/core/foundation/types/bulk_result.dart';
import 'package:accounting_software/app/core/error/failures/failure.dart';
import 'package:accounting_software/app/core/foundation/config/app_config.dart';
import 'package:accounting_software/app/core/localization/translations/app_key.dart';
import 'package:accounting_software/app/core/presentation/state_management/paged_list/paged_list_cubit.dart';
import 'package:accounting_software/app/core/presentation/state_management/paged_list/paged_result.dart';
import 'package:accounting_software/app/features/catalog/seasons/domain/entity/season.dart';
import 'package:accounting_software/app/features/catalog/seasons/domain/entity/season_list_query.dart';
import 'package:accounting_software/app/features/catalog/seasons/domain/usecase/get_seasons_use_case.dart';
import 'package:accounting_software/app/features/catalog/seasons/domain/usecase/set_season_active_use_case.dart';
import 'package:accounting_software/app/features/catalog/seasons/domain/usecase/delete_season_use_case.dart';
import 'package:accounting_software/app/features/catalog/seasons/presentation/localization/seasons_keys.dart';
import 'package:accounting_software/app/features/catalog/seasons/presentation/cubit/seasons_list_effect.dart';

class SeasonsListCubit
    extends PagedListCubit<CatalogSeason, SeasonListQuery, SeasonsListEffect> {
  SeasonsListCubit({
    required GetSeasonsUseCase getItems,
    required SetSeasonActiveUseCase setActive,
    required DeleteSeasonUseCase deleteItem,
    required super.flashMessages,
  }) : _get = getItems,
       _set = setActive,
       _delete = deleteItem,
       super(
         initialQuery: const SeasonListQuery(
           page: AppConfig.defaultPage,
           pageSize: AppConfig.defaultPageSize,
         ),
       );
  final GetSeasonsUseCase _get;
  final SetSeasonActiveUseCase _set;
  final DeleteSeasonUseCase _delete;
  @override
  Future<Either<Failure, PagedResult<CatalogSeason>>> fetch(
    SeasonListQuery query,
  ) => _get(query);
  @override
  Future<Either<Failure, Unit>> deleteItem(CatalogSeason item) =>
      _delete(DeleteSeasonParams(item.id));
  @override
  AppKey get deletedMessageKey => SeasonsKeys.deleted;
  @override
  SeasonsListEffect buildMutationEffect(PagedMutationKind kind) =>
      SeasonsMutatedEffect(switch (kind) {
        PagedMutationKind.created => SeasonsMutationKind.created,
        PagedMutationKind.updated => SeasonsMutationKind.updated,
        PagedMutationKind.statusChanged => SeasonsMutationKind.statusChanged,
        PagedMutationKind.deleted => SeasonsMutationKind.deleted,
      });
  Future<void> setStatus(SeasonStatusFilter value) =>
      applyQueryAndLoad(state.query.copyWith(status: value, page: 1));
  Future<void> setSort(SeasonSortField field, bool ascending) =>
      setSorts([SeasonSort(field, ascending)]);
  Future<void> setSorts(List<SeasonSort> sorts) =>
      applyQueryAndLoad(state.query.withSorts(sorts));
  Future<Either<Failure, Unit>> activate(int id) => runMutation(
    () => _set(SetSeasonActiveParams(id: id, isActive: true)),
    kind: PagedMutationKind.statusChanged,
    successMessage: SeasonsKeys.statusUpdated,
    flashFailure: true,
    rowId: id,
  );
  Future<Either<Failure, Unit>> deactivate(int id) => runMutation(
    () => _set(SetSeasonActiveParams(id: id, isActive: false)),
    kind: PagedMutationKind.statusChanged,
    successMessage: SeasonsKeys.statusUpdated,
    flashFailure: true,
    rowId: id,
  );
  Future<BulkResult<CatalogSeason>> bulkActivate(
    Iterable<CatalogSeason> items,
  ) => runBulk(
    items: items,
    action: (item) => _set(SetSeasonActiveParams(id: item.id, isActive: true)),
    kind: PagedMutationKind.statusChanged,
    successMessage: SeasonsKeys.statusUpdated,
  );
  Future<BulkResult<CatalogSeason>> bulkDeactivate(
    Iterable<CatalogSeason> items,
  ) => runBulk(
    items: items,
    action: (item) => _set(SetSeasonActiveParams(id: item.id, isActive: false)),
    kind: PagedMutationKind.statusChanged,
    successMessage: SeasonsKeys.statusUpdated,
  );
  Future<BulkResult<CatalogSeason>> bulkDelete(Iterable<CatalogSeason> items) =>
      runBulk(
        items: items,
        action: (item) => _delete(DeleteSeasonParams(item.id)),
        kind: PagedMutationKind.deleted,
        successMessage: SeasonsKeys.deleted,
      );
  Future<void> onSaved({required bool isNew}) => reloadAfterMutation(
    isNew ? PagedMutationKind.created : PagedMutationKind.updated,
  );
  Future<void> setType(String? value) => applyQueryAndLoad(
    state.query.copyWith(type: value, clearType: value == null, page: 1),
  );
}
