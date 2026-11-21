import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:accounting_software/app/core/error/failures/failure.dart';
import 'package:accounting_software/app/features/catalog/brands/domain/entity/brand_stats.dart';
import 'package:accounting_software/app/features/catalog/brands/presentation/localization/brands_keys.dart';
import 'package:accounting_software/app/features/catalog/brands/domain/usecase/get_brand_stats_use_case.dart';
import 'package:accounting_software/app/features/catalog/brands/presentation/cubit/brand_stats/brand_stats_cubit.dart';
import 'package:accounting_software/app/features/catalog/brands/presentation/cubit/brand_stats/brand_stats_state.dart';

import '../../support/fake_brands_repository.dart';

class _StatsFailure extends Failure {
  const _StatsFailure() : super(messageKey: BrandsKeys.loadError);
}

void main() {
  test('loads aggregate statistics from the repository operation', () async {
    final repository = FakeBrandsRepository()
      ..onGetBrandStats = () async => const Right(
        BrandStats(total: 9, active: 6, inactive: 3),
      );
    final cubit = BrandStatsCubit(
      getBrandStats: GetBrandStatsUseCase(repository),
    );

    await cubit.load();

    expect(cubit.state, isA<BrandStatsLoaded>());
    final stats = (cubit.state as BrandStatsLoaded).stats;
    expect(stats.total, 9);
    expect(stats.active, 6);
    expect(stats.inactive, 3);
    expect(repository.queries, isEmpty);
    await cubit.close();
  });

  test('ignores stale statistics when a newer refresh finishes first',
      () async {
    final repository = FakeBrandsRepository();
    final pending = <Completer<Either<Failure, BrandStats>>>[];
    repository.onGetBrandStats = () {
      final request = Completer<Either<Failure, BrandStats>>();
      pending.add(request);
      return request.future;
    };
    final cubit = BrandStatsCubit(
      getBrandStats: GetBrandStatsUseCase(repository),
    );

    final first = cubit.load();
    final second = cubit.refresh();
    pending[1].complete(
      const Right(BrandStats(total: 10, active: 7, inactive: 3)),
    );
    await second;
    pending[0].complete(
      const Right(BrandStats(total: 3, active: 2, inactive: 1)),
    );
    await first;

    final stats = (cubit.state as BrandStatsLoaded).stats;
    expect(stats.total, 10);
    expect(stats.active, 7);
    await cubit.close();
  });

  test('refresh failure retains the last stats without a flash message',
      () async {
    var requests = 0;
    final repository = FakeBrandsRepository()
      ..onGetBrandStats = () async {
        requests++;
        if (requests == 1) {
          return const Right(BrandStats(total: 9, active: 6, inactive: 3));
        }
        return const Left(_StatsFailure());
      };
    final cubit = BrandStatsCubit(
      getBrandStats: GetBrandStatsUseCase(repository),
    );

    await cubit.load();
    await cubit.refresh();

    expect(cubit.state, isA<BrandStatsRefreshFailed>());
    final state = cubit.state as BrandStatsRefreshFailed;
    expect(state.stats, const BrandStats(total: 9, active: 6, inactive: 3));
    expect(state.failure, isA<_StatsFailure>());
    await cubit.close();
  });

  test('reports failure when the repository cannot calculate statistics',
      () async {
    final repository = FakeBrandsRepository()
      ..onGetBrandStats = () async => const Left(_StatsFailure());
    final cubit = BrandStatsCubit(
      getBrandStats: GetBrandStatsUseCase(repository),
    );

    await cubit.load();

    expect(cubit.state, isA<BrandStatsFailed>());
    await cubit.close();
  });
}
