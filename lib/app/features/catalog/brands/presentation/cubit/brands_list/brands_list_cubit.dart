import 'package:accounting_software/app/core/foundation/config/app_config.dart';
import 'package:accounting_software/app/core/presentation/state_management/paged_list/paged_list_cubit.dart';
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
  fetch(BrandListQuery query) => _getBrands(query);

  @override
  deleteItem(Brand brand) => _deleteBrand(brand.id);

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
      BrandsMutatedEffect.fromPaged(kind);

  Future<void> setStatus(BrandStatusFilter status) =>
      state.query.status == status
          ? Future.value()
          : applyQueryAndLoad(state.query.withStatus(status));

  Future<void> setSort({BrandSortField? field, required bool ascending}) =>
      _sort(state.query.withSort(
        field: field ?? state.query.sortField,
        ascending: ascending,
      ));

  Future<void> setSorts(List<BrandSort> sorts) =>
      sorts.isEmpty ? Future.value() : _sort(state.query.withSorts(sorts));

  Future<void> _sort(BrandListQuery query) =>
      state.query == query ? Future.value() : applyQueryAndLoad(query);

  Future<void> activate(int id) async {
    await runMutation(
      () => _setBrandActive(SetBrandActiveParams(id: id, isActive: true)),
      kind: PagedMutationKind.statusChanged,
      successMessage: BrandsKeys.statusUpdated,
      flashFailure: true,
    );
  }

  deactivate(int id) => runMutation(
    () => _setBrandActive(SetBrandActiveParams(id: id, isActive: false)),
    kind: PagedMutationKind.statusChanged,
    successMessage: BrandsKeys.statusUpdated,
  );

  Future<void> onBrandSaved({required bool isNew}) => reloadAfterMutation(
    isNew ? PagedMutationKind.created : PagedMutationKind.updated,
  );
}
