import 'package:dartz/dartz.dart';
import 'package:accounting_software/app/core/error/failures/failure.dart';
import 'package:accounting_software/app/core/foundation/config/app_config.dart';
import 'package:accounting_software/app/core/localization/translations/app_key.dart';
import 'package:accounting_software/app/core/presentation/state_management/paged_list/paged_list_cubit.dart';
import 'package:accounting_software/app/core/presentation/state_management/paged_list/paged_result.dart';
import 'package:accounting_software/app/features/catalog/size_systems/presentation/localization/size_systems_keys.dart';
import 'package:accounting_software/app/features/catalog/size_systems/shared/domain/failures/size_system_failures.dart';
import 'package:accounting_software/app/features/catalog/size_systems/shared/domain/size_status_filter.dart';
import 'package:accounting_software/app/features/catalog/size_systems/sizes/domain/entity/catalog_size.dart';
import 'package:accounting_software/app/features/catalog/size_systems/sizes/domain/entity/catalog_size_list_query.dart';
import 'package:accounting_software/app/features/catalog/size_systems/sizes/domain/usecase/sizes_use_cases.dart';
import 'package:accounting_software/app/features/catalog/size_systems/sizes/presentation/cubit/sizes_list/sizes_list_effect.dart';

class SizesListCubit
    extends PagedListCubit<CatalogSize, CatalogSizeListQuery, SizesListEffect> {
  SizesListCubit({
    required int sizeGroupId,
    required GetSizesUseCase get,
    required SetSizeActiveUseCase setActive,
    required DeleteSizeUseCase delete,
    required super.flashMessages,
  }) : _get = get,
       _setActive = setActive,
       _delete = delete,
       super(
         initialQuery: CatalogSizeListQuery(
           sizeGroupId: sizeGroupId,
           page: AppConfig.defaultPage,
           pageSize: AppConfig.defaultPageSize,
         ),
       );

  final GetSizesUseCase _get;
  final SetSizeActiveUseCase _setActive;
  final DeleteSizeUseCase _delete;

  @override
  Future<Either<Failure, PagedResult<CatalogSize>>> fetch(
    CatalogSizeListQuery query,
  ) => _get(query);

  @override
  Future<Either<Failure, Unit>> deleteItem(CatalogSize item) =>
      _delete(item.id);

  /// An unknown usage count is treated as "in use" (CAT07-SZ-AC5).
  @override
  Failure? beforeDelete(CatalogSize item) =>
      item.canDelete ? null : const SizeInUseFailure();

  @override
  AppKey get deletedMessageKey => SizeSystemsKeys.deleted;

  @override
  SizesListEffect buildMutationEffect(PagedMutationKind kind) =>
      SizesMutatedEffect.fromPaged(kind);

  Future<void> setStatus(SizeStatusFilter value) async {
    final query = state.query.withStatus(value);
    if (query != state.query) await applyQueryAndLoad(query);
  }

  Future<void> setSort(CatalogSizeSortField field, bool ascending) async {
    final query = state.query.withSort(field, ascending);
    if (query != state.query) await applyQueryAndLoad(query);
  }

  Future<Either<Failure, Unit>> activate(int id) => _toggle(id, true);

  Future<Either<Failure, Unit>> deactivate(int id) => _toggle(id, false);

  Future<Either<Failure, Unit>> _toggle(int id, bool isActive) => runMutation(
    () => _setActive(SetSizeActiveParams(id: id, isActive: isActive)),
    kind: PagedMutationKind.statusChanged,
    successMessage: SizeSystemsKeys.statusUpdated,
    flashFailure: true,
    rowId: id,
  );

  Future<void> onSaved({required bool isNew}) => reloadAfterMutation(
    isNew ? PagedMutationKind.created : PagedMutationKind.updated,
  );

  /// Reload after the range generator created sizes.
  Future<void> onGenerated() => reloadAfterMutation(PagedMutationKind.created);
}
