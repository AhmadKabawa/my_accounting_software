import 'package:flutter_test/flutter_test.dart';
import 'package:accounting_software/app/core/error/exceptions/api_exception.dart';
import 'package:accounting_software/app/core/foundation/types/api_result.dart';
import 'package:accounting_software/app/core/foundation/types/paginated_result.dart';
import 'package:accounting_software/app/features/catalog/option_sets/data/datasources/option_set_stats_remote_data_source_impl.dart';
import 'package:accounting_software/app/features/catalog/option_sets/data/datasources/option_sets_remote_data_source_impl.dart';
import 'package:accounting_software/app/features/catalog/option_sets/data/models/option_set_model.dart';
import 'package:accounting_software/app/features/catalog/option_sets/data/option_sets_endpoint.dart';
import 'package:accounting_software/app/features/catalog/option_sets/data/repositories/option_sets_repository_impl.dart';
import 'package:accounting_software/app/features/catalog/option_sets/domain/entity/option_set.dart';
import 'package:accounting_software/app/features/catalog/option_sets/domain/entity/option_set_draft.dart';
import 'package:accounting_software/app/features/catalog/option_sets/domain/entity/option_set_list_query.dart';
import 'package:accounting_software/app/features/catalog/option_sets/domain/entity/option_set_stats.dart';
import 'package:accounting_software/app/features/catalog/option_sets/domain/failures/option_set_failure_keys.dart';
import '../../support/fake_catalog_api_client.dart';

