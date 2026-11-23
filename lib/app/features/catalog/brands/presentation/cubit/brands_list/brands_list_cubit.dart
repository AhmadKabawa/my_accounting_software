import 'package:dartz/dartz.dart';
import 'package:accounting_software/app/core/error/failures/failure.dart';
import 'package:accounting_software/app/core/foundation/config/app_config.dart';
import 'package:accounting_software/app/core/localization/translations/app_key.dart';
import 'package:accounting_software/app/core/presentation/state_management/paged_list/paged_result.dart';
import 'package:accounting_software/app/core/presentation/state_management/paged_list/paged_list_cubit.dart';
import 'package:accounting_software/app/core/foundation/types/bulk_result.dart';
import 'package:accounting_software/app/features/catalog/brands/domain/entity/brand.dart';
import 'package:accounting_software/app/features/catalog/brands/domain/entity/brand_list_query.dart';
import 'package:accounting_software/app/features/catalog/brands/domain/failures/brand_failures.dart';
import 'package:accounting_software/app/features/catalog/brands/domain/usecase/delete_brand_use_case.dart';
import 'package:accounting_software/app/features/catalog/brands/domain/usecase/get_brands_use_case.dart';
import 'package:accounting_software/app/features/catalog/brands/domain/usecase/set_brand_active_use_case.dart';
import 'package:accounting_software/app/features/catalog/brands/presentation/cubit/brands_list/brands_list_effect.dart';
import 'package:accounting_software/app/features/catalog/brands/presentation/localization/brands_keys.dart';

class BrandsListCubit
    extends PagedListCubit<Brand, BrandListQuery, BrandsListEffect> {
  BrandsListCubit({
    required GetBrandsUseCase getBrands,
    required SetBrandActiveUseCase setBrandActive,
    required DeleteBrandUseCase deleteBrand,
    required super.flashMessages,
  }) : _getBrands = getBrands,
       _setBrandActive = setBrandActive,
       _deleteBrand = deleteBrand,
       super(
         initialQuery: const BrandListQuery(
           page: AppConfig.defaultPage,
           pageSize: AppConfig.defaultPageSize,
         ),
       );

  final GetBrandsUseCase _getBrands;
  final SetBrandActiveUseCase _setBrandActive;
  final DeleteBrandUseCase _deleteBrand;

  @override
  Future<Either<Failure, PagedResult<Brand>>> fetch(BrandListQuery query) =>
      _getBrands(query);

  @override
  Future<Either<Failure, Unit>> deleteItem(Brand item) =>
      _deleteBrand(item.id);

  @override
  Failure? beforeDelete(Brand item) => item.productCount == null
      ? const BrandUsageUnknownFailure()
      : item.hasProducts
      ? const BrandInUseFailure()
      : null;

  @override
  AppKey get deletedMessageKey => BrandsKeys.deleted;

  @override
  BrandsListEffect buildMutationEffect(PagedMutationKind kind) =>
      BrandsMutatedEffect.fromPaged(kind);

  Future<void> _loadIfChanged(BrandListQuery query) =>
      state.query == query ? Future.value() : applyQueryAndLoad(query);

  Future<void> setStatus(BrandStatusFilter status) =>
      _loadIfChanged(state.query.withStatus(status));

  Future<void> setSort({BrandSortField? field, required bool ascending}) =>
      _loadIfChanged(
        state.query.withSort(
          field: field ?? state.query.sortField,
          ascending: ascending,
        ),
      );

  Future<void> setSorts(List<BrandSort> sorts) =>
      _loadIfChanged(state.query.withSorts(sorts));

  Future<void> activate(int id) async {
    await runMutation(
      () => _setBrandActive(SetBrandActiveParams(id: id, isActive: true)),
      kind: PagedMutationKind.statusChanged,
      successMessage: BrandsKeys.statusUpdated,
      flashFailure: true,
    );
  }

  Future<Either<Failure, Unit>> deactivate(int id) => runMutation(
    () => _setBrandActive(SetBrandActiveParams(id: id, isActive: false)),
    kind: PagedMutationKind.statusChanged,
    successMessage: BrandsKeys.statusUpdated,
  );

  Future<BulkResult<Brand>> bulkActivate(Iterable<Brand> brands) => runBulk(
    items: brands,
    action: (brand) =>
        _setBrandActive(SetBrandActiveParams(id: brand.id, isActive: true)),
    kind: PagedMutationKind.statusChanged,
    successMessage: BrandsKeys.statusUpdated,
  );

  Future<BulkResult<Brand>> bulkDeactivate(Iterable<Brand> brands) => runBulk(
    items: brands,
    action: (brand) =>
        _setBrandActive(SetBrandActiveParams(id: brand.id, isActive: false)),
    kind: PagedMutationKind.statusChanged,
    successMessage: BrandsKeys.statusUpdated,
  );

  Future<BulkResult<Brand>> bulkDelete(Iterable<Brand> brands) => runBulk(
    items: brands,
    action: (brand) {
      final rejection = beforeDelete(brand);
      return rejection == null
          ? _deleteBrand(brand.id)
          : Future.value(Left<Failure, Unit>(rejection));
    },
    kind: PagedMutationKind.deleted,
    successMessage: BrandsKeys.deleted,
  );

  Future<void> onBrandSaved({required bool isNew}) => reloadAfterMutation(
    isNew ? PagedMutationKind.created : PagedMutationKind.updated,
  );
}
