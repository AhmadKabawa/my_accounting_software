import 'package:dartz/dartz.dart';
import 'package:accounting_software/app/core/error/failures/failure.dart';
import 'package:accounting_software/app/core/foundation/config/app_config.dart';
import 'package:accounting_software/app/core/localization/translations/app_key.dart';
import 'package:accounting_software/app/core/presentation/state_management/paged_list/paged_list_cubit.dart';
import 'package:accounting_software/app/core/presentation/state_management/paged_list/paged_result.dart';
import 'package:accounting_software/app/core/foundation/types/bulk_result.dart';
import 'package:accounting_software/app/features/catalog/sports/domain/entity/sport.dart';
import 'package:accounting_software/app/features/catalog/sports/domain/entity/sport_list_query.dart';
import 'package:accounting_software/app/features/catalog/sports/domain/usecase/get_sports_use_case.dart';
import 'package:accounting_software/app/features/catalog/sports/domain/usecase/delete_sport_use_case.dart';
import 'package:accounting_software/app/features/catalog/sports/domain/usecase/set_sport_active_use_case.dart';
import 'package:accounting_software/app/features/catalog/sports/presentation/cubit/sports_list/sports_list_effect.dart';
import 'package:accounting_software/app/features/catalog/sports/presentation/localization/sports_keys.dart';

class SportsListCubit
    extends PagedListCubit<Sport, SportListQuery, SportsListEffect> {
  SportsListCubit({
    required GetSportsUseCase getSports,
    required SetSportActiveUseCase setSportActive,
    required DeleteSportUseCase deleteSport,
    required super.flashMessages,
  }) : _getSports = getSports,
       _setSportActive = setSportActive,
       _deleteSport = deleteSport,
       super(
         initialQuery: const SportListQuery(
           page: AppConfig.defaultPage,
           pageSize: AppConfig.defaultPageSize,
         ),
       );

  final GetSportsUseCase _getSports;
  final SetSportActiveUseCase _setSportActive;
  final DeleteSportUseCase _deleteSport;

  @override
  Future<Either<Failure, PagedResult<Sport>>> fetch(
    SportListQuery query,
  ) => _getSports(query);

  @override
  Future<Either<Failure, Unit>> deleteItem(Sport item) =>
      _deleteSport(DeleteSportParams(item.id));

  @override
  AppKey get deletedMessageKey => SportsKeys.deleted;

  @override
  SportsListEffect buildMutationEffect(PagedMutationKind kind) =>
      SportsMutatedEffect(switch (kind) {
        PagedMutationKind.created => SportsMutationKind.created,
        PagedMutationKind.updated => SportsMutationKind.updated,
        PagedMutationKind.statusChanged => SportsMutationKind.statusChanged,
        PagedMutationKind.deleted => SportsMutationKind.deleted,
      });

  Future<void> setStatus(SportStatusFilter status) async {
    if (state.query.status == status) return;
    await applyQueryAndLoad(state.query.withStatus(status));
  }

  Future<void> setSorts(List<SportSort> sorts) async {
    final query = state.query.withSorts(sorts);
    if (query == state.query) return;
    await applyQueryAndLoad(query);
  }

  Future<Either<Failure, Unit>> activate(int id) => runMutation(
    () => _setSportActive(SetSportActiveParams(id: id, isActive: true)),
    kind: PagedMutationKind.statusChanged,
    successMessage: SportsKeys.statusUpdated,
    flashFailure: true,
    rowId: id,
  );

  Future<Either<Failure, Unit>> deactivate(int id) => runMutation(
    () => _setSportActive(SetSportActiveParams(id: id, isActive: false)),
    kind: PagedMutationKind.statusChanged,
    successMessage: SportsKeys.statusUpdated,
    flashFailure: true,
    rowId: id,
  );

  Future<BulkResult<Sport>> bulkActivate(
    Iterable<Sport> sports,
  ) => runBulk(
    items: sports,
    action: (sport) =>
        _setSportActive(SetSportActiveParams(id: sport.id, isActive: true)),
    kind: PagedMutationKind.statusChanged,
    successMessage: SportsKeys.statusUpdated,
  );

  Future<BulkResult<Sport>> bulkDeactivate(
    Iterable<Sport> sports,
  ) => runBulk(
    items: sports,
    action: (sport) =>
        _setSportActive(SetSportActiveParams(id: sport.id, isActive: false)),
    kind: PagedMutationKind.statusChanged,
    successMessage: SportsKeys.statusUpdated,
  );

  Future<BulkResult<Sport>> bulkDelete(Iterable<Sport> sports) =>
      runBulk(
        items: sports,
        action: (sport) => _deleteSport(DeleteSportParams(sport.id)),
        kind: PagedMutationKind.deleted,
        successMessage: SportsKeys.deleted,
      );

  Future<void> onSportSaved({required bool isNew}) => reloadAfterMutation(
    isNew ? PagedMutationKind.created : PagedMutationKind.updated,
  );
}
