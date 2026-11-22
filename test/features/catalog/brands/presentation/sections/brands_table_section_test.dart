import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:accounting_software/app/core/access/cubit/access_cubit.dart';
import 'package:accounting_software/app/core/access/domain/access_repository.dart';
import 'package:accounting_software/app/core/access/domain/get_my_access_usecase.dart';
import 'package:accounting_software/app/core/access/models/access_snapshot.dart';
import 'package:accounting_software/app/core/access/permissions.dart';
import 'package:accounting_software/app/core/error/failures/failure.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_empty_state/app_empty_state.dart';
import 'package:accounting_software/app/features/catalog/brands/domain/entity/brand.dart';
import 'package:accounting_software/app/features/catalog/brands/domain/entity/brand_list_query.dart';
import 'package:accounting_software/app/features/catalog/brands/presentation/localization/brands_keys.dart';
import 'package:accounting_software/app/features/catalog/brands/presentation/sections/brands_table_section.dart';
import '../../../../../helpers/localized_app.dart';

const _brand = Brand(
  id: 12,
  name: 'Northwind',
  slug: 'northwind',
  isActive: true,
  productCount: 2,
);

Widget _section({
  BrandListQuery query = const BrandListQuery(),
  List<Brand> rows = const [_brand],
  int total = 1,
}) => BrandsTableSection(
  query: query,
  onRetry: () {},
  onSort: (_) {},
  onPageChanged: (_) {},
  rows: rows,
  total: total,
  loading: false,
  failure: null,
  onAdd: () {},
  onEdit: (_) {},
  onDelete: (_) {},
  onToggleStatus: (_) {},
);

class _AccessRepository implements AccessRepository {
  @override
  Future<Either<Failure, AccessSnapshot>> getMyAccess() async => Right(
    AccessSnapshot(
      userId: 'test-user',
      username: 'test',
      email: null,
      isSuperAdmin: false,
      roles: [],
      permissions: {Permissions.masterData.manage},
      branches: [],
      warehouses: [],
      posTerminals: [],
    ),
  );
}

Widget _withAccess(Widget child) => BlocProvider<AccessCubit>(
  create: (_) =>
      AccessCubit(getMyAccess: GetMyAccessUseCase(_AccessRepository()))
        ..load(),
  child: Scaffold(body: child),
);

void main() {
  setUpAll(() => useTranslations(const Locale('en')));

  testWidgets(
    'table retains the products column and its existing count badge',
    (tester) async {
    tester.view.physicalSize = const Size(1280, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(buildTestApp(home: _withAccess(_section())));

    expect(find.text(BrandsKeys.productCount.en), findsOneWidget);
    expect(find.text('Products: 2'), findsOneWidget);
  });

  testWidgets('empty brands uses its dedicated AppEmptyState', (tester) async {
    await tester.pumpWidget(
      buildTestApp(
        home: _withAccess(_section(rows: const [], total: 0)),
      ),
    );

    expect(find.byType(AppEmptyState), findsOneWidget);
    expect(find.text(BrandsKeys.empty.en), findsOneWidget);
  });

  testWidgets('filtered empty result uses its dedicated AppEmptyState', (
    tester,
  ) async {
    await tester.pumpWidget(
      buildTestApp(
        home: _withAccess(
          _section(
            query: const BrandListQuery(search: 'missing'),
            rows: const [],
            total: 0,
          ),
        ),
      ),
    );

    expect(find.byType(AppEmptyState), findsOneWidget);
    expect(find.text(BrandsKeys.noResults.en), findsOneWidget);
  });
}
