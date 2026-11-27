import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:accounting_software/app/core/error/failures/failure.dart';
import 'package:accounting_software/app/core/foundation/types/paginated_result.dart';
import 'package:accounting_software/app/core/presentation/state_management/paged_list/paged_list_state.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_message/flash_messages.dart';
import 'package:accounting_software/app/features/catalog/product_types/domain/entity/product_type.dart';
import 'package:accounting_software/app/features/catalog/product_types/domain/entity/product_type_draft.dart';
import 'package:accounting_software/app/features/catalog/product_types/domain/entity/product_type_list_query.dart';
import 'package:accounting_software/app/features/catalog/product_types/domain/repositories/product_types_repository.dart';
import 'package:accounting_software/app/features/catalog/product_types/presentation/cubit/product_types_list/product_types_list_cubit.dart';

void main() {
  late _FakeProductTypesRepository repository;
  late ProductTypesListCubit cubit;

  setUp(() {
    repository = _FakeProductTypesRepository();
    cubit = ProductTypesListCubit(
      repository: repository,
      flashMessages: FlashMessages(),
    );
  });

  tearDown(() async => cubit.close());

  test('loads an empty page successfully', () async {
    repository.result = Right(_page(const []));

    await cubit.load();

    expect(cubit.state.status, PagedListStatus.ready);
    expect(cubit.state.result?.items, isEmpty);
    expect(cubit.state.failure, isNull);
  });

  test('retains a failed state when the repository fails', () async {
    repository.result = const Left(ServerFailure());

    await cubit.load();

    expect(cubit.state.status, PagedListStatus.failed);
    expect(cubit.state.failure, isA<ServerFailure>());
  });

  test('status filter updates the server query', () async {
    repository.result = Right(_page([_type(1)]));

    await cubit.setStatus(ProductTypeStatusFilter.active);

    expect(repository.queries.last.status, ProductTypeStatusFilter.active);
    expect(repository.queries.last.page, 1);
    expect(cubit.state.status, PagedListStatus.ready);
  });

  test('debounce keeps only the last search and latest request wins', () async {
    final first = Completer<Either<Failure, PaginatedResult<ProductType>>>();
    final second = Completer<Either<Failure, PaginatedResult<ProductType>>>();
    repository.pending.addAll([first, second]);

    cubit.searchChanged('shoe');
    await Future<void>.delayed(const Duration(milliseconds: 350));
    cubit.searchChanged('boot');
    await Future<void>.delayed(const Duration(milliseconds: 350));

    expect(repository.queries.map((query) => query.search), ['shoe', 'boot']);

    second.complete(Right(_page([_type(2, name: 'Boots')])));
    await Future<void>.delayed(Duration.zero);
    first.complete(Right(_page([_type(1, name: 'Shoes')])));
    await Future<void>.delayed(Duration.zero);

    expect(cubit.state.result?.items.single.name, 'Boots');
  });

  test(
    'delete is rejected for unknown or linked usage before API call',
    () async {
      final unknown = _type(1, products: null);
      final linked = _type(2, products: 1);

      final unknownResult = await cubit.delete(unknown);
      final linkedResult = await cubit.delete(linked);

      expect(unknownResult.isLeft(), isTrue);
      expect(linkedResult.isLeft(), isTrue);
      expect(repository.deleteCalls, 0);
    },
  );
}

PaginatedResult<ProductType> _page(List<ProductType> items) => PaginatedResult(
  items: items,
  totalCount: items.length,
  currentPage: 1,
  totalPages: 1,
);

ProductType _type(int id, {String name = 'Shoes', int? products = 0}) =>
    ProductType(
      id: id,
      name: name,
      code: 'TYPE$id',
      sortOrder: 0,
      isActive: true,
      productCount: products,
      sizeGroupCount: 0,
      attributeCount: 0,
      optionSetCount: 0,
      careInstructionCount: 0,
    );

class _FakeProductTypesRepository implements ProductTypesRepository {
  Either<Failure, PaginatedResult<ProductType>> result = Right(_page(const []));
  final List<ProductTypeListQuery> queries = [];
  final List<Completer<Either<Failure, PaginatedResult<ProductType>>>> pending =
      [];
  int deleteCalls = 0;

  @override
  Future<Either<Failure, PaginatedResult<ProductType>>> getPage(
    ProductTypeListQuery query,
  ) {
    queries.add(query);
    if (pending.isNotEmpty) return pending.removeAt(0).future;
    return Future.value(result);
  }

  @override
  Future<Either<Failure, ProductType>> getById(int id) async =>
      Right(_type(id));

  @override
  Future<Either<Failure, ProductType>> create(ProductTypeDraft draft) async =>
      Right(_type(10));

  @override
  Future<Either<Failure, ProductType>> update({
    required int id,
    required ProductTypeDraft draft,
  }) async => Right(_type(id));

  @override
  Future<Either<Failure, Unit>> setActive({
    required int id,
    required bool isActive,
  }) async => const Right(unit);

  @override
  Future<Either<Failure, Unit>> delete(int id) async {
    deleteCalls++;
    return const Right(unit);
  }
}
