import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:accounting_software/app/core/error/failures/failure.dart';
import 'package:accounting_software/app/core/foundation/types/paginated_result.dart';
import 'package:accounting_software/app/features/catalog/brands/domain/entity/brand.dart';
import 'package:accounting_software/app/features/catalog/brands/domain/entity/brand_list_query.dart';
import 'package:accounting_software/app/features/catalog/brands/domain/usecase/get_brand_stats_use_case.dart';
import 'package:accounting_software/app/features/catalog/brands/presentation/cubit/brand_stats_cubit.dart';
import 'package:accounting_software/app/features/catalog/brands/presentation/cubit/brand_stats/brand_stats_state.dart';

import '../../support/fake_brands_repository.dart';

void main() {
  test(
    'loads global total, active and inactive counts independently',
    () async {
      final repository = FakeBrandsRepository();
      repository.onGetBrands = (query) async {
        final count = query.status == BrandStatusFilter.active ? 6 : 9;
        return Right(
          PaginatedResult<Brand>(
            items: const [],
            totalCount: count,
            currentPage: 1,
            totalPages: count,
          ),
        );
      };
      final cubit = BrandStatsCubit(
        getBrandStats: GetBrandStatsUseCase(repository),
      );

      await cubit.load();

      expect(cubit.state, isA<BrandStatsLoaded>());
      final stats = (cubit.state as BrandStatsLoaded).stats;
      expect(stats.total, 9);
      expect(stats.active, 6);
      expect(stats.inactive, 3);
      expect(repository.queries, hasLength(2));
      expect(repository.queries.every((query) => query.search.isEmpty), isTrue);
      await cubit.close();
    },
  );

  test(
    'ignores stale statistics when a newer refresh finishes first',
    () async {
      final repository = FakeBrandsRepository();
      final pending = <Completer<Either<Failure, PaginatedResult<Brand>>>>[];
      repository.onGetBrands = (_) {
        final request = Completer<Either<Failure, PaginatedResult<Brand>>>();
        pending.add(request);
        return request.future;
      };
      final cubit = BrandStatsCubit(
        getBrandStats: GetBrandStatsUseCase(repository),
      );

      final firstLoad = cubit.load();
      await Future<void>.delayed(Duration.zero);
      final secondLoad = cubit.refresh();
      await Future<void>.delayed(Duration.zero);
      expect(pending, hasLength(4));

      pending[2].complete(Right(_page(total: 10)));
      pending[3].complete(Right(_page(total: 7)));
      await Future<void>.delayed(Duration.zero);
      expect((cubit.state as BrandStatsLoaded).stats.total, 10);
      expect((cubit.state as BrandStatsLoaded).stats.active, 7);

      pending[0].complete(Right(_page(total: 3)));
      pending[1].complete(Right(_page(total: 2)));
      await Future.wait([firstLoad, secondLoad]);

      expect((cubit.state as BrandStatsLoaded).stats.total, 10);
      expect((cubit.state as BrandStatsLoaded).stats.active, 7);
      await cubit.close();
    },
  );
}

PaginatedResult<Brand> _page({required int total}) => PaginatedResult<Brand>(
  items: const [],
  totalCount: total,
  currentPage: 1,
  totalPages: total,
);
