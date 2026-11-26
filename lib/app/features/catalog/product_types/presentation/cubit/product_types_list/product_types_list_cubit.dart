import 'package:dartz/dartz.dart';
import 'package:accounting_software/app/core/error/failures/failure.dart';
import 'package:accounting_software/app/core/foundation/types/paged_query.dart';
import 'package:accounting_software/app/core/localization/translations/app_key.dart';
import 'package:accounting_software/app/core/presentation/state_management/paged_list/paged_list_cubit.dart';
import 'package:accounting_software/app/core/presentation/state_management/paged_list/paged_result.dart';
import 'package:accounting_software/app/features/catalog/product_types/domain/entity/product_type.dart';
import 'package:accounting_software/app/features/catalog/product_types/domain/entity/product_type_draft.dart';
import 'package:accounting_software/app/features/catalog/product_types/domain/entity/product_type_list_query.dart';
import 'package:accounting_software/app/features/catalog/product_types/domain/failures/product_type_failures.dart';
import 'package:accounting_software/app/features/catalog/product_types/domain/repositories/product_types_repository.dart';
import 'package:accounting_software/app/features/catalog/product_types/presentation/cubit/product_types_list/product_types_list_effect.dart';
import 'package:accounting_software/app/features/catalog/product_types/presentation/localization/product_types_keys.dart';

class ProductTypesListCubit
    extends
        PagedListCubit<
          ProductType,
          ProductTypeListQuery,
          ProductTypesListEffect
        > {
  ProductTypesListCubit({
    required ProductTypesRepository repository,
    required super.flashMessages,
  }) : _repository = repository,
       super(initialQuery: const ProductTypeListQuery());

  final ProductTypesRepository _repository;

  @override
  Future<Either<Failure, PagedResult<ProductType>>> fetch(
    ProductTypeListQuery query,
  ) async {
    final result = await _repository.getPage(query);
    return result.map(
      (page) => PagedResult(
        items: page.items,
        totalCount: page.totalCount,
        currentPage: page.currentPage,
        totalPages: page.totalPages,
      ),
    );
  }

  @override
  Failure? beforeDelete(ProductType item) {
    if (!item.usageKnown) return const ProductTypeUsageUnknownFailure();
    if (item.hasUsage) return const ProductTypeInUseFailure();
    return null;
  }

  @override
  Future<Either<Failure, Unit>> deleteItem(ProductType item) =>
      _repository.delete(item.id);

  @override
  AppKey get deletedMessageKey => ProductTypesKeys.deleted;

  @override
  ProductTypesListEffect buildMutationEffect(PagedMutationKind kind) =>
      ProductTypesMutatedEffect.fromPaged(kind);

  Future<void> setStatus(ProductTypeStatusFilter status) async {
    final query = state.query.withStatus(status);
    if (query != state.query) await applyQueryAndLoad(query);
  }

  Future<Either<Failure, Unit>> activate(int id) => runMutation(
    () => _repository.setActive(id: id, isActive: true),
    kind: PagedMutationKind.statusChanged,
    successMessage: ProductTypesKeys.statusUpdated,
    flashFailure: true,
    rowId: id,
  );

  Future<Either<Failure, Unit>> deactivate(int id) => runMutation(
    () => _repository.setActive(id: id, isActive: false),
    kind: PagedMutationKind.statusChanged,
    successMessage: ProductTypesKeys.statusUpdated,
    flashFailure: true,
    rowId: id,
  );

  Future<void> onProductTypeSaved({required bool isNew}) => reloadAfterMutation(
    isNew ? PagedMutationKind.created : PagedMutationKind.updated,
  );
}
