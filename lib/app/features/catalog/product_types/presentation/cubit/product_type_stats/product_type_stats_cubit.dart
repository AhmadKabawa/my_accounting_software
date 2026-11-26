import 'package:accounting_software/app/core/foundation/types/paged_query.dart';
import 'package:accounting_software/app/core/foundation/base/use_case.dart';
import 'package:accounting_software/app/core/presentation/state_management/base_cubit.dart';
import 'package:accounting_software/app/features/catalog/product_types/domain/entity/product_type_list_query.dart';
import 'package:accounting_software/app/features/catalog/product_types/domain/entity/product_type_stats.dart';
import 'package:accounting_software/app/features/catalog/product_types/domain/repositories/product_types_repository.dart';
import 'package:accounting_software/app/features/catalog/product_types/presentation/cubit/product_type_stats/product_type_stats_state.dart';

class ProductTypeStatsCubit extends BaseCubit<ProductTypeStatsState, void> {
  ProductTypeStatsCubit({required ProductTypesRepository repository})
    : _repository = repository,
      super(const ProductTypeStatsInitial());

  final ProductTypesRepository _repository;
  int _requestVersion = 0;

  Future<void> load() async {
    final version = ++_requestVersion;
    final previous = state.stats;
    if (previous == null) emit(const ProductTypeStatsLoading());

    final first = await _repository.getPage(
      const ProductTypeListQuery(page: 1, pageSize: 100),
    );
    final failure = first.fold((value) => value, (_) => null);
    if (failure != null) {
      if (isClosed || version != _requestVersion) return;
      emit(
        previous == null
            ? ProductTypeStatsFailed(failure)
            : ProductTypeStatsRefreshFailed(previous, failure),
      );
      return;
    }

    final page = first.getOrElse(() => throw StateError('Unreachable'));
    final items = [...page.items];
    for (var index = 2; index <= page.totalPages; index++) {
      final result = await _repository.getPage(
        ProductTypeListQuery(page: index, pageSize: 100),
      );
      final pageFailure = result.fold((value) => value, (_) => null);
      if (pageFailure != null) {
        if (isClosed || version != _requestVersion) return;
        emit(
          previous == null
              ? ProductTypeStatsFailed(pageFailure)
              : ProductTypeStatsRefreshFailed(previous, pageFailure),
        );
        return;
      }
      items.addAll(result.getOrElse(() => throw StateError('Unreachable')).items);
    }

    if (isClosed || version != _requestVersion) return;
    final unknownUsage = items.any((item) => item.productCount == null);
    emit(
      ProductTypeStatsLoaded(
        ProductTypeStats(
          total: page.totalCount,
          active: items.where((item) => item.isActive).length,
          inactive: items.where((item) => !item.isActive).length,
          withoutProducts: unknownUsage
              ? null
              : items.where((item) => item.productCount == 0).length,
        ),
      ),
    );
  }

  Future<void> refresh() => load();

  @override
  Future<void> close() {
    _requestVersion++;
    return super.close();
  }
}
