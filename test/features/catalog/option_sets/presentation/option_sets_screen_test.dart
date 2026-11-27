import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:accounting_software/app/core/access/cubit/access_cubit.dart';
import 'package:accounting_software/app/core/access/domain/access_repository.dart';
import 'package:accounting_software/app/core/access/domain/get_my_access_usecase.dart';
import 'package:accounting_software/app/core/access/models/access_snapshot.dart';
import 'package:accounting_software/app/core/access/permissions.dart';
import 'package:accounting_software/app/core/di/service_locator.dart';
import 'package:accounting_software/app/core/error/failures/failure.dart';
import 'package:accounting_software/app/core/foundation/types/paginated_result.dart';
import 'package:accounting_software/app/core/localization/keys/catalog_ui_keys.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_message/flash_messages.dart';
import 'package:accounting_software/app/core/storage/shared_preferences/app_settings_manager.dart';
import 'package:accounting_software/app/core/storage/storage_key.dart';
import 'package:accounting_software/app/core/storage/storage_service.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_searchable_dropdown/searchable_dropdown.dart';
import 'package:accounting_software/app/features/catalog/option_sets/domain/entity/option_set.dart';
import 'package:accounting_software/app/features/catalog/option_sets/domain/entity/option_set_draft.dart';
import 'package:accounting_software/app/features/catalog/option_sets/domain/entity/option_set_list_query.dart';
import 'package:accounting_software/app/features/catalog/option_sets/domain/entity/option_set_stats.dart';
import 'package:accounting_software/app/features/catalog/option_sets/domain/repositories/option_sets_repository.dart';
import 'package:accounting_software/app/features/catalog/option_sets/domain/usecase/create_option_use_case.dart';
import 'package:accounting_software/app/features/catalog/option_sets/domain/usecase/create_option_set_use_case.dart';
import 'package:accounting_software/app/features/catalog/option_sets/domain/usecase/delete_option_set_use_case.dart';
import 'package:accounting_software/app/features/catalog/option_sets/domain/usecase/get_option_set_stats_use_case.dart';
import 'package:accounting_software/app/features/catalog/option_sets/domain/usecase/get_option_sets_use_case.dart';
import 'package:accounting_software/app/features/catalog/option_sets/domain/usecase/get_options_use_case.dart';
import 'package:accounting_software/app/features/catalog/option_sets/domain/usecase/set_option_active_use_case.dart';
import 'package:accounting_software/app/features/catalog/option_sets/domain/usecase/set_option_set_active_use_case.dart';
import 'package:accounting_software/app/features/catalog/option_sets/domain/usecase/update_option_use_case.dart';
import 'package:accounting_software/app/features/catalog/option_sets/domain/usecase/update_option_set_use_case.dart';
import 'package:accounting_software/app/features/catalog/option_sets/presentation/cubit/option_set_form/option_set_form_cubit.dart';
import 'package:accounting_software/app/features/catalog/option_sets/presentation/cubit/option_set_options/option_set_options_cubit.dart';
import 'package:accounting_software/app/features/catalog/option_sets/presentation/cubit/option_set_stats/option_set_stats_cubit.dart';
import 'package:accounting_software/app/features/catalog/option_sets/presentation/cubit/option_sets_list/option_sets_list_cubit.dart';
import 'package:accounting_software/app/features/catalog/option_sets/presentation/localization/option_sets_keys.dart';
import 'package:accounting_software/app/features/catalog/option_sets/presentation/pages/option_sets_screen.dart';
import '../../../../helpers/localized_app.dart';
import '../../../../helpers/screen_matrix.dart';

class _AccessRepository implements AccessRepository {
  _AccessRepository({required this.canManage});
  final bool canManage;

  @override
  Future<Either<Failure, AccessSnapshot>> getMyAccess() async => Right(
    AccessSnapshot(
      userId: 'test-user',
      username: 'test',
      email: null,
      isSuperAdmin: false,
      roles: [],
      permissions: {if (canManage) Permissions.masterData.manage},
      branches: [],
      warehouses: [],
      posTerminals: [],
    ),
  );
}

class _MemoryStorage implements StorageService {
  final Map<StorageKey, Object?> values = {};

  @override
  Future<void> write<T>(StorageKey key, T value) async => values[key] = value;

  @override
  Future<T?> read<T>(StorageKey key) async => values[key] as T?;

  @override
  Future<void> delete(StorageKey key) async => values.remove(key);

  @override
  Future<void> clearAll() async => values.clear();

  @override
  Future<bool> containsKey(StorageKey key) async => values.containsKey(key);
}

