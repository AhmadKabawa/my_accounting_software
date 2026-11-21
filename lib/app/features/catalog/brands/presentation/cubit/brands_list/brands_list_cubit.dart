import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:accounting_software/app/core/error/failures/failure.dart';
import 'package:accounting_software/app/core/presentation/state_management/base_cubit.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_message/flash_messages.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_message/message_view_widgets.dart';
import 'package:accounting_software/app/features/catalog/brands/domain/entity/brand.dart';
import 'package:accounting_software/app/features/catalog/brands/domain/entity/brand_list_query.dart';
import 'package:accounting_software/app/features/catalog/brands/domain/failures/brand_failures.dart';
import 'package:accounting_software/app/features/catalog/brands/domain/usecase/delete_brand_use_case.dart';
import 'package:accounting_software/app/features/catalog/brands/domain/usecase/get_brands_use_case.dart';
import 'package:accounting_software/app/features/catalog/brands/domain/usecase/set_brand_active_use_case.dart';
import 'package:accounting_software/app/features/catalog/brands/presentation/cubit/brands_list/brands_list_effect.dart';
import 'package:accounting_software/app/features/catalog/brands/presentation/cubit/brands_list/brands_list_state.dart';
import 'package:accounting_software/app/features/catalog/brands/presentation/localization/brands_keys.dart';

class BrandsListCubit extends BaseCubit<BrandsListState, BrandsListEffect> {
  BrandsListCubit({
    required GetBrandsUseCase getBrands,
    required SetBrandActiveUseCase setBrandActive,
    required DeleteBrandUseCase deleteBrand,
    required FlashMessages flashMessages,
  }) : _getBrands = getBrands,
       _setBrandActive = setBrandActive,
       _deleteBrand = deleteBrand,
       _flashMessages = flashMessages,
       super(const BrandsListState());

  final GetBrandsUseCase _getBrands;
  final SetBrandActiveUseCase _setBrandActive;
  final DeleteBrandUseCase _deleteBrand;
  final FlashMessages _flashMessages;

  Timer? _searchTimer;
  int _requestVersion = 0;

  Future<void> load() async {
    _searchTimer?.cancel();
    final version = ++_requestVersion;
    final previous = state.result;
    emit(
      state.copyWith(
        status: previous == null
            ? BrandsListStatus.loading
            : BrandsListStatus.refreshing,
        clearFailure: true,
      ),
    );

    final response = await _getBrands(state.query);
    if (isClosed || version != _requestVersion) return;

    response.fold(
      (failure) => emit(
        state.copyWith(
          status: BrandsListStatus.failed,
          result: previous,
          failure: failure,
        ),
      ),
      (page) => emit(
        state.copyWith(
          status: BrandsListStatus.ready,
          result: page,
          clearFailure: true,
        ),
      ),
    );
  }

  void searchChanged(String value) {
    final query = state.query.copyWith(search: value, page: 1);
    _requestVersion++;
    _searchTimer?.cancel();
    emit(state.copyWith(query: query, clearFailure: true));
    _searchTimer = Timer(const Duration(milliseconds: 300), () {
      if (!isClosed) load();
    });
  }

  Future<void> setStatus(BrandStatusFilter status) {
    if (state.query.status == status) return Future.value();
    _updateQuery(state.query.copyWith(status: status, page: 1));
    return load();
  }

  Future<void> setSort({required bool ascending}) {
    if (state.query.sortAscending == ascending) return Future.value();
    _updateQuery(state.query.copyWith(sortAscending: ascending, page: 1));
    return load();
  }

  Future<void> setPage(int page) {
    if (page < 1 || page == state.query.page) return Future.value();
    _updateQuery(state.query.copyWith(page: page));
    return load();
  }

  Future<void> clearFilters() {
    _searchTimer?.cancel();
    _searchTimer = null;
    _updateQuery(
      state.query.copyWith(search: '', status: BrandStatusFilter.all, page: 1),
    );
    return load();
  }

  Future<void> refresh() => load();

  Future<void> activate(int id) async {
    final result = await _setBrandActive(
      SetBrandActiveParams(id: id, isActive: true),
    );
    if (isClosed) return;
    if (result.isLeft()) {
      final failure = result.fold<Failure?>((failure) => failure, (_) => null);
      if (failure != null) {
        _flashMessages.post(failure.messageKey, MessageType.error);
      }
      return;
    }
    _flashMessages.post(BrandsKeys.statusUpdated, MessageType.success);
    emitEffect(const BrandsMutatedEffect(BrandsMutationKind.statusChanged));
    await load();
  }

  Future<Either<Failure, Unit>> deactivate(int id) async {
    final result = await _setBrandActive(
      SetBrandActiveParams(id: id, isActive: false),
    );
    if (isClosed) return result;
    if (result.isRight()) {
      _flashMessages.post(BrandsKeys.statusUpdated, MessageType.success);
      emitEffect(const BrandsMutatedEffect(BrandsMutationKind.statusChanged));
      await load();
    }
    return result;
  }

  Future<Either<Failure, Unit>> delete(Brand brand) async {
    if (brand.productCount == null) {
      return const Left(BrandUsageUnknownFailure());
    }
    if (brand.hasProducts) {
      return const Left(BrandInUseFailure());
    }

    final result = await _deleteBrand(brand.id);
    if (isClosed) return result;
    if (result.isRight()) {
      // Deleting the only row of a later page: go back first, so the table
      // never flashes an empty page.
      final wasLastRowOnLaterPage =
          (state.result?.items.length ?? 0) <= 1 && state.query.page > 1;
      if (wasLastRowOnLaterPage) {
        _updateQuery(state.query.copyWith(page: state.query.page - 1));
      }
      await load();
      if (isClosed) return result;
      if (!wasLastRowOnLaterPage &&
          state.result != null &&
          state.result!.items.isEmpty &&
          state.query.page > 1) {
        _updateQuery(state.query.copyWith(page: state.query.page - 1));
        await load();
      }
      if (isClosed) return result;
      _flashMessages.post(BrandsKeys.deleted, MessageType.success);
      emitEffect(const BrandsMutatedEffect(BrandsMutationKind.deleted));
    }
    return result;
  }

  Future<void> onBrandSaved({required bool isNew}) async {
    if (isClosed) return;
    emitEffect(
      BrandsMutatedEffect(
        isNew ? BrandsMutationKind.created : BrandsMutationKind.updated,
      ),
    );
    await load();
  }

  void _updateQuery(BrandListQuery query) {
    emit(state.copyWith(query: query, clearFailure: true));
  }

  @override
  Future<void> close() {
    _searchTimer?.cancel();
    _requestVersion++;
    return super.close();
  }
}
