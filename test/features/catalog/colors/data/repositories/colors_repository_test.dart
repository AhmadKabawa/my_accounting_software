import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:accounting_software/app/core/error/exceptions/api_exception.dart';
import 'package:accounting_software/app/features/catalog/colors/data/datasources/colors_remote_data_source_impl.dart';
import 'package:accounting_software/app/features/catalog/colors/data/datasources/color_stats_remote_data_source_impl.dart';
import 'package:accounting_software/app/features/catalog/colors/data/repositories/colors_repository_impl.dart';
import 'package:accounting_software/app/features/catalog/colors/domain/entity/catalog_color_draft.dart';
import 'package:accounting_software/app/features/catalog/colors/domain/entity/color_list_query.dart';
import 'package:accounting_software/app/features/catalog/colors/domain/failures/color_failures.dart';

import '../../support/fake_colors_api_client.dart';

void main() {
  late FakeColorsApiClient api;
  late ColorsRepositoryImpl repository;

  setUp(() {
    api = FakeColorsApiClient();
    repository = ColorsRepositoryImpl(
      ColorsRemoteDataSourceImpl(api),
      ColorStatsRemoteDataSourceImpl(api),
    );
  });

  test('default query orders by sort_order then name', () async {
    final result = await repository.getColors(const ColorListQuery());

    expect(api.lastPath, '/rest/v1/colors');
    expect(api.lastQueryParameters['order'], 'sort_order.asc,name.asc,id.asc');
    expect(api.lastQueryParameters.containsKey('or'), isFalse);
    expect(api.lastQueryParameters.containsKey('is_active'), isFalse);
    expect(api.usageQuery, {
      'select': 'color_id,product_count,component_count',
      'color_id': 'in.(7)',
    });
    result.fold((_) => fail('Expected color page'), (page) {
      expect(page.items.single.productCount, 4);
      expect(page.items.single.componentCount, 9);
    });
  });

  test(
    'keeps the color list available when the usage view is not readable',
    () async {
      api.usageFailure = ApiException.forbidden();

      final result = await repository.getColors(const ColorListQuery());

      result.fold((_) => fail('Expected the base color page'), (page) {
        expect(page.items.single.id, 7);
        expect(page.items.single.productCount, isNull);
        expect(page.items.single.componentCount, isNull);
      });
    },
  );

  test('builds search, status, sort and pagination parameters', () async {
    await repository.getColors(
      const ColorListQuery(
        search: 'Na"vy',
        status: ColorStatusFilter.inactive,
        sortField: ColorSortField.code,
        sortAscending: false,
        page: 3,
        pageSize: 10,
      ),
    );

    expect(api.lastQueryParameters['order'], 'code.desc,name.asc,id.asc');
    expect(api.lastQueryParameters['is_active'], 'eq.false');
    expect(api.lastQueryParameters['or'], contains(r'Na\"vy'));
    expect(api.lastQueryParameters['or'], contains('code.ilike'));
    expect(api.lastQueryParameters['or'], contains('hex_code.ilike'));
    expect(api.lastPage, 3);
    expect(api.lastLimit, 10);
  });

  test('create normalizes hex and requests the representation', () async {
    final result = await repository.createColor(
      const CatalogColorDraft(
        name: ' Navy ',
        code: ' NAVY ',
        hexCode: ' #1e3a8a ',
        sortOrder: 4,
      ),
    );

    expect(api.lastBody, {
      'name': 'Navy',
      'code': 'NAVY',
      'hex_code': '#1E3A8A',
      'sort_order': 4,
      'is_active': true,
    });
    expect(api.lastOptions?.headers?['Prefer'], 'return=representation');
    expect(result.isRight(), isTrue);
  });

  test('a blank hex is sent as null', () async {
    await repository.createColor(
      const CatalogColorDraft(name: 'a', code: 'b', hexCode: '  '),
    );
    expect(api.lastBody?['hex_code'], isNull);
  });

  test('update targets the row by id', () async {
    await repository.updateColor(
      id: 7,
      draft: const CatalogColorDraft(name: 'a', code: 'b'),
    );
    expect(api.lastQueryParameters, {'id': 'eq.7'});
  });

  test('set active patches only is_active without a body back', () async {
    final result = await repository.setColorActive(id: 7, isActive: false);

    expect(api.lastQueryParameters, {'id': 'eq.7'});
    expect(api.lastBody, {'is_active': false});
    expect(api.lastOptions?.headers?['Prefer'], 'return=minimal');
    expect(result, const Right(unit));
  });

  test('maps a unique violation to a duplicate failure', () async {
    api.postFailure = ApiException.conflict(errorCode: '23505');
    final result = await repository.createColor(
      const CatalogColorDraft(name: 'a', code: 'b'),
    );
    result.fold(
      (failure) => expect(failure, isA<ColorDuplicateFailure>()),
      (_) => fail('Expected duplicate failure'),
    );
  });

  test('an update conflict is also a duplicate failure', () async {
    api.patchFailure = ApiException.conflict(errorCode: '23505');
    final result = await repository.updateColor(
      id: 7,
      draft: const CatalogColorDraft(name: 'a', code: 'b'),
    );
    expect(result.fold((f) => f, (_) => null), isA<ColorDuplicateFailure>());
  });

  test('maps deleting a referenced color to ColorInUseFailure', () async {
    api.deleteFailure = ApiException.conflict(errorCode: '23503');
    final result = await repository.deleteColor(7);
    expect(
      result.fold((failure) => failure, (_) => null),
      isA<ColorInUseFailure>(),
    );
    expect(api.lastPath, '/rest/v1/colors');
    expect(api.lastQueryParameters, {'id': 'eq.7'});
  });

  test('other conflicts are not reported as duplicates', () async {
    api.postFailure = ApiException.conflict(errorCode: '23503');
    final result = await repository.createColor(
      const CatalogColorDraft(name: 'a', code: 'b'),
    );
    expect(
      result.fold((f) => f, (_) => null),
      isNot(isA<ColorDuplicateFailure>()),
    );
  });
}
