import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:accounting_software/app/core/access/cubit/access_cubit.dart';
import 'package:accounting_software/app/core/access/domain/access_repository.dart';
import 'package:accounting_software/app/core/access/domain/get_my_access_usecase.dart';
import 'package:accounting_software/app/core/access/models/access_snapshot.dart';
import 'package:accounting_software/app/core/di/service_locator.dart';
import 'package:accounting_software/app/core/error/failures/failure.dart';
import 'package:accounting_software/app/features/catalog/domain/usecase/delete_brand_use_case.dart';
import 'package:accounting_software/app/features/catalog/domain/usecase/get_brands_use_case.dart';
import 'package:accounting_software/app/features/catalog/domain/usecase/set_brand_active_use_case.dart';
import 'package:accounting_software/app/features/catalog/presentation/cubit/brands_list_cubit.dart';
import 'package:accounting_software/app/features/catalog/presentation/cubit/brand_stats_cubit.dart';
import 'package:accounting_software/app/features/catalog/presentation/pages/brands/brands_screen.dart';
import '../../helpers/localized_app.dart';
import '../../helpers/screen_matrix.dart';
import 'support/fake_brands_repository.dart';

class _NoopAccessRepository implements AccessRepository {
  @override
  Future<Either<Failure, AccessSnapshot>> getMyAccess() =>
      throw UnimplementedError();
}

void main() {
  setUpAll(() => useTranslations(const Locale('en')));

  for (final width in [360.0, 600.0, 900.0, 1200.0]) {
    for (final direction in [TextDirection.ltr, TextDirection.rtl]) {
      for (final dark in [false, true]) {
        testWidgets('brands page renders at $width, $direction, dark=$dark', (
          tester,
        ) async {
          final repository = FakeBrandsRepository();
          sl.registerFactory<BrandStatsCubit>(
            () => BrandStatsCubit(getBrands: GetBrandsUseCase(repository)),
          );
          sl.registerFactory<BrandsListCubit>(
            () => BrandsListCubit(
              getBrands: GetBrandsUseCase(repository),
              setBrandActive: SetBrandActiveUseCase(repository),
              deleteBrand: DeleteBrandUseCase(repository),
            ),
          );
          addTearDown(() async => sl.reset());

          await pumpScreenMatrix(
            tester,
            width: width,
            direction: direction,
            dark: dark,
            home: const Scaffold(body: BrandsScreen()),
          );

            expect(find.byType(BrandsScreen), findsOneWidget);
            // Breadcrumb + page title both show "Brands".
            expect(find.text('Brands'), findsWidgets);
            expect(find.textContaining('Total brands'), findsOneWidget);
            expect(find.textContaining('Active brands'), findsOneWidget);
            expect(find.textContaining('Inactive brands'), findsOneWidget);
            // No unresolved placeholders anywhere on the page.
            expect(find.textContaining('{'), findsNothing);
            expect(find.textContaining('@'), findsNothing);
            // Record actions are icons (AppRowActions), never text buttons.
            expect(find.text('Edit brand'), findsNothing);
            expect(find.text('Brand deleted'), findsNothing);
          },
        );
      }
    }
  }
}
