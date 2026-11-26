import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:accounting_software/app/core/error/failures/failure.dart';
import 'package:accounting_software/app/core/foundation/types/paginated_result.dart';
import 'package:accounting_software/app/features/catalog/units/domain/entity/catalog_unit.dart';
import 'package:accounting_software/app/features/catalog/units/domain/entity/unit_draft.dart';
import 'package:accounting_software/app/features/catalog/units/domain/entity/unit_list_query.dart';
import 'package:accounting_software/app/features/catalog/units/domain/entity/unit_stats.dart';
import 'package:accounting_software/app/features/catalog/units/domain/repositories/units_repository.dart';
import 'package:accounting_software/app/features/catalog/units/domain/usecase/get_unit_stats_use_case.dart';
import 'package:accounting_software/app/features/catalog/units/presentation/cubit/unit_stats/unit_stats_cubit.dart';
import 'package:accounting_software/app/features/catalog/units/presentation/cubit/unit_stats/unit_stats_state.dart';

void main() {
  test('UnitStatsCubit loads and refreshes server-derived counts', () async {
    final repository = _FakeUnitsRepository();
    final cubit = UnitStatsCubit(getUnitStats: GetUnitStatsUseCase(repository));
    addTearDown(cubit.close);

    await cubit.load();

    expect(cubit.state.status, UnitStatsStatus.ready);
    expect(
      cubit.state.stats,
      const UnitStats(total: 8, active: 6, inactive: 2),
    );
    expect(repository.statsCalls, 1);

    await cubit.refresh();
    expect(repository.statsCalls, 2);
  });
}

class _FakeUnitsRepository implements UnitsRepository {
  int statsCalls = 0;

  @override
  Future<Either<Failure, UnitStats>> getUnitStats() async {
    statsCalls++;
    return const Right(UnitStats(total: 8, active: 6, inactive: 2));
  }

  @override
  Future<Either<Failure, PaginatedResult<CatalogUnit>>> getUnits(
    UnitListQuery query,
  ) => throw UnimplementedError();

  @override
  Future<Either<Failure, CatalogUnit>> createUnit(UnitDraft draft) =>
      throw UnimplementedError();

  @override
  Future<Either<Failure, CatalogUnit>> updateUnit({
    required int id,
    required UnitDraft draft,
  }) => throw UnimplementedError();

  @override
  Future<Either<Failure, Unit>> setUnitActive({
    required int id,
    required bool isActive,
  }) => throw UnimplementedError();

  @override
  Future<Either<Failure, Unit>> deleteUnit(int id) =>
      throw UnimplementedError();
}
