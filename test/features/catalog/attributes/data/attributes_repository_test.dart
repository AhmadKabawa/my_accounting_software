import 'package:flutter_test/flutter_test.dart';
import 'package:accounting_software/app/core/error/exceptions/api_exception.dart';
import 'package:accounting_software/app/features/catalog/attributes/data/attributes_endpoint.dart';
import 'package:accounting_software/app/features/catalog/attributes/data/datasources/attributes_remote_data_source_impl.dart';
import 'package:accounting_software/app/features/catalog/attributes/data/datasources/attribute_stats_remote_data_source_impl.dart';
import 'package:accounting_software/app/features/catalog/attributes/data/repositories/attributes_repository_impl.dart';
import 'package:accounting_software/app/features/catalog/attributes/domain/entity/attribute_draft.dart';
import 'package:accounting_software/app/features/catalog/attributes/domain/entity/catalog_attribute.dart';
import 'package:accounting_software/app/features/catalog/attributes/domain/entity/attribute_list_query.dart';
import 'package:accounting_software/app/features/catalog/attributes/presentation/localization/attributes_keys.dart';
import '../../support/fake_catalog_api_client.dart';

void main() {
  final row = <String, dynamic>{
    'id': 7, 'name': 'Material', 'code': 'MATERIAL', 'data_type': 'text',
    'unit_id': null, 'option_set_id': null, 'is_filterable': true, 'is_active': true,
    'units': null, 'option_sets': null,
    'product_type_attributes': const [{'count': 0}],
    'product_attribute_values': const [{'count': 0}],
  };
  late FakeCatalogApiClient api;
  late AttributesRepositoryImpl repository;
  setUp(() {
    api = FakeCatalogApiClient()..rows = [row]..writeRow = row..totalCount = 12..activeCount = 8..inactiveCount = 4..filterableCount = 5;
    repository = AttributesRepositoryImpl(
      AttributesRemoteDataSourceImpl(api),
      AttributeStatsRemoteDataSourceImpl(api),
    );
  });

  test('list search and filters are sent to PostgREST with stable order', () async {
    final result = await repository.getAttributes(const AttributeListQuery(
      search: 'mat', status: AttributeStatusFilter.active,
      dataType: AttributeDataType.text, filterable: AttributeFilterableFilter.filterable,
      page: 2, pageSize: 10,
    ));
    expect(result.isRight(), isTrue);
    final request = api.lastRequest;
    expect(request.path, AttributesEndpoint.collection.toStringPath());
    expect(request.query['order'], 'name.asc,id.asc');
    expect(request.query['is_active'], 'eq.true');
    expect(request.query['data_type'], 'eq.text');
    expect(request.query['is_filterable'], 'eq.true');
    expect(request.query['or'], contains('name.ilike'));
    expect(request.page, 2);
    expect(request.limit, 10);
  });

  test('create sends active true and excludes hidden fields', () async {
    await repository.createAttribute(const AttributeDraft(
      name: 'Material', code: 'MATERIAL', dataType: AttributeDataType.text,
      isFilterable: true, isActive: true,
    ));
    expect(api.lastRequest.method, 'POST');
    expect(api.lastRequest.body, {
      'name': 'Material', 'code': 'MATERIAL', 'data_type': 'text',
      'unit_id': null, 'option_set_id': null, 'is_filterable': true, 'is_active': true,
    });
    expect(api.lastRequest.body!.containsKey('is_required'), isFalse);
    expect(api.lastRequest.body!.containsKey('is_variant_option'), isFalse);
  });

  test('PATCH omits unchanged active state and status action patches only status', () async {
    await repository.updateAttribute(id: 7, draft: const AttributeDraft(
      name: 'Material', code: 'MATERIAL', dataType: AttributeDataType.text,
      isFilterable: true,
    ));
    expect(api.lastRequest.method, 'PATCH');
    expect(api.lastRequest.query, {'id': 'eq.7'});
    expect(api.lastRequest.body!.containsKey('is_active'), isFalse);
    await repository.setAttributeActive(id: 7, isActive: false);
    expect(api.lastRequest.body, {'is_active': false});
  });

  test('option relation is sent if and only if data type is option', () async {
    await repository.createAttribute(const AttributeDraft(
      name: 'Size', code: 'SIZE', dataType: AttributeDataType.option,
      optionSetId: 4, isFilterable: false, isActive: true,
    ));
    expect(api.lastRequest.body!['option_set_id'], 4);
    await repository.createAttribute(const AttributeDraft(
      name: 'Length', code: 'LENGTH', dataType: AttributeDataType.number,
      unitId: 2, isFilterable: false, isActive: true,
    ));
    expect(api.lastRequest.body!['option_set_id'], isNull);
    expect(api.lastRequest.body!['unit_id'], 2);
  });

  test('statistics use four independent server count queries', () async {
    final result = await repository.getAttributeStats();
    expect(result.fold((_) => null, (value) => value.all), 12);
    expect(result.fold((_) => null, (value) => value.active), 8);
    expect(result.fold((_) => null, (value) => value.inactive), 4);
    expect(result.fold((_) => null, (value) => value.filterable), 5);
    expect(api.requests, hasLength(4));
    expect(api.requests.map((r) => r.query['select']), everyElement('id'));
  });

  test('duplicate, constraint, and ERP errors map to translated keys', () async {
    api.nextPostFailure = ApiException.conflict(errorCode: '23505');
    var result = await repository.createAttribute(const AttributeDraft(
      name: 'Material', code: 'MATERIAL', dataType: AttributeDataType.text,
      isFilterable: true,
    ));
    expect(result.fold((f) => f.messageKey, (_) => null), AttributesKeys.duplicateCode);

    api.nextPostFailure = ApiException.erp(errorCode: 'ERP27');
    result = await repository.createAttribute(const AttributeDraft(
      name: 'Material', code: 'MATERIAL', dataType: AttributeDataType.text,
      isFilterable: true,
    ));
    expect(result.fold((f) => f.messageKey, (_) => null), AttributesKeys.erp27);
  });

  test('23503 delete race returns the in-use translation', () async {
    api.nextDeleteFailure = ApiException.conflict(errorCode: '23503');
    final result = await repository.deleteAttribute(7);
    expect(result.fold((f) => f.messageKey, (_) => null), AttributesKeys.inUse);
  });
}