class _FakeOptionSetsRepository implements OptionSetsRepository {
  _FakeOptionSetsRepository({int usageCount = 1, int optionCount = 1})
    : optionSet = OptionSet(
        id: 12,
        name: 'Size',
        code: 'SIZE',
        selectionType: OptionSelectionType.single,
        isActive: true,
        options: const [],
        usageCount: usageCount,
        optionCount: optionCount,
      );

  final OptionSet optionSet;
  final List<OptionSetListQuery> queries = [];
  final List<CatalogOption> options = [
    const CatalogOption(
      id: 41,
      name: 'Small',
      code: 'S',
      sortOrder: 1,
      isActive: true,
    ),
  ];
  final List<CatalogOptionDraft> createdOptions = [];
  final List<CatalogOptionDraft> updatedOptions = [];
  final List<int> updatedOptionIds = [];
  final List<(int, bool)> activeChanges = [];
  int getOptionsCalls = 0;
  int createSetCalls = 0;
  int updateSetCalls = 0;

  @override
  Future<Either<Failure, OptionSetStats>> getOptionSetStats() async =>
      const Right(OptionSetStats(total: 1, active: 1, inactive: 0));

  @override
  Future<Either<Failure, PaginatedResult<OptionSet>>> getOptionSets(
    OptionSetListQuery query,
  ) async {
    queries.add(query);
    return Right(
      PaginatedResult(
        items: [optionSet],
        totalCount: 1,
        currentPage: query.page,
        totalPages: 1,
      ),
    );
  }

  @override
  Future<Either<Failure, List<CatalogOption>>> getOptions({
    required int optionSetId,
    String search = '',
  }) async {
    getOptionsCalls++;
    return Right(List.unmodifiable(options));
  }

  @override
  Future<Either<Failure, OptionSet>> createOptionSet(
    OptionSetDraft draft,
  ) async {
    createSetCalls++;
    return Right(optionSet);
  }

  @override
  Future<Either<Failure, OptionSet>> updateOptionSet({
    required int id,
    required OptionSetDraft draft,
  }) async {
    updateSetCalls++;
    return Right(optionSet);
  }

  @override
  Future<Either<Failure, Unit>> deleteOptionSet(int id) async =>
      const Right(unit);

  @override
  Future<Either<Failure, Unit>> setOptionSetActive({
    required int id,
    required bool isActive,
  }) async => const Right(unit);

  @override
  Future<Either<Failure, Unit>> createOption({
    required int optionSetId,
    required CatalogOptionDraft draft,
  }) async {
    createdOptions.add(draft);
    options.add(
      CatalogOption(
        id: 42,
        name: draft.name,
        code: draft.code,
        sortOrder: draft.sortOrder,
        isActive: draft.isActive ?? true,
      ),
    );
    return const Right(unit);
  }

  @override
  Future<Either<Failure, Unit>> updateOption({
    required int optionId,
    required CatalogOptionDraft draft,
  }) async {
    updatedOptionIds.add(optionId);
    updatedOptions.add(draft);
    final index = options.indexWhere((option) => option.id == optionId);
    if (index >= 0) {
      options[index] = CatalogOption(
        id: optionId,
        name: draft.name,
        code: draft.code,
        sortOrder: draft.sortOrder,
        isActive: options[index].isActive,
      );
    }
    return const Right(unit);
  }

  @override
  Future<Either<Failure, Unit>> setOptionActive({
    required int optionId,
    required bool isActive,
  }) async {
    activeChanges.add((optionId, isActive));
    final index = options.indexWhere((option) => option.id == optionId);
    if (index >= 0) {
      final current = options[index];
      options[index] = CatalogOption(
        id: current.id,
        name: current.name,
        code: current.code,
        sortOrder: current.sortOrder,
        isActive: isActive,
      );
    }
    return const Right(unit);
  }
}

