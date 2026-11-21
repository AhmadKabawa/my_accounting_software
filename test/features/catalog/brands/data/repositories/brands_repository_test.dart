import 'dart:typed_data';

import 'package:dartz/dartz.dart';
import 'package:accounting_software/app/core/error/exceptions/api_exception.dart';
import 'package:accounting_software/app/core/error/failures/failure.dart';
import 'package:accounting_software/app/features/catalog/brands/data/datasources/brands_remote_data_source_impl.dart';
import 'package:accounting_software/app/features/catalog/brands/data/repositories/brands_repository_impl.dart';
import 'package:accounting_software/app/features/catalog/brands/domain/entity/brand_draft.dart';
import 'package:accounting_software/app/features/catalog/brands/domain/entity/brand_list_query.dart';
import 'package:accounting_software/app/features/catalog/brands/domain/entity/brand_logo_upload.dart';
import 'package:accounting_software/app/features/catalog/brands/domain/failures/brand_failures.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/fake_brands_api_client.dart';

void main() {
  late FakeBrandsApiClient api;
  late BrandsRepositoryImpl repository;

  setUp(() {
    api = FakeBrandsApiClient();
    repository = BrandsRepositoryImpl(BrandsRemoteDataSourceImpl(api));
  });

  test(
    'builds server-side search, status, sort and pagination query',
    () async {
      final result = await repository.getBrands(
        const BrandListQuery(
          search: 'North "Wind"',
          status: BrandStatusFilter.active,
          sortAscending: false,
          page: 2,
          pageSize: 50,
        ),
      );

      expect(api.lastPath, '/rest/v1/brands');
      expect(api.lastQueryParameters['select'], contains('products(count)'));
      expect(api.lastQueryParameters['order'], 'name.desc');
      expect(api.lastQueryParameters['is_active'], 'eq.true');
      expect(api.lastQueryParameters['or'], contains(r'North \"Wind\"'));
      expect(api.lastPage, 2);
      expect(api.lastLimit, 50);
      expect(result.isRight(), isTrue);
      result.fold((_) => fail('Expected brands page'), (page) {
        expect(page.items.single.id, 12);
        expect(page.items.single.productCount, 2);
      });
    },
  );

  test('creates a brand without sending the status column', () async {
    final result = await repository.createBrand(
      const BrandDraft(name: 'Northwind', slug: 'northwind'),
    );

    expect(api.lastBody, {
      'name': 'Northwind',
      'slug': 'northwind',
      'logo': null,
      'description': null,
    });
    expect(api.lastBody!.containsKey('is_active'), isFalse);
    expect(result.isRight(), isTrue);
  });

  test('updates only editable fields and scopes the patch by id', () async {
    final result = await repository.updateBrand(
      id: 12,
      draft: const BrandDraft(
        name: 'Northwind Trading',
        slug: 'northwind-trading',
      ),
    );

    expect(api.lastQueryParameters, {'id': 'eq.12'});
    expect(api.lastBody!.containsKey('is_active'), isFalse);
    expect(api.lastBody!['name'], 'Northwind Trading');
    expect(result.isRight(), isTrue);
  });

  test('maps forbidden writes to a permission failure', () async {
    api.postFailure = ApiException.forbidden();

    final result = await repository.createBrand(
      const BrandDraft(name: 'Northwind', slug: 'northwind'),
    );

    result.fold(
      (failure) => expect(failure, isA<PermissionFailure>()),
      (_) => fail('Expected permission failure'),
    );
  });

  test('status update sends only is_active', () async {
    final result = await repository.setBrandActive(id: 12, isActive: false);

    expect(api.lastQueryParameters, {'id': 'eq.12'});
    expect(api.lastBody, {'is_active': false});
    expect(result, const Right(unit));
  });

  test('maps a create conflict to a duplicate failure', () async {
    api.postFailure = ApiException.conflict();

    final result = await repository.createBrand(
      const BrandDraft(name: 'Northwind', slug: 'northwind'),
    );

    result.fold(
      (failure) => expect(failure, isA<BrandDuplicateFailure>()),
      (_) => fail('Expected duplicate failure'),
    );
  });

  test('maps a delete foreign-key conflict to an in-use failure', () async {
    api.deleteFailure = ApiException.conflict(errorCode: '23503');

    final result = await repository.deleteBrand(12);

    result.fold(
      (failure) => expect(failure, isA<BrandInUseFailure>()),
      (_) => fail('Expected in-use failure'),
    );
  });

  test(
    'does not treat every delete conflict as a foreign-key conflict',
    () async {
      api.deleteFailure = ApiException.conflict();

      final result = await repository.deleteBrand(12);

      result.fold((failure) {
        expect(failure, isNot(isA<BrandInUseFailure>()));
        expect(failure, isA<Failure>());
      }, (_) => fail('Expected conflict failure'));
    },
  );

  test(
    'uses the MIME type when an uploaded filename has no extension',
    () async {
      final result = await repository.uploadLogo(
        BrandLogoUpload(
          bytes: Uint8List.fromList([1, 2, 3]),
          fileName: 'brand-logo',
          mimeType: 'image/png',
        ),
      );

      expect(api.lastPath, endsWith('.png'));
      expect(result.isRight(), isTrue);
    },
  );

  test(
    'uploads a logo to the product-images bucket and returns its URL',
    () async {
      final bytes = Uint8List.fromList([1, 2, 3]);
      final result = await repository.uploadLogo(
        BrandLogoUpload(
          bytes: bytes,
          fileName: 'Logo.PNG',
          mimeType: 'image/png',
        ),
      );

      expect(
        api.lastPath,
        startsWith('/storage/v1/object/product-images/brands/'),
      );
      expect(api.lastPath, endsWith('.png'));
      expect(api.lastRawBody, bytes);
      expect(api.lastOptions?.headers?['Content-Type'], 'image/png');
      result.fold(
        (_) => fail('Expected a public URL'),
        (url) => expect(
          url,
          contains('/storage/v1/object/public/product-images/brands/'),
        ),
      );
    },
  );
}
