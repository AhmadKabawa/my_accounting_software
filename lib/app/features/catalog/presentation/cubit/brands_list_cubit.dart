import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:accounting_software/app/core/error/failures/failure.dart';
import 'package:accounting_software/app/core/foundation/config/app_config.dart';
import 'package:accounting_software/app/core/foundation/types/paginated_result.dart';
import 'package:accounting_software/app/features/catalog/domain/entity/brand.dart';
import 'package:accounting_software/app/features/catalog/domain/entity/brand_list_query.dart';
import 'package:accounting_software/app/features/catalog/domain/failures/brand_failures.dart';
import 'package:accounting_software/app/features/catalog/domain/usecase/delete_brand_use_case.dart';
import 'package:accounting_software/app/features/catalog/domain/usecase/get_brands_use_case.dart';
import 'package:accounting_software/app/features/catalog/domain/usecase/set_brand_active_use_case.dart';

sealed class BrandsListState extends Equatable {
  const BrandsListState();
}

final class BrandsListInitial extends BrandsListState {
  const BrandsListInitial();
  @override
  List<Object?> get props => [];
}

final class BrandsListLoading extends BrandsListState {
  const BrandsListLoading();
  @override
  List<Object?> get props => [];
}

final class BrandsListReady extends BrandsListState {
  const BrandsListReady({
    required this.result,
    required this.query,
  });
  final PaginatedResult<Brand> result;
  final BrandListQuery query;

  @override
  List<Object?> get props => [result, query];
}

final class BrandsListFailed extends BrandsListState {
  const BrandsListFailed(this.failure);
  final Failure failure;

  @override
  List<Object?> get props => [failure];
}

class BrandsListCubit extends Cubit<BrandsListState> {
  BrandsListCubit({
    required GetBrandsUseCase getBrands,
    required SetBrandActiveUseCase setBrandActive,
    required DeleteBrandUseCase deleteBrand,
  }) : _getBrands = getBrands,
       _setBrandActive = setBrandActive,
       _deleteBrand = deleteBrand,
       super(const BrandsListInitial());

  final GetBrandsUseCase _getBrands;
  final SetBrandActiveUseCase _setBrandActive;
  final DeleteBrandUseCase _deleteBrand;

  BrandListQuery _query = const BrandListQuery(
    page: AppConfig.defaultPage,
    pageSize: AppConfig.defaultPageSize,
  );
  Timer? _searchTimer;
  int _requestVersion = 0;
  BrandListQuery get query => _query;
  Future<void> load() async {
    _searchTimer?.cancel();
    final requestVersion = ++_requestVersion;
    if (state is! BrandsListReady) emit(const BrandsListLoading());
    final result = await _getBrands(_query);
    if (isClosed || requestVersion != _requestVersion) return;
    result.fold(
      (failure) => emit(BrandsListFailed(failure)),
      (page) =>
          emit(BrandsListReady(result: page, query: _query)),
    );
  }

  void searchChanged(String value) {
    _query = _query.copyWith(search: value, page: 1);
    _requestVersion++;
    _searchTimer?.cancel();
    _searchTimer = Timer(const Duration(milliseconds: 300), load);
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
    final result = await _setBrandActive(
      SetBrandActiveParams(id: id, isActive: isActive),
    );
    if (isClosed) return result;
    if (result.isRight()) {
      await load();
    }
    return result;
  }

  Future<Either<Failure, Unit>> delete(Brand brand) async {
    if (brand.productCount != 0) {
      return const Left(BrandInUseFailure());
    }
    final result = await _deleteBrand(brand.id);
    if (isClosed) return result;
    if (result.isRight()) {
      await load();
      final current = state;
      if (!isClosed &&
          _query.page > 1 &&
          current is BrandsListReady &&
          current.result.items.isEmpty) {
        _query = _query.copyWith(page: _query.page - 1);
        await load();
      }
    }
    return result;
  }

  @override
  Future<void> close() {
    _searchTimer?.cancel();
    _requestVersion++;
    return super.close();
  }
}
