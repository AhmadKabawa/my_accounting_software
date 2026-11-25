import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:accounting_software/app/core/foundation/types/paginated_result.dart';
import 'package:accounting_software/app/core/error/exceptions/api_exception.dart';
import 'package:accounting_software/app/features/catalog/categories/data/models/category_model.dart';
import 'package:accounting_software/app/features/catalog/categories/data/repositories/categories_repository_impl.dart';
import 'package:accounting_software/app/features/catalog/categories/domain/entity/category_draft.dart';
import 'package:accounting_software/app/features/catalog/categories/domain/failures/category_failures.dart';

import '../support/fake_categories_remote_data_source.dart';

void main() {
  late FakeCategoriesRemoteDataSource remote;
  late CategoriesRepositoryImpl repository;

  setUp(() {
    remote = FakeCategoriesRemoteDataSource();
    repository = CategoriesRepositoryImpl(remote);
  });

  test('loads every page up to the 2000-category safety cap', () async {
    remote.pages[1] = PaginatedResult<CategoryModel>(
      items: [remote.model],
      totalCount: 1001,
      currentPage: 1,
      totalPages: 2,
    );
    remote.pages[2] = PaginatedResult<CategoryModel>(
      items: [remote.model.copyWithId(2)],
      totalCount: 1001,
      currentPage: 2,
      totalPages: 2,
    );

    final result = await repository.getAll();

    expect(result.isRight(), isTrue);
    expect(remote.requestedPages, [1, 2]);
    result.fold((_) => fail('Expected all category pages'), (items) {
      expect(items, hasLength(2));
      expect(items.map((item) => item.id), [1, 2]);
    });
  });

  test('refuses a tree larger than 2000 instead of truncating it', () async {
    remote.pages[1] = PaginatedResult<CategoryModel>(
      items: [remote.model],
      totalCount: 2001,
      currentPage: 1,
      totalPages: 3,
    );

    final result = await repository.getAll();

    expect(result.isLeft(), isTrue);
    expect(
      result.fold((failure) => failure, (_) => null),
      isA<CategoryTreeTooLargeFailure>(),
    );
    expect(remote.requestedPages, [1]);
  });

  test('maps SQLSTATE 23505 to duplicate slug failure', () async {
    remote.createFailure = ApiException.conflict(errorCode: '23505');

    final result = await repository.create(
      const CategoryDraft(name: 'Shoes', slug: 'shoes'),
    );

    expect(
      result.fold((failure) => failure, (_) => null),
      isA<CategorySlugTakenFailure>(),
    );
  });

  test('maps SQLSTATE 23503 to category in-use failure', () async {
    remote.deleteFailure = ApiException.conflict(errorCode: '23503');

    final result = await repository.delete(1);

    expect(
      result.fold((failure) => failure, (_) => null),
      isA<CategoryInUseFailure>(),
    );
  });

  test('does not map unrelated delete conflicts to in-use', () async {
    remote.deleteFailure = ApiException.conflict(errorCode: '23514');

    final result = await repository.delete(1);

    expect(result.isLeft(), isTrue);
    expect(
      result.fold((failure) => failure, (_) => null),
      isNot(isA<CategoryInUseFailure>()),
    );
  });
}

extension on CategoryModel {
  CategoryModel copyWithId(int id) => CategoryModel(
    id: id,
    parentId: parentId,
    name: name,
    slug: slug,
    description: description,
    image: image,
    sortOrder: sortOrder,
    isActive: isActive,
    productCount: productCount,
  );
}