void _register(_FakeOptionSetsRepository repository) {
  sl.registerFactory<AppSettingsManager>(
    () => AppSettingsManager(storage: _MemoryStorage()),
  );
  sl.registerFactory<FlashMessages>(FlashMessages.new);
  sl.registerFactory<OptionSetsListCubit>(
    () => OptionSetsListCubit(
      getOptionSets: GetOptionSetsUseCase(repository),
      setActive: SetOptionSetActiveUseCase(repository),
      deleteOptionSet: DeleteOptionSetUseCase(repository),
      flashMessages: sl<FlashMessages>(),
    ),
  );
  sl.registerFactory<OptionSetStatsCubit>(
    () => OptionSetStatsCubit(getStats: GetOptionSetStatsUseCase(repository)),
  );
  sl.registerFactory<OptionSetFormCubit>(
    () => OptionSetFormCubit(
      create: CreateOptionSetUseCase(repository),
      update: UpdateOptionSetUseCase(repository),
      flashMessages: sl<FlashMessages>(),
    ),
  );
  sl.registerFactory<OptionSetOptionsCubit>(
    () => OptionSetOptionsCubit(
      getOptions: GetOptionsUseCase(repository),
      createOption: CreateOptionUseCase(repository),
      updateOption: UpdateOptionUseCase(repository),
      setOptionActive: SetOptionActiveUseCase(repository),
    ),
  );
  addTearDown(() async => sl.reset());
}

Widget _home() => BlocProvider<AccessCubit>(
  create: (_) => AccessCubit(
    getMyAccess: GetMyAccessUseCase(_AccessRepository(canManage: true)),
  )..load(),
  child: const Scaffold(body: OptionSetsScreen()),
);

void main() {
  setUpAll(() => useTranslations(const Locale('en')));

  for (final width in [360.0, 600.0, 900.0, 1200.0]) {
    for (final direction in [TextDirection.ltr, TextDirection.rtl]) {
      for (final dark in [false, true]) {
        testWidgets(
          'option sets workflows render at $width, $direction, dark=$dark',
          (tester) async {
            final repository = _FakeOptionSetsRepository();
            _register(repository);
            await pumpScreenMatrix(
              tester,
              width: width,
              direction: direction,
              dark: dark,
              home: _home(),
            );

            expect(find.text('Size'), findsOneWidget);
            expect(tester.takeException(), isNull);

            await tester.tap(find.text(OptionSetsKeys.add.en).first);
            await tester.pumpAndSettle();
            expect(find.text(OptionSetsKeys.selectionType.en), findsOneWidget);
            expect(tester.takeException(), isNull);
            await tester.tap(find.text(OptionSetsKeys.cancel.en).last);
            await tester.pumpAndSettle();

            await tester.tap(
              find.byTooltip(CatalogUiKeys.moreActions.en).first,
            );
            await tester.pumpAndSettle();
            await tester.tap(find.text(OptionSetsKeys.edit.en).last);
            await tester.pumpAndSettle();
            expect(find.text(OptionSetsKeys.locked.en), findsOneWidget);
            final selection = tester
                .widget<SearchableDropdown<OptionSelectionType>>(
                  find.byType(SearchableDropdown<OptionSelectionType>),
                );
            expect(selection.enabled, isFalse);
            await tester.tap(find.text(OptionSetsKeys.cancel.en).last);
            await tester.pumpAndSettle();

            await tester.tap(find.text('Size').first);
            await tester.pumpAndSettle();
            expect(repository.getOptionsCalls, 1);
            expect(find.text('Small'), findsOneWidget);

            await tester.tap(find.text(OptionSetsKeys.addOption.en));
            await tester.pumpAndSettle();
            var fields = find.byType(TextFormField);
            expect(fields, findsNWidgets(3));
            await tester.enterText(fields.at(0), 'Large');
            await tester.enterText(fields.at(1), 'L');
            await tester.enterText(fields.at(2), '2');
            await tester.tap(find.text(OptionSetsKeys.save.en).last);
            await tester.pumpAndSettle();
            expect(repository.createdOptions.single.name, 'Large');

            await tester.tap(
              find.byTooltip(OptionSetsKeys.editOption.en).first,
            );
            await tester.pumpAndSettle();
            fields = find.byType(TextFormField);
            await tester.enterText(fields.at(0), 'Small updated');
            await tester.enterText(fields.at(1), 'S2');
            await tester.enterText(fields.at(2), '3');
            await tester.tap(find.text(OptionSetsKeys.save.en).last);
            await tester.pumpAndSettle();
            expect(repository.updatedOptionIds, [41]);

            await tester.tap(
              find.byTooltip(OptionSetsKeys.deactivate.en).first,
            );
            await tester.pumpAndSettle();
            expect(repository.activeChanges, [(41, false)]);

            await tester.tap(find.text(OptionSetsKeys.cancel.en).last);
            await tester.pumpAndSettle();
            await tester.tap(
              find.byTooltip(CatalogUiKeys.moreActions.en).first,
            );
            await tester.pumpAndSettle();
            expect(find.text(OptionSetsKeys.delete.en), findsNothing);
            expect(tester.takeException(), isNull);
          },
        );
      }
    }
  }
}
