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
  Future<Either<Failure, PagedResult<Brand>>> fetch(BrandListQuery query) async {
    final result = await _getBrands(query);
    return result.map<PagedResult<Brand>>((page) => page);
  }

  @override
  Future<Either<Failure, Unit>> deleteItem(Brand brand) =>
      _deleteBrand(brand.id);

  @override
  Failure? beforeDelete(Brand brand) {
    if (brand.productCount == null) return const BrandUsageUnknownFailure();
    if (brand.hasProducts) return const BrandInUseFailure();
    return null;
  }

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

  /// A column-header click replaces any existing multi-sort.
  Future<void> setSort({BrandSortField? field, required bool ascending}) {
    final query = state.query;
    final next = field ?? query.sortField;
    if (query.sortField == next &&
        query.sortAscending == ascending &&
        query.thenSorts.isEmpty) {
      return Future.value();
    }
    applyQuery(query.copyWith(
      sortField: next,
      sortAscending: ascending,
      thenSorts: const [],
      page: 1,
    ));
    return load();
  }

  /// The sort menu supports a primary and one secondary database criterion.
  Future<void> setSorts(List<BrandSort> sorts) {
    if (sorts.isEmpty) return Future.value();
    final primary = sorts.first;
    final secondary = sorts.skip(1).take(1).toList();
    if (primary.field == state.query.sortField &&
        primary.ascending == state.query.sortAscending &&
        _sameSorts(secondary, state.query.thenSorts)) {
      return Future.value();
    }
    applyQuery(state.query.copyWith(
      sortField: primary.field,
      sortAscending: primary.ascending,
      thenSorts: secondary,
      page: 1,
    ));
    return load();
  }

  bool _sameSorts(List<BrandSort> a, List<BrandSort> b) =>
      a.length == b.length &&
      [for (var i = 0; i < a.length; i++) a[i] == b[i]].every((same) => same);

  Future<void> activate(int id) async {
    final result = await _setBrandActive(
      SetBrandActiveParams(id: id, isActive: true),
    );
    if (isClosed) return;
    if (result.isLeft()) {
      final failure = result.fold<Failure?>((value) => value, (_) => null);
      if (failure != null) {
        // Activation failures are flashed; deactivation failures go to the dialog.
        _postFailure(failure);
      }
      return;
    }
    _postStatusUpdated();
    publishMutation(PagedMutationKind.statusChanged);
    await load();
  }

  Future<Either<Failure, Unit>> deactivate(int id) async {
    final result = await _setBrandActive(
      SetBrandActiveParams(id: id, isActive: false),
    );
    if (isClosed) return result;
    if (result.isRight()) {
      _postStatusUpdated();
      publishMutation(PagedMutationKind.statusChanged);
      await load();
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

  void _postFailure(Failure failure) =>
      _flashMessages.post(failure.messageKey, MessageType.error);

  void _postStatusUpdated() =>
      _flashMessages.post(BrandsKeys.statusUpdated, MessageType.success);
}
