import 'package:dartz/dartz.dart';
import 'package:accounting_software/app/core/foundation/types/bulk_result.dart';
import 'package:accounting_software/app/core/error/failures/failure.dart';
import 'package:accounting_software/app/core/foundation/config/app_config.dart';
import 'package:accounting_software/app/core/localization/translations/app_key.dart';
import 'package:accounting_software/app/core/presentation/state_management/paged_list/paged_list_cubit.dart';
import 'package:accounting_software/app/core/presentation/state_management/paged_list/paged_result.dart';
import 'package:accounting_software/app/features/catalog/collections/domain/entity/collection.dart';
import 'package:accounting_software/app/features/catalog/collections/domain/entity/collection_list_query.dart';
import 'package:accounting_software/app/features/catalog/collections/domain/usecase/get_collections_use_case.dart';
import 'package:accounting_software/app/features/catalog/collections/domain/usecase/set_collection_active_use_case.dart';
import 'package:accounting_software/app/features/catalog/collections/domain/usecase/delete_collection_use_case.dart';
import 'package:accounting_software/app/features/catalog/collections/presentation/localization/collections_keys.dart';
import 'package:accounting_software/app/features/catalog/collections/presentation/cubit/collections_list_effect.dart';

class CollectionsListCubit
    extends
        PagedListCubit<
          CatalogCollection,
          CollectionListQuery,
          CollectionsListEffect
        > {
  CollectionsListCubit({
    required GetCollectionsUseCase getItems,
    required SetCollectionActiveUseCase setActive,
    required DeleteCollectionUseCase deleteItem,
    required super.flashMessages,
  }) : _get = getItems,
       _set = setActive,
       _delete = deleteItem,
       super(
         initialQuery: const CollectionListQuery(
           page: AppConfig.defaultPage,
           pageSize: AppConfig.defaultPageSize,
         ),
       );
  final GetCollectionsUseCase _get;
  final SetCollectionActiveUseCase _set;
  final DeleteCollectionUseCase _delete;
  @override
  Future<Either<Failure, PagedResult<CatalogCollection>>> fetch(
    CollectionListQuery query,
  ) => _get(query);
  @override
  Future<Either<Failure, Unit>> deleteItem(CatalogCollection item) =>
      _delete(DeleteCollectionParams(item.id));
  @override
  AppKey get deletedMessageKey => CollectionsKeys.deleted;
  @override
  CollectionsListEffect buildMutationEffect(PagedMutationKind kind) =>
      CollectionsMutatedEffect(switch (kind) {
        PagedMutationKind.created => CollectionsMutationKind.created,
        PagedMutationKind.updated => CollectionsMutationKind.updated,
        PagedMutationKind.statusChanged =>
          CollectionsMutationKind.statusChanged,
        PagedMutationKind.deleted => CollectionsMutationKind.deleted,
      });
  Future<void> setStatus(CollectionStatusFilter value) =>
      applyQueryAndLoad(state.query.copyWith(status: value, page: 1));
  Future<void> setSort(CollectionSortField field, bool ascending) =>
      setSorts([CollectionSort(field, ascending)]);
  Future<void> setSorts(List<CollectionSort> sorts) =>
      applyQueryAndLoad(state.query.withSorts(sorts));
  Future<Either<Failure, Unit>> activate(int id) => runMutation(
    () => _set(SetCollectionActiveParams(id: id, isActive: true)),
    kind: PagedMutationKind.statusChanged,
    successMessage: CollectionsKeys.statusUpdated,
    flashFailure: true,
    rowId: id,
  );
  Future<Either<Failure, Unit>> deactivate(int id) => runMutation(
    () => _set(SetCollectionActiveParams(id: id, isActive: false)),
    kind: PagedMutationKind.statusChanged,
    successMessage: CollectionsKeys.statusUpdated,
    flashFailure: true,
    rowId: id,
  );
  Future<BulkResult<CatalogCollection>> bulkActivate(
    Iterable<CatalogCollection> items,
  ) => runBulk(
    items: items,
    action: (item) =>
        _set(SetCollectionActiveParams(id: item.id, isActive: true)),
    kind: PagedMutationKind.statusChanged,
    successMessage: CollectionsKeys.statusUpdated,
  );
  Future<BulkResult<CatalogCollection>> bulkDeactivate(
    Iterable<CatalogCollection> items,
  ) => runBulk(
    items: items,
    action: (item) =>
        _set(SetCollectionActiveParams(id: item.id, isActive: false)),
    kind: PagedMutationKind.statusChanged,
    successMessage: CollectionsKeys.statusUpdated,
  );
  Future<BulkResult<CatalogCollection>> bulkDelete(
    Iterable<CatalogCollection> items,
  ) => runBulk(
    items: items,
    action: (item) => _delete(DeleteCollectionParams(item.id)),
    kind: PagedMutationKind.deleted,
    successMessage: CollectionsKeys.deleted,
  );
  Future<void> onSaved({required bool isNew}) => reloadAfterMutation(
    isNew ? PagedMutationKind.created : PagedMutationKind.updated,
  );
}
