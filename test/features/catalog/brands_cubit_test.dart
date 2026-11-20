import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:accounting_software/app/core/foundation/types/paginated_result.dart';
import 'package:accounting_software/app/features/catalog/domain/entities/brand.dart';
import 'package:accounting_software/app/features/catalog/domain/entities/brand_draft.dart';
import 'package:accounting_software/app/features/catalog/domain/entities/brand_list_query.dart';
import 'package:accounting_software/app/features/catalog/domain/usecases/create_brand_use_case.dart';
import 'package:accounting_software/app/features/catalog/domain/usecases/delete_brand_use_case.dart';
import 'package:accounting_software/app/features/catalog/domain/usecases/get_brands_use_case.dart';
import 'package:accounting_software/app/features/catalog/domain/usecases/set_brand_active_use_case.dart';
import 'package:accounting_software/app/features/catalog/domain/usecases/update_brand_use_case.dart';
import 'package:accounting_software/app/features/catalog/presentation/cubit/brand_form_cubit.dart';
import 'package:accounting_software/app/features/catalog/presentation/cubit/brands_list_cubit.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/fake_brands_repository.dart';

void main() {
  test('latest debounced search wins over an older in-flight request', () async {
    final repository = FakeBrandsRepository();
    final requests = <Completer<Either<dynamic, PaginatedResult<Brand>>>>[];
    repository.onGetBrands = (_) {
      final completer = Completer<Either<dynamic, PaginatedResult<Brand>>>();
      requests.add(completer);
      return completer.future;
    };
    final cubit = BrandsListCubit(
      getBrands: GetBrandsUseCase(repository),
      setBrandActive: SetBrandActiveUseCase(repository),
      deleteBrand: DeleteBrandUseCase(repository),
    );

    final firstRequest = cubit.load();
    expect(requests, hasLength(1));

    cubit.searchChanged('newest');
    await Future<void>.delayed(const Duration(milliseconds: 350));
    expect(requests, hasLength(2));
    expect(repository.queries.last.search, 'newest');

    requests[1].complete(const Right(PaginatedResult<Brand>(
      items: [Brand(id: 2, name: 'Newest', slug: 'newest', isActive: true)],
      totalCount: 1,
      currentPage: 1,
      totalPages: 1,
    )));
    await Future<void>.delayed(Duration.zero);

    requests[0].complete(const Right(PaginatedResult<Brand>(
      items: [Brand(id: 1, name: 'Old', slug: 'old', isActive: true)],
      totalCount: 1,
      currentPage: 1,
      totalPages: 1,
    )));
    await firstRequest;

    expect(cubit.state, isA<BrandsListReady>());
    expect((cubit.state as BrandsListReady).result.items.single.name, 'Newest');
    await cubit.close();
  });

  test('form cubit saves through repository use cases without page dependency', () async {
    final repository = FakeBrandsRepository();
    final cubit = BrandFormCubit(
      createBrand: CreateBrandUseCase(repository),
      updateBrand: UpdateBrandUseCase(repository),
    );

    final result = await cubit.save(
      draft: const BrandDraft(name: 'Northwind', slug: 'northwind'),
    );

    expect(result.isRight(), isTrue);
    expect(cubit.state, isA<BrandFormSaved>());
    expect((cubit.state as BrandFormSaved).brand.id, 12);
    await cubit.close();
  });
}
