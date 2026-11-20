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
import 'package:accounting_software/app/features/catalog/presentation/pages/brands_screen.dart';
import 'package:accounting_software/app/core/presentation/design_system/theme/app_theme.dart';
import '../../helpers/localized_app.dart';
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
          setScreenSize(tester, Size(width, 900));
          final repository = FakeBrandsRepository();
          sl.registerFactory<BrandsListCubit>(
            () => BrandsListCubit(
              getBrands: GetBrandsUseCase(repository),
              setBrandActive: SetBrandActiveUseCase(repository),
              deleteBrand: DeleteBrandUseCase(repository),
            ),
          );
          addTearDown(() async => sl.reset());

          await tester.pumpWidget(
            MultiBlocProvider(
              providers: [
                BlocProvider<AccessCubit>(
                  create: (_) => AccessCubit(
                    getMyAccess: GetMyAccessUseCase(_NoopAccessRepository()),
                  ),
                ),
              ],
              child: buildTestApp(
                direction: direction,
                theme: dark ? AppTheme.dark() : AppTheme.light(),
                home: const Scaffold(body: BrandsScreen()),
              ),
            ),
          );
          await tester.pumpAndSettle();

          expect(tester.takeException(), isNull);
          expect(find.byType(BrandsScreen), findsOneWidget);
          expect(find.text('Brands'), findsOneWidget);
          expect(find.text('Total brands'), findsOneWidget);
          expect(find.text('Active brands'), findsOneWidget);
          expect(find.text('Inactive brands'), findsOneWidget);
          expect(find.text('Brand deleted'), findsNothing);
        });
      }
    }
  }
}
