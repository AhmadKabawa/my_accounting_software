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
import 'package:accounting_software/app/core/error/failures/failure.dart'
    show ValidationFailure;
import 'package:accounting_software/app/core/presentation/widgets/app_message/flash_messages.dart';
import 'package:accounting_software/app/core/storage/shared_preferences/app_settings_manager.dart';
import 'package:accounting_software/app/features/catalog/attributes/domain/usecase/get_attributes_use_case.dart';
import 'package:accounting_software/app/features/catalog/attributes/domain/usecase/get_attribute_stats_use_case.dart';
import 'package:accounting_software/app/features/catalog/attributes/domain/usecase/set_attribute_active_use_case.dart';
import 'package:accounting_software/app/features/catalog/attributes/domain/usecase/delete_attribute_use_case.dart';
import 'package:accounting_software/app/features/catalog/attributes/domain/usecase/create_attribute_use_case.dart';
import 'package:accounting_software/app/features/catalog/attributes/domain/usecase/update_attribute_use_case.dart';
import 'package:accounting_software/app/features/catalog/attributes/domain/usecase/get_attribute_unit_choices_use_case.dart';
import 'package:accounting_software/app/features/catalog/attributes/domain/usecase/get_attribute_option_set_choices_use_case.dart';
import 'package:accounting_software/app/features/catalog/attributes/presentation/cubit/attributes_list/attributes_list_cubit.dart';
import 'package:accounting_software/app/features/catalog/attributes/presentation/cubit/attribute_stats/attribute_stats_cubit.dart';
import 'package:accounting_software/app/features/catalog/attributes/presentation/cubit/attribute_form/attribute_form_cubit.dart';
import 'package:accounting_software/app/features/catalog/attributes/presentation/cubit/attribute_lookups/attribute_lookups_cubit.dart';
import 'package:accounting_software/app/features/catalog/attributes/presentation/pages/attributes_screen.dart';
import 'package:accounting_software/app/features/catalog/attributes/presentation/localization/attributes_keys.dart';
import '../../../../helpers/localized_app.dart';
import '../../../../helpers/memory_storage.dart';
import '../../../../helpers/screen_matrix.dart';
import '../support/fake_attributes_repository.dart';

class _AccessRepository implements AccessRepository {
  @override
  Future<Either<Failure, AccessSnapshot>> getMyAccess() async => const Right(
    AccessSnapshot(
      userId: 'test',
      username: 'test',
      email: null,
      isSuperAdmin: false,
      roles: [],
      permissions: {},
      branches: [],
      warehouses: [],
      posTerminals: [],
    ),
  );
}

void main() {
  setUpAll(() => useTranslations(const Locale('en')));
  for (final width in [280.0, 360.0, 600.0, 900.0, 1200.0]) {
    for (final direction in [TextDirection.ltr, TextDirection.rtl]) {
      for (final dark in [false, true]) {
        testWidgets('attributes screen renders $width $direction dark=$dark', (
          tester,
        ) async {
          final repository = FakeAttributesRepository()
            ..statsResult = const Left(
              ValidationFailure(messageKey: AttributesKeys.loadError),
            );
          sl.registerFactory<FlashMessages>(FlashMessages.new);
          sl.registerSingleton<AppSettingsManager>(
            AppSettingsManager(storage: MemoryStorage()),
          );
          sl.registerFactory<AttributesListCubit>(
            () => AttributesListCubit(
              getAttributes: GetAttributesUseCase(repository),
              setActive: SetAttributeActiveUseCase(repository),
              deleteAttribute: DeleteAttributeUseCase(repository),
              flashMessages: sl(),
            ),
          );
          sl.registerFactory<AttributeStatsCubit>(
            () => AttributeStatsCubit(
              getStats: GetAttributeStatsUseCase(repository),
            ),
          );
          sl.registerFactory<AttributeFormCubit>(
            () => AttributeFormCubit(
              createAttribute: CreateAttributeUseCase(repository),
              updateAttribute: UpdateAttributeUseCase(repository),
              flashMessages: sl(),
            ),
          );
          sl.registerFactory<AttributeLookupsCubit>(
            () => AttributeLookupsCubit(
              getUnits: GetAttributeUnitChoicesUseCase(repository),
              getOptionSets: GetAttributeOptionSetChoicesUseCase(repository),
            ),
          );
          addTearDown(() async => sl.reset());
          await pumpScreenMatrix(
            tester,
            width: width,
            direction: direction,
            dark: dark,
            textScale: width == 280 ? 1.5 : 1,
            home: Scaffold(
              body: BlocProvider<AccessCubit>(
                create: (_) => AccessCubit(
                  getMyAccess: GetMyAccessUseCase(_AccessRepository()),
                )..load(),
                child: const AttributesScreen(),
              ),
            ),
          );
          expect(find.byType(AttributesScreen), findsOneWidget);
          expect(find.text('Material'), findsOneWidget);
          expect(tester.takeException(), isNull);
        });
      }
    }
  }
}
