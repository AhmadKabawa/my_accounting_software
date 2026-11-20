import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:accounting_software/app/core/foundation/types/paginated_result.dart';
import 'package:accounting_software/app/features/catalog/domain/entity/brand.dart';
import 'package:accounting_software/app/features/catalog/domain/entity/brand_list_query.dart';
import 'package:accounting_software/app/features/catalog/domain/usecase/get_brands_use_case.dart';
import 'package:accounting_software/app/features/catalog/presentation/cubit/brand_stats_cubit.dart';

import 'support/fake_brands_repository.dart';

void main() {
  test('loads global total, active and inactive counts independently', () async {
    final repository = FakeBrandsRepository();
    repository.onGetBrands = (query) async {
      final count = query.status == BrandStatusFilter.active ? 6 : 9;
      return Right(PaginatedResult<Brand>(
        items: const [],
        totalCount: count,
        currentPage: 1,
        totalPages: count,
      ));
    };
    final cubit = BrandStatsCubit(getBrands: GetBrandsUseCase(repository));

    await cubit.load();

    expect(cubit.state, isA<BrandStatsLoaded>());
    final stats = (cubit.state as BrandStatsLoaded).stats;
    expect(stats.total, 9);
    expect(stats.active, 6);
    expect(stats.inactive, 3);
    expect(repository.queries, hasLength(2));
    expect(repository.queries.every((query) => query.search.isEmpty), isTrue);
    await cubit.close();
  });

  test('does not publish stale statistics after a newer refresh', () async {
    final repository = FakeBrandsRepository();
    repository.onGetBrands = (query) async => Right(PaginatedResult<Brand>(
      items: const [],
      totalCount: query.status == BrandStatusFilter.active ? 4 : 8,
      currentPage: 1,
      totalPages: 1,
    ));
    final cubit = BrandStatsCubit(getBrands: GetBrandsUseCase(repository));

    await cubit.load();
    expect((cubit.state as BrandStatsLoaded).stats.active, 4);
    await cubit.refresh();
    expect((cubit.state as BrandStatsLoaded).stats.total, 8);
    await cubit.close();
  });
}
