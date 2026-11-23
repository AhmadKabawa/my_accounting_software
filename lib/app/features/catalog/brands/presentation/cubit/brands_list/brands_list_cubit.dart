import 'package:dartz/dartz.dart';
import 'package:accounting_software/app/core/error/failures/failure.dart';
import 'package:accounting_software/app/core/foundation/config/app_config.dart';
import 'package:accounting_software/app/core/localization/translations/app_key.dart';
import 'package:accounting_software/app/core/presentation/state_management/paged_list/paged_list_cubit.dart';
import 'package:accounting_software/app/core/presentation/state_management/paged_list/paged_result.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_message/flash_messages.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_message/message_view_widgets.dart';
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
       _flashMessages = flashMessages,
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
  final FlashMessages _flashMessages;

  @override
  Future<Either<Failure, PagedResult<Brand>>> fetch(BrandListQuery query) async =>
      (await _getBrands(query)).map<PagedResult<Brand>>((page) => page);

  @override
  Future<Either<Failure, Unit>> deleteItem(Brand brand) =>
      _deleteBrand(brand.id);

  @override
  Failure? beforeDelete(Brand brand) => brand.productCount == null
      ? const BrandUsageUnknownFailure()
      : brand.hasProducts
      ? const BrandInUseFailure()
      : null;

  @override
  AppKey get deletedMessageKey => BrandsKeys.deleted;

  @override
  BrandsListEffect buildMutationEffect(PagedMutationKind kind) =>
      BrandsMutatedEffect(switch (kind) {
        PagedMutationKind.created => BrandsMutationKind.created,
        PagedMutationKind.updated => BrandsMutationKind.updated,
        PagedMutationKind.statusChanged => BrandsMutationKind.statusChanged,
        PagedMutationKind.deleted => BrandsMutationKind.deleted,
      });

  Future<void> setStatus(BrandStatusFilter status) {
    if (state.query.status == status) return Future.value();
    applyQuery(state.query.copyWith(status: status, page: 1));
    return load();
  }

  Future<void> setSort({BrandSortField? field, required bool ascending}) {
    final query = state.query.withSort(
      field: field ?? state.query.sortField,
      ascending: ascending,
    );
    if (query.sortField == state.query.sortField &&
        query.sortAscending == state.query.sortAscending &&
        state.query.thenSorts.isEmpty) {
      return Future.value();
    }
    applyQuery(query);
    return load();
  }

  Future<void> setSorts(List<BrandSort> sorts) {
    if (sorts.isEmpty || state.query.hasSameSorts(sorts)) {
      return Future.value();
    }
    applyQuery(state.query.withSorts(sorts));
    return load();
  }

  Future<void> activate(int id) async {
    await _changeStatus(id, true, flashFailure: true);
  }

  Future<Either<Failure, Unit>> deactivate(int id) =>
      _changeStatus(id, false);

  Future<Either<Failure, Unit>> _changeStatus(
    int id,
    bool active, {
    bool flashFailure = false,
  }) async {
    final result = await _setBrandActive(
      SetBrandActiveParams(id: id, isActive: active),
    );
    if (isClosed) return result;
    if (result.isRight()) {
      _flashMessages.post(BrandsKeys.statusUpdated, MessageType.success);
      publishMutation(PagedMutationKind.statusChanged);
      await load();
    } else if (flashFailure) {
      result.fold(
        (failure) => _flashMessages.post(failure.messageKey, MessageType.error),
        (_) {},
      );
    }
    return result;
  }

  Future<void> onBrandSaved({required bool isNew}) async {
    if (isClosed) return;
    publishMutation(
      isNew ? PagedMutationKind.created : PagedMutationKind.updated,
    );
    await load();
  }
}
