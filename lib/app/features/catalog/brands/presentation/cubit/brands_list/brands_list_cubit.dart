import 'package:dartz/dartz.dart';
import 'package:accounting_software/app/core/error/failures/failure.dart';
import 'package:accounting_software/app/core/foundation/config/app_config.dart';
import 'package:accounting_software/app/core/presentation/state_management/paged_list/paged_list_cubit.dart';
import 'package:accounting_software/app/core/presentation/state_management/paged_list/paged_result.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_message/flash_messages.dart';
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
    required FlashMessages flashMessages,
  }) : _getBrands = getBrands,
       _setBrandActive = setBrandActive,
       _deleteBrand = deleteBrand,
       super(
         initialQuery: const BrandListQuery(
           page: AppConfig.defaultPage,
           pageSize: AppConfig.defaultPageSize,
         ),
         flashMessages: flashMessages,
       );

  final GetBrandsUseCase _getBrands;
  final SetBrandActiveUseCase _setBrandActive;
  final DeleteBrandUseCase _deleteBrand;

  @override
  Future<Either<Failure, PagedResult<Brand>>> fetch(BrandListQuery query) async =>
      (await _getBrands(query)).map<PagedResult<Brand>>((page) => page);

  @override
  Future<Either<Failure, Unit>> deleteItem(Brand brand) =>
      _deleteBrand(brand.id);

  @override
  beforeDelete(Brand brand) => brand.productCount == null
      ? const BrandUsageUnknownFailure()
      : brand.hasProducts
      ? const BrandInUseFailure()
      : null;

  @override
  get deletedMessageKey => BrandsKeys.deleted;

  @override
  BrandsListEffect buildMutationEffect(PagedMutationKind kind) =>
      BrandsMutatedEffect(switch (kind) {
        PagedMutationKind.created => BrandsMutationKind.created,
        PagedMutationKind.updated => BrandsMutationKind.updated,
        PagedMutationKind.statusChanged => BrandsMutationKind.statusChanged,
        PagedMutationKind.deleted => BrandsMutationKind.deleted,
      });

  Future<void> _loadQuery(BrandListQuery query) {
    applyQuery(query);
    return load();
  }

  Future<void> setStatus(BrandStatusFilter status) =>
      state.query.status == status
          ? Future.value()
          : _loadQuery(state.query.withStatus(status));

  Future<void> setSort({BrandSortField? field, required bool ascending}) {
    final sorts = [BrandSort(field ?? state.query.sortField, ascending)];
    return state.query.hasSameSorts(sorts)
        ? Future.value()
        : _loadQuery(state.query.withSort(
            field: sorts.first.field,
            ascending: ascending,
          ));
  }

  Future<void> setSorts(List<BrandSort> sorts) =>
      sorts.isEmpty || state.query.hasSameSorts(sorts)
          ? Future.value()
          : _loadQuery(state.query.withSorts(sorts));

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

  Future<void> onBrandSaved({required bool isNew}) => reloadAfterMutation(
    isNew ? PagedMutationKind.created : PagedMutationKind.updated,
  );
}
