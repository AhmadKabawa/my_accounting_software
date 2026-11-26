import 'package:flutter_test/flutter_test.dart';
import 'package:accounting_software/app/core/error/exceptions/api_exception.dart';
import 'package:accounting_software/app/core/foundation/types/api_result.dart';
import 'package:accounting_software/app/core/foundation/types/paginated_result.dart';
import 'package:accounting_software/app/features/catalog/units/data/datasources/unit_stats_remote_data_source_impl.dart';
import 'package:accounting_software/app/features/catalog/units/data/datasources/units_remote_data_source_impl.dart';
import 'package:accounting_software/app/features/catalog/units/data/repositories/units_repository_impl.dart';
import 'package:accounting_software/app/features/catalog/units/data/models/unit_model.dart';
import 'package:accounting_software/app/features/catalog/units/data/units_endpoint.dart';
import 'package:accounting_software/app/features/catalog/units/domain/entity/catalog_unit.dart';
import 'package:accounting_software/app/features/catalog/units/domain/entity/unit_draft.dart';
import 'package:accounting_software/app/features/catalog/units/domain/entity/unit_list_query.dart';
import 'package:accounting_software/app/features/catalog/units/domain/failures/unit_failure_keys.dart';
import 'package:accounting_software/app/features/catalog/units/domain/entity/unit_stats.dart';
import '../../support/fake_catalog_api_client.dart';

void main() {
  final unitJson = <String, dynamic>{
    'id': 7,
    'name': 'Piece',
    'symbol': 'pc',
    'unit_type': 'piece',
    'is_active': true,
    'updated_at': '2026-11-20T12:30:00Z',
    'product_variants': const [{'count': 2}],
    'attributes': const [{'count': 1}],
  };

  late FakeCatalogApiClient api;
  late UnitsRepositoryImpl repository;

  setUp(() {
    api = FakeCatalogApiClient()
      ..rows = [unitJson]
      ..writeRow = unitJson
      ..totalCount = 20
      ..activeCount = 14
      ..inactiveCount = 6;
    repository = UnitsRepositoryImpl(
      UnitsRemoteDataSourceImpl(api),
      UnitStatsRemoteDataSourceImpl(api),
    );
  });

  test('list query is server filtered, escaped and stably sorted', () async {
    final result = await repository.getUnits(
      const UnitListQuery(
        search: 'pc,',
        status: UnitStatusFilter.active,
        type: UnitType.piece,
        page: 2,
        pageSize: 10,
        sortAscending: false,
      ),
    );

    expect(result.isRight(), isTrue);
    final request = api.lastRequest;
    expect(request.path, UnitsEndpoint.collection.toStringPath());
    expect(request.query['select'], UnitsEndpoint.select);
    expect(request.query['order'], 'name.desc,id.asc');
    expect(request.query['is_active'], 'eq.true');
    expect(request.query['unit_type'], 'eq.piece');
    expect(request.query['or'], contains('pc'));
    expect(request.page, 2);
    expect(request.limit, 10);
  });

  test('create omits conversion fields and sends active state', () async {
    await repository.createUnit(
      const UnitDraft(
        name: 'Piece',
        symbol: 'pc',
        type: UnitType.piece,
        isActive: true,
      ),
    );

    final request = api.lastRequest;
    expect(request.method, 'POST');
    expect(request.body, {
      'name': 'Piece',
      'symbol': 'pc',
      'unit_type': 'piece',
      'is_active': true,
    });
    expect(request.body!.containsKey('base_unit_id'), isFalse);
    expect(request.body!.containsKey('conversion_factor'), isFalse);
    expect(request.options?.headers?['Prefer'], 'return=representation');
  });

  test('PATCH omits unchanged active state and conversion fields', () async {
    await repository.updateUnit(
      id: 7,
      draft: const UnitDraft(
        name: 'Piece',
        symbol: 'pc',
        type: UnitType.piece,
      ),
    );

    final request = api.lastRequest;
    expect(request.method, 'PATCH');
    expect(request.query, {'id': 'eq.7'});
    expect(request.body, {
      'name': 'Piece',
      'symbol': 'pc',
      'unit_type': 'piece',
    });
    expect(request.options?.headers?['Prefer'], 'return=representation');
  });

  test('23505 and 409 map to one translated duplicate-symbol failure', () async {
    api.nextPostFailure = ApiException.conflict(errorCode: '23505');

    final result = await repository.createUnit(
      const UnitDraft(
        name: 'Piece',
        symbol: 'pc',
        type: UnitType.piece,
      ),
    );

    final failure = result.fold((value) => value, (_) => null);
    expect(failure?.messageKey, UnitFailureKeys.duplicateSymbol);
  });

  test('23503 delete failure maps to translated in-use failure', () async {
    api.nextDeleteFailure = ApiException.conflict(errorCode: '23503');

    final result = await repository.deleteUnit(7);
    final failure = result.fold((value) => value, (_) => null);

    expect(failure?.messageKey, UnitFailureKeys.inUse);
  });

  test('statistics are server-derived, not calculated from the current page', () async {
    final result = await repository.getUnitStats();

    final stats = result.fold((_) => null, (value) => value);
    expect(stats, const UnitStats(total: 20, active: 14, inactive: 6));
    expect(api.requests, hasLength(2));
    expect(api.requests[0].query, {'select': 'id'});
    expect(api.requests[1].query, {
      'select': 'id',
      'is_active': 'eq.true',
    });
  });

  test('count projection 400 retries once without counts and caches fallback', () async {
    final remote = UnitsRemoteDataSourceImpl(api);
    api.nextPaginatedFailure = ApiException.badRequest();

    final first = await remote.getUnits(const UnitListQuery());
    final second = await remote.getUnits(const UnitListQuery(page: 2));

    expect(first, isA<ApiSuccess<PaginatedResult<UnitModel>>>());
    expect(second, isA<ApiSuccess<PaginatedResult<UnitModel>>>());
    expect(api.requests[0].query['select'], UnitsEndpoint.select);
    expect(api.requests[1].query['select'], UnitsEndpoint.baseSelect);
    expect(api.requests[2].query['select'], UnitsEndpoint.baseSelect);
    final unit = (second as ApiSuccess<PaginatedResult<UnitModel>>)
        .data.items.first;
    expect(unit.usageCount, isNull);
  });

  test('count projection does not retry on permission failure', () async {
    final remote = UnitsRemoteDataSourceImpl(api);
    api.nextPaginatedFailure = ApiException.forbidden();

    final result = await remote.getUnits(const UnitListQuery());

    expect(result, isA<ApiFailure<PaginatedResult<UnitModel>>>());
    expect(api.requests, hasLength(1));
  });
}