void main() {
  final setJson = <String, dynamic>{
    'id': 9,
    'name': 'Colours',
    'code': 'COL',
    'selection_type': 'multiple',
    'is_active': true,
    'options': const [{'count': 4}],
    'attributes': const [{'count': 2}],
    'product_type_option_sets': const [{'count': 1}],
  };

  late FakeCatalogApiClient api;
  late OptionSetsRepositoryImpl repository;

  setUp(() {
    api = FakeCatalogApiClient()
      ..rows = [setJson]
      ..writeRow = setJson
      ..totalCount = 20
      ..activeCount = 14
      ..inactiveCount = 6;
    repository = OptionSetsRepositoryImpl(
      OptionSetsRemoteDataSourceImpl(api),
      OptionSetStatsRemoteDataSourceImpl(api),
    );
  });

  test('list is server filtered and stably sorted', () async {
    final result = await repository.getOptionSets(
      const OptionSetListQuery(
        search: 'col,',
        status: OptionSetStatusFilter.active,
        page: 2,
        pageSize: 10,
        sortAscending: false,
      ),
    );
    expect(result.isRight(), isTrue);
    expect(api.lastRequest.query['select'], contains('options(count)'));
    expect(api.lastRequest.query['order'], 'name.desc,id.asc');
    expect(api.lastRequest.query['is_active'], 'eq.true');
    expect(api.lastRequest.query['or'], contains('col'));
    expect(api.lastRequest.page, 2);
  });

  test('group create sends active state', () async {
    await repository.createOptionSet(
      const OptionSetDraft(
        name: 'Colours',
        code: 'COL',
        selectionType: OptionSelectionType.multiple,
      ),
    );
    expect(api.lastRequest.method, 'POST');
    expect(api.lastRequest.body, {
      'name': 'Colours',
      'code': 'COL',
      'selection_type': 'multiple',
      'is_active': true,
    });
    expect(api.lastRequest.options?.headers?['Prefer'], 'return=representation');
  });

  test('options are fetched lazily for a set in stable order', () async {
    api.rows = [
      {
        'id': 31,
        'name': 'Blue',
        'code': 'BLUE',
        'sort_order': 2,
        'is_active': true,
      },
    ];
    final result = await repository.getOptions(optionSetId: 9, search: 'bl');
    expect(result.isRight(), isTrue);
    expect(api.lastRequest.path, OptionSetsEndpoint.optionsCollection.toStringPath());
    expect(api.lastRequest.query['option_set_id'], 'eq.9');
    expect(api.lastRequest.query['order'], 'sort_order.asc,name.asc,id.asc');
    expect(api.lastRequest.query['or'], contains('bl'));
    final options = result.fold((_) => <CatalogOption>[], (value) => value);
    expect(options.single.sortOrder, 2);
  });

  test('create option is scoped to the group and sends sort order', () async {
    await repository.createOption(
      optionSetId: 9,
      draft: const CatalogOptionDraft(
        name: 'Blue',
        code: 'BLUE',
        sortOrder: 4,
        isActive: true,
      ),
    );
    expect(api.lastRequest.path, OptionSetsEndpoint.optionsCollection.toStringPath());
    expect(api.lastRequest.body, {
      'option_set_id': 9,
      'name': 'Blue',
      'code': 'BLUE',
      'sort_order': 4,
      'is_active': true,
    });
  });

  test('update option cannot change its parent set', () async {
    await repository.updateOption(
      optionId: 31,
      draft: const CatalogOptionDraft(
        name: 'Azure',
        code: 'AZURE',
        sortOrder: 5,
      ),
    );
    expect(api.lastRequest.query, {'id': 'eq.31'});
    expect(api.lastRequest.body, {
      'name': 'Azure',
      'code': 'AZURE',
      'sort_order': 5,
    });
  });

  test('duplicate group and option codes map to separate failures', () async {
    api.nextPostFailure = ApiException.conflict(errorCode: '23505');
    final group = await repository.createOptionSet(
      const OptionSetDraft(
        name: 'Colours',
        code: 'COL',
        selectionType: OptionSelectionType.single,
      ),
    );
    expect(
      group.fold((failure) => failure.messageKey, (_) => null),
      OptionSetFailureKeys.duplicateCode,
    );

    api.nextPostFailure = ApiException.conflict(errorCode: '23505');
    final option = await repository.createOption(
      optionSetId: 9,
      draft: const CatalogOptionDraft(name: 'Blue', code: 'BLUE', sortOrder: 0),
    );
    expect(
      option.fold((failure) => failure.messageKey, (_) => null),
      OptionSetFailureKeys.duplicateOptionCode,
    );
  });

  test('23503 delete maps to the translated in-use failure', () async {
    api.nextDeleteFailure = ApiException.conflict(errorCode: '23503');
    final result = await repository.deleteOptionSet(9);
    expect(
      result.fold((failure) => failure.messageKey, (_) => null),
      OptionSetFailureKeys.inUse,
    );
  });

  test('23514 and ERP28 map to translated selection failures', () async {
    api.nextPatchFailure = ApiException.constraint(errorCode: '23514');
    final invalid = await repository.updateOptionSet(
      id: 9,
      draft: const OptionSetDraft(
        name: 'Colours',
        code: 'COL',
        selectionType: OptionSelectionType.single,
      ),
    );
    expect(
      invalid.fold((failure) => failure.messageKey, (_) => null),
      OptionSetFailureKeys.invalidSelectionType,
    );

    api.nextPatchFailure = ApiException.erp(code: 'ERP28');
    final locked = await repository.updateOptionSet(
      id: 9,
      draft: const OptionSetDraft(
        name: 'Colours',
        code: 'COL',
        selectionType: OptionSelectionType.single,
      ),
    );
    expect(
      locked.fold((failure) => failure.messageKey, (_) => null),
      OptionSetFailureKeys.selectionTypeLocked,
    );
  });

  test('permission failure does not retry the count projection', () async {
    final remote = OptionSetsRemoteDataSourceImpl(api);
    api.nextPaginatedFailure = ApiException.forbidden();
    final result = await remote.getOptionSets(const OptionSetListQuery());
    expect(result, isA<ApiFailure<PaginatedResult<OptionSetModel>>>());
    expect(api.requests, hasLength(1));
  });

  test('statistics use independent server counts', () async {
    final result = await repository.getOptionSetStats();
    expect(
      result.fold((_) => null, (value) => value),
      const OptionSetStats(total: 20, active: 14, inactive: 6),
    );
    expect(api.requests, hasLength(2));
    expect(api.requests.first.query, {'select': 'id'});
    expect(api.requests.last.query, {'select': 'id', 'is_active': 'eq.true'});
  });

  test('count projection 400 retries without embedded counts', () async {
    final remote = OptionSetsRemoteDataSourceImpl(api);
    api.nextPaginatedFailure = ApiException.badRequest();
    final result = await remote.getOptionSets(const OptionSetListQuery());
    expect(result, isA<ApiSuccess<PaginatedResult<OptionSetModel>>>());
    expect(api.requests.first.query['select'], contains('options(count)'));
    expect(api.requests.last.query['select'], OptionSetsEndpoint.baseSelect);
  });
}
