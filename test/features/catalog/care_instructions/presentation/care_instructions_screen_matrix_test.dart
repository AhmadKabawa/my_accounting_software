import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:accounting_software/app/core/access/cubit/access_cubit.dart';
import 'package:accounting_software/app/core/access/domain/access_repository.dart';
import 'package:accounting_software/app/core/access/domain/get_my_access_usecase.dart';
import 'package:accounting_software/app/core/access/models/access_snapshot.dart';
import 'package:accounting_software/app/core/access/permission.dart';
import 'package:accounting_software/app/core/di/service_locator.dart';
import 'package:accounting_software/app/core/error/failures/failure.dart';
import 'package:accounting_software/app/core/foundation/types/paginated_result.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_message/flash_messages.dart';
import 'package:accounting_software/app/core/storage/shared_preferences/app_settings_manager.dart';
import 'package:accounting_software/app/features/catalog/care_instructions/domain/entity/care_instruction.dart';
import 'package:accounting_software/app/features/catalog/care_instructions/domain/entity/care_instruction_draft.dart';
import 'package:accounting_software/app/features/catalog/care_instructions/domain/entity/care_instruction_list_query.dart';
import 'package:accounting_software/app/features/catalog/care_instructions/domain/repositories/care_instructions_repository.dart';
import 'package:accounting_software/app/features/catalog/care_instructions/domain/usecase/create_care_instruction_use_case.dart';
import 'package:accounting_software/app/features/catalog/care_instructions/domain/usecase/delete_care_instruction_use_case.dart';
import 'package:accounting_software/app/features/catalog/care_instructions/domain/usecase/get_care_instructions_use_case.dart';
import 'package:accounting_software/app/features/catalog/care_instructions/domain/usecase/set_care_instruction_active_use_case.dart';
import 'package:accounting_software/app/features/catalog/care_instructions/domain/usecase/update_care_instruction_use_case.dart';
import 'package:accounting_software/app/features/catalog/care_instructions/presentation/cubit/care_instruction_form_cubit.dart';
import 'package:accounting_software/app/features/catalog/care_instructions/presentation/cubit/care_instructions_list_cubit.dart';
import 'package:accounting_software/app/features/catalog/care_instructions/presentation/pages/care_instructions_screen.dart';
import '../../../../helpers/localized_app.dart';
import '../../../../helpers/memory_storage.dart';
import '../../../../helpers/screen_matrix.dart';

class _AccessRepository implements AccessRepository {
  @override
  Future<Either<Failure, AccessSnapshot>> getMyAccess() async => const Right(
    AccessSnapshot(
      userId: 'test-user',
      username: 'test',
      email: null,
      isSuperAdmin: false,
      roles: [],
      permissions: {Permission('masterdata.manage')},
      branches: [],
      warehouses: [],
      posTerminals: [],
    ),
  );
}

class _CareInstructionsRepository implements CareInstructionsRepository {
  @override
  Future<Either<Failure, PaginatedResult<CareInstruction>>> getCareInstructions(
    CareInstructionListQuery query,
  ) async => const Right(
    PaginatedResult(items: [], totalCount: 0, currentPage: 1, totalPages: 0),
  );
  @override
  Future<Either<Failure, CareInstruction>> createCareInstruction(
    CareInstructionDraft draft,
  ) async => Right(
    CareInstruction(
      id: 1,
      name: draft.name,
      code: draft.code,
      careType: draft.careType,
      isActive: draft.isActive ?? true,
    ),
  );
  @override
  Future<Either<Failure, CareInstruction>> updateCareInstruction({
    required int id,
    required CareInstructionDraft draft,
  }) async => Right(
    CareInstruction(
      id: id,
      name: draft.name,
      code: draft.code,
      careType: draft.careType,
      isActive: draft.isActive ?? true,
    ),
  );
  @override
  Future<Either<Failure, Unit>> deleteCareInstruction(int id) async =>
      const Right(unit);
  @override
  Future<Either<Failure, Unit>> setCareInstructionActive({
    required int id,
    required bool isActive,
  }) async => const Right(unit);
}

void main() {
  setUpAll(() => useTranslations(const Locale('en')));

  testWidgets('280px RTL light screen at 1.5 scale', (tester) async {
    _register();
    addTearDown(() async => sl.reset());
    await pumpScreenMatrix(
      tester,
      width: 280,
      height: 760,
      direction: TextDirection.rtl,
      dark: false,
      textScale: 1.5,
      home: _withAccess(),
    );
    expect(find.byType(CareInstructionsScreen), findsOneWidget);
    expect(find.text('No care instructions yet'), findsOneWidget);
  });

  testWidgets('1200px LTR dark screen', (tester) async {
    _register();
    addTearDown(() async => sl.reset());
    await pumpScreenMatrix(
      tester,
      width: 1200,
      direction: TextDirection.ltr,
      dark: true,
      home: _withAccess(),
    );
    expect(find.byType(CareInstructionsScreen), findsOneWidget);
    expect(find.text('No care instructions yet'), findsOneWidget);
  });
}

Widget _withAccess() => BlocProvider<AccessCubit>(
  create: (_) =>
      AccessCubit(getMyAccess: GetMyAccessUseCase(_AccessRepository()))..load(),
  child: const Scaffold(body: CareInstructionsScreen()),
);

void _register() {
  final repository = _CareInstructionsRepository();
  sl.registerFactory<FlashMessages>(FlashMessages.new);
  sl.registerSingleton<AppSettingsManager>(
    AppSettingsManager(storage: MemoryStorage()),
  );
  sl.registerFactory<CareInstructionsListCubit>(
    () => CareInstructionsListCubit(
      getItems: GetCareInstructionsUseCase(repository),
      setActive: SetCareInstructionActiveUseCase(repository),
      deleteItem: DeleteCareInstructionUseCase(repository),
      flashMessages: sl(),
    ),
  );
  sl.registerFactory<CareInstructionFormCubit>(
    () => CareInstructionFormCubit(
      create: CreateCareInstructionUseCase(repository),
      update: UpdateCareInstructionUseCase(repository),
      flashMessages: sl(),
    ),
  );
}
