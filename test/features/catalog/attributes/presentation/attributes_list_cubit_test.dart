import 'dart:async';
import 'package:dartz/dartz.dart';
import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:accounting_software/app/core/error/failures/failure.dart';
import 'package:accounting_software/app/core/foundation/types/paginated_result.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_message/flash_messages.dart';
import 'package:accounting_software/app/features/catalog/attributes/domain/entity/attribute_list_query.dart';
import 'package:accounting_software/app/features/catalog/attributes/domain/entity/catalog_attribute.dart';
import 'package:accounting_software/app/features/catalog/attributes/domain/usecase/get_attributes_use_case.dart';
import 'package:accounting_software/app/features/catalog/attributes/domain/usecase/set_attribute_active_use_case.dart';
import 'package:accounting_software/app/features/catalog/attributes/domain/usecase/delete_attribute_use_case.dart';
import 'package:accounting_software/app/features/catalog/attributes/presentation/cubit/attributes_list/attributes_list_cubit.dart';
import '../support/fake_attributes_repository.dart';

void main() {
  test('search is debounced for 300ms', () {
    fakeAsync((async) {
      final repository = FakeAttributesRepository();
      final cubit = _cubit(repository);
      cubit.searchChanged('material');
      expect(cubit.state.query.search, 'material');
      expect(repository.queries, isEmpty);
      async.elapse(const Duration(milliseconds: 299));
      expect(repository.queries, isEmpty);
      async.elapse(const Duration(milliseconds: 1));
      async.flushMicrotasks();
      expect(repository.queries, hasLength(1));
      expect(repository.queries.single.search, 'material');
      cubit.close();
      async.flushMicrotasks();
    });
  });

  test('status, type and filterable filters reset page to one', () async {
    final repository = FakeAttributesRepository();
    final cubit = _cubit(repository);
    addTearDown(cubit.close);
    await cubit.load();
    await cubit.setPage(3);
    await cubit.setStatus(AttributeStatusFilter.active);
    expect(cubit.state.query.page, 1);
    expect(repository.queries.last.status, AttributeStatusFilter.active);
    await cubit.setPage(2);
    await cubit.setDataType(AttributeDataType.number);
    expect(cubit.state.query.page, 1);
    expect(repository.queries.last.dataType, AttributeDataType.number);
    await cubit.setPage(2);
    await cubit.setFilterable(AttributeFilterableFilter.filterable);
    expect(cubit.state.query.page, 1);
    expect(
      repository.queries.last.filterable,
      AttributeFilterableFilter.filterable,
    );
  });

  test('latest request wins over older in-flight response', () async {
    final repository = FakeAttributesRepository();
    final pending =
        <Completer<Either<Failure, PaginatedResult<CatalogAttribute>>>>[];
    repository.onGet = (_) {
      final request =
          Completer<Either<Failure, PaginatedResult<CatalogAttribute>>>();
      pending.add(request);
      return request.future;
    };
    final cubit = _cubit(repository);
    final first = cubit.load();
    final second = cubit.setStatus(AttributeStatusFilter.active);
    pending[1].complete(Right(_page('Latest')));
    await second;
    pending[0].complete(Right(_page('Old')));
    await first;
    expect(cubit.state.result!.items.single.name, 'Latest');
    await cubit.close();
  });

  test(
    'unknown or positive usage blocks delete before repository call',
    () async {
      final repository = FakeAttributesRepository();
      final cubit = _cubit(repository);
      final unknown = _attribute(links: null, values: 0);
      final result = await cubit.delete(unknown);
      expect(result.isLeft(), isTrue);
      expect(repository.deletedIds, isEmpty);
      await cubit.close();
    },
  );
}

AttributesListCubit _cubit(FakeAttributesRepository repository) =>
    AttributesListCubit(
      getAttributes: GetAttributesUseCase(repository),
      setActive: SetAttributeActiveUseCase(repository),
      deleteAttribute: DeleteAttributeUseCase(repository),
      flashMessages: FlashMessages(),
    );

PaginatedResult<CatalogAttribute> _page(String name) =>
    PaginatedResult<CatalogAttribute>(
      items: [_attribute(name: name)],
      totalCount: 1,
      currentPage: 1,
      totalPages: 1,
    );
CatalogAttribute _attribute({
  String name = 'Material',
  int? links = 0,
  int? values = 0,
}) => CatalogAttribute(
  id: 7,
  name: name,
  code: 'MATERIAL',
  dataType: AttributeDataType.text,
  unitId: null,
  unitName: null,
  unitSymbol: null,
  optionSetId: null,
  optionSetName: null,
  optionSetCode: null,
  isFilterable: true,
  isActive: true,
  linkedProductTypesCount: links,
  valueCount: values,
);
