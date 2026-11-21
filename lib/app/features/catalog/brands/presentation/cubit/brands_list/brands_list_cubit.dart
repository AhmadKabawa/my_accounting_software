import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:accounting_software/app/core/presentation/state_management/base_cubit.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_message/flash_messages.dart';
import 'package:accounting_software/app/core/error/failures/failure.dart';
import 'package:accounting_software/app/core/foundation/config/app_config.dart';
import 'package:accounting_software/app/features/catalog/brands/domain/entity/brand.dart';
import 'package:accounting_software/app/features/catalog/brands/domain/entity/brand_list_query.dart';
import 'package:accounting_software/app/features/catalog/brands/domain/failures/brand_failures.dart';
import 'package:accounting_software/app/features/catalog/brands/domain/usecase/delete_brand_use_case.dart';
import 'package:accounting_software/app/features/catalog/brands/domain/usecase/get_brands_use_case.dart';
import 'package:accounting_software/app/features/catalog/brands/domain/usecase/set_brand_active_use_case.dart';
import 'package:accounting_software/app/features/catalog/brands/presentation/cubit/brands_list/brands_list_state.dart';
import 'package:accounting_software/app/features/catalog/brands/presentation/localization/brands_keys.dart';

class BrandsListCubit extends BaseCubit<BrandsListState, void> {
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

  BrandListQuery _query = const BrandListQuery(
    page: AppConfig.defaultPage,
    pageSize: AppConfig.defaultPageSize,
  );
  Timer? _searchTimer;
  int _requestVersion = 0;
  BrandListQuery get query => _query;

  Future<void> load() async {
    _searchTimer?.cancel();
    final version = ++_requestVersion;
    final previous = state.result;
    emit(BrandsListState(
      status: previous == null ? BrandsListStatus.loading : BrandsListStatus.success,
      query: _query,
      result: previous,
    ));
    final response = await _getBrands(_query);
    if (isClosed || version != _requestVersion) return;
    response.fold(
      (failure) => emit(BrandsListState(
        status: BrandsListStatus.failure,
        query: _query,
        result: previous,
        failure: failure,
      )),
      (page) => emit(BrandsListState(
        status: BrandsListStatus.success,
        query: _query,
        result: page,
      )),
    );
  }

  void searchChanged(String value) {
    _query = _query.copyWith(search: value, page: 1);
    _requestVersion++;
    _searchTimer?.cancel();
    _searchTimer = Timer(const Duration(milliseconds: 300), load);
    emit(state.copyWith(query: _query, clearFailure: true));
  }

  Future<void> setStatus(BrandStatusFilter status) {
    if (_query.status == status) return Future.value();
    _query = _query.copyWith(status: status, page: 1);
    return load();
  }

  Future<void> setSort({required bool ascending}) {
    if (_query.sortAscending == ascending) return Future.value();
    _query = _query.copyWith(sortAscending: ascending, page: 1);
    return load();
  }

  Future<void> setPage(int page) {
    if (page < 1 || page == _query.page) return Future.value();
    _query = _query.copyWith(page: page);
    return load();
  }

  Future<void> refresh() => load();

  Future<Either<Failure, Unit>> setActive({
    required int id,
    required bool isActive,
  }) async {
    final response = await _setBrandActive(
      SetBrandActiveParams(id: id, isActive: isActive),
    );
    if (isClosed) return response;
    if (response.isRight()) {
      await load();
      if (!isClosed) {
        _flashMessages.post(BrandsKeys.statusUpdated, MessageType.success);
      }
    }
    return response;
  }

  Future<Either<Failure, Unit>> delete(Brand brand) async {
    if (!brand.canDelete) return const Left(BrandInUseFailure());
    final response = await _deleteBrand(brand.id);
    if (isClosed) return response;
    if (response.isRight()) {
      await load();
      if (!isClosed &&
          _query.page > 1 &&
          state.result != null &&
          state.result!.items.isEmpty) {
        _query = _query.copyWith(page: _query.page - 1);
        await load();
      }
      if (!isClosed) {
        _flashMessages.post(BrandsKeys.deleted, MessageType.success);
      }
    }
    return response;
  }

  @override
  Future<void> close() {
    _searchTimer?.cancel();
    _requestVersion++;
    return super.close();
  }
}
