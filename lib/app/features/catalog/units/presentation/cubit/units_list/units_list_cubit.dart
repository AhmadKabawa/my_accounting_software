import 'package:dartz/dartz.dart';
import 'package:accounting_software/app/core/error/failures/failure.dart';
import 'package:accounting_software/app/core/foundation/config/app_config.dart';
import 'package:accounting_software/app/core/foundation/types/bulk_result.dart';
import 'package:accounting_software/app/core/localization/translations/app_key.dart';
import 'package:accounting_software/app/core/presentation/state_management/paged_list/paged_list_cubit.dart';
import 'package:accounting_software/app/core/presentation/state_management/paged_list/paged_result.dart';
import 'package:accounting_software/app/features/catalog/units/domain/entity/catalog_unit.dart';
import 'package:accounting_software/app/features/catalog/units/domain/entity/unit_list_query.dart';
import 'package:accounting_software/app/features/catalog/units/domain/usecase/delete_unit_use_case.dart';
import 'package:accounting_software/app/features/catalog/units/domain/usecase/get_units_use_case.dart';
import 'package:accounting_software/app/features/catalog/units/domain/usecase/set_unit_active_use_case.dart';
import 'package:accounting_software/app/features/catalog/units/presentation/cubit/units_list/units_list_effect.dart';
import 'package:accounting_software/app/features/catalog/units/presentation/localization/units_keys.dart';

class UnitsListCubit
    extends PagedListCubit<CatalogUnit, UnitListQuery, UnitsListEffect> {
  UnitsListCubit({
    required GetUnitsUseCase getUnits,
    required SetUnitActiveUseCase setUnitActive,
    required DeleteUnitUseCase deleteUnit,
    required super.flashMessages,
  }) : _getUnits = getUnits,
       _setUnitActive = setUnitActive,
       _deleteUnit = deleteUnit,
       super(
         initialQuery: const UnitListQuery(
           page: AppConfig.defaultPage,
           pageSize: AppConfig.defaultPageSize,
         ),
       );

  final GetUnitsUseCase _getUnits;
  final SetUnitActiveUseCase _setUnitActive;
  final DeleteUnitUseCase _deleteUnit;

  @override
  Future<Either<Failure, PagedResult<CatalogUnit>>> fetch(
    UnitListQuery query,
  ) => _getUnits(query);

  @override
  Future<Either<Failure, Unit>> deleteItem(CatalogUnit item) =>
      _deleteUnit(item.id);

  @override
  Failure? beforeDelete(CatalogUnit item) {
    final usageCount = item.usageCount;
    if (usageCount == null) {
      return const ValidationFailure(messageKey: UnitsKeys.unknownUsage);
    }
    if (usageCount > 0) {
      return const ValidationFailure(messageKey: UnitsKeys.inUse);
    }
    return null;
  }

  @override
  AppKey get deletedMessageKey => UnitsKeys.deleted;

  @override
  UnitsListEffect buildMutationEffect(PagedMutationKind kind) =>
      UnitsMutatedEffect.fromPaged(kind);

  Future<void> setSort(bool ascending) =>
      _loadIfChanged(state.query.withSort(ascending));

  Future<void> setStatus(UnitStatusFilter status) =>
      _loadIfChanged(state.query.copyWith(status: status, page: 1));

  Future<void> setType(UnitType? type) => _loadIfChanged(
    state.query.copyWith(type: type, clearType: type == null, page: 1),
  );

  Future<void> _loadIfChanged(UnitListQuery query) async {
    if (state.query == query) return;
    await applyQueryAndLoad(query);
  }

  Future<Either<Failure, Unit>> activate(int id) => runMutation(
    () => _setUnitActive(SetUnitActiveParams(id: id, isActive: true)),
    kind: PagedMutationKind.statusChanged,
    successMessage: UnitsKeys.statusUpdated,
    flashFailure: true,
    rowId: id,
  );

  Future<Either<Failure, Unit>> deactivate(int id) => runMutation(
    () => _setUnitActive(SetUnitActiveParams(id: id, isActive: false)),
    kind: PagedMutationKind.statusChanged,
    successMessage: UnitsKeys.statusUpdated,
    flashFailure: true,
    rowId: id,
  );

  Future<BulkResult<CatalogUnit>> bulkActivate(Iterable<CatalogUnit> items) =>
      runBulk(
        items: items,
        action: (item) =>
            _setUnitActive(SetUnitActiveParams(id: item.id, isActive: true)),
        kind: PagedMutationKind.statusChanged,
        successMessage: UnitsKeys.statusUpdated,
      );

  Future<BulkResult<CatalogUnit>> bulkDeactivate(Iterable<CatalogUnit> items) =>
      runBulk(
        items: items,
        action: (item) =>
            _setUnitActive(SetUnitActiveParams(id: item.id, isActive: false)),
        kind: PagedMutationKind.statusChanged,
        successMessage: UnitsKeys.statusUpdated,
      );

  Future<BulkResult<CatalogUnit>> bulkDelete(Iterable<CatalogUnit> items) =>
      runBulk(
        items: items,
        action: (item) {
          final rejection = beforeDelete(item);
          return rejection == null
              ? _deleteUnit(item.id)
              : Future.value(Left<Failure, Unit>(rejection));
        },
        kind: PagedMutationKind.deleted,
        successMessage: UnitsKeys.deleted,
      );

  Future<void> onUnitSaved({required bool isNew}) => reloadAfterMutation(
    isNew ? PagedMutationKind.created : PagedMutationKind.updated,
  );
}
