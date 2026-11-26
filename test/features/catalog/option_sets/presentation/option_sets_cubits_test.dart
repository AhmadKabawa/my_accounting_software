import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:accounting_software/app/core/error/failures/failure.dart';
import 'package:accounting_software/app/core/foundation/types/paginated_result.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_message/flash_messages.dart';
import 'package:accounting_software/app/features/catalog/option_sets/domain/entity/option_set.dart';
import 'package:accounting_software/app/features/catalog/option_sets/domain/entity/option_set_draft.dart';
import 'package:accounting_software/app/features/catalog/option_sets/domain/entity/option_set_list_query.dart';
import 'package:accounting_software/app/features/catalog/option_sets/domain/entity/option_set_stats.dart';
import 'package:accounting_software/app/features/catalog/option_sets/domain/repositories/option_sets_repository.dart';
import 'package:accounting_software/app/features/catalog/option_sets/domain/usecase/create_option_use_case.dart';
import 'package:accounting_software/app/features/catalog/option_sets/domain/usecase/create_option_set_use_case.dart';
import 'package:accounting_software/app/features/catalog/option_sets/domain/usecase/get_option_set_stats_use_case.dart';
import 'package:accounting_software/app/features/catalog/option_sets/domain/usecase/delete_option_set_use_case.dart';
import 'package:accounting_software/app/features/catalog/option_sets/domain/usecase/get_option_sets_use_case.dart';
import 'package:accounting_software/app/features/catalog/option_sets/domain/usecase/get_options_use_case.dart';
import 'package:accounting_software/app/features/catalog/option_sets/domain/usecase/set_option_active_use_case.dart';
import 'package:accounting_software/app/features/catalog/option_sets/domain/usecase/set_option_set_active_use_case.dart';
import 'package:accounting_software/app/features/catalog/option_sets/domain/usecase/update_option_use_case.dart';
import 'package:accounting_software/app/features/catalog/option_sets/domain/usecase/update_option_set_use_case.dart';
import 'package:accounting_software/app/features/catalog/option_sets/presentation/cubit/option_set_form/option_set_form_cubit.dart';
import 'package:accounting_software/app/features/catalog/option_sets/presentation/cubit/option_set_options/option_set_options_cubit.dart';
import 'package:accounting_software/app/features/catalog/option_sets/presentation/cubit/option_set_stats/option_set_stats_cubit.dart';
import 'package:accounting_software/app/features/catalog/option_sets/presentation/cubit/option_set_stats/option_set_stats_state.dart';
import 'package:accounting_software/app/features/catalog/option_sets/presentation/cubit/option_set_options/option_set_options_state.dart';
import 'package:accounting_software/app/features/catalog/option_sets/presentation/cubit/option_sets_list/option_sets_list_cubit.dart';

void main() {
  group('OptionSetsListCubit', () {
    late _FakeOptionSetsRepository repository;
    late OptionSetsListCubit cubit;

    setUp(() {
      repository = _FakeOptionSetsRepository();
      cubit = OptionSetsListCubit(
        getOptionSets: GetOptionSetsUseCase(repository),
        setActive: SetOptionSetActiveUseCase(repository),
        deleteOptionSet: DeleteOptionSetUseCase(repository),
        flashMessages: FlashMessages(),
      );
    });

    tearDown(() async => cubit.close());

    test(
      'status and sort changes reset pagination and reload server query',
      () async {
        await cubit.load();
        await cubit.setPage(4);
        await cubit.setStatus(OptionSetStatusFilter.active);

        expect(cubit.state.query.page, 1);
        expect(cubit.state.query.status, OptionSetStatusFilter.active);
        expect(repository.queries.last.page, 1);
        expect(repository.queries.last.status, OptionSetStatusFilter.active);

        await cubit.setPage(3);
        await cubit.setSort(false);
        expect(cubit.state.query.page, 1);
        expect(cubit.state.query.sortAscending, isFalse);
      },
    );

    test(
      'delete is rejected when either relationship count is unknown',
      () async {
        final result = await cubit.delete(
          const OptionSet(
            id: 7,
            name: 'Size',
            code: 'SIZE',
            selectionType: OptionSelectionType.single,
            isActive: true,
            options: [],
            usageCount: 0,
            optionCount: null,
          ),
        );

        expect(result.isLeft(), isTrue);
        expect(repository.deleteCalls, 0);
      },
    );
  });

  group('OptionSetStatsCubit', () {
    test('publishes server-derived counts', () async {
      final repository = _FakeOptionSetsRepository();
      final cubit = OptionSetStatsCubit(
        getStats: GetOptionSetStatsUseCase(repository),
      );
      addTearDown(cubit.close);

      await cubit.load();

      expect(cubit.state.status, OptionSetStatsStatus.ready);
      expect(cubit.state.stats, const OptionSetStats(total: 1, active: 1, inactive: 0));
      expect(repository.getStatsCalls, 1);
    });
  });

  group('OptionSetFormCubit', () {
    test('uses create for new sets and update for existing sets', () async {
      final repository = _FakeOptionSetsRepository();
      final cubit = OptionSetFormCubit(
        create: CreateOptionSetUseCase(repository),
        update: UpdateOptionSetUseCase(repository),
        flashMessages: FlashMessages(),
      );
      addTearDown(cubit.close);
      const draft = OptionSetDraft(
        name: 'Size',
        code: 'SIZE',
        selectionType: OptionSelectionType.single,
        isActive: true,
      );

      await cubit.save(draft: draft);
      await cubit.save(id: 12, draft: draft);

      expect(repository.createdGroupDrafts, [draft]);
      expect(repository.updatedGroupIds, [12]);
      expect(cubit.state, OptionSetFormStatus.idle);
    });
  });

  group('OptionSetOptionsCubit', () {
    test(
      'loads lazily and refreshes after create and active mutations',
      () async {
        final repository = _FakeOptionSetsRepository();
        final cubit = OptionSetOptionsCubit(
          getOptions: GetOptionsUseCase(repository),
          createOption: CreateOptionUseCase(repository),
          updateOption: UpdateOptionUseCase(repository),
          setOptionActive: SetOptionActiveUseCase(repository),
        );
        addTearDown(cubit.close);

        expect(repository.getOptionsCalls, 0);
        await cubit.load(12);
        expect(cubit.state.status, OptionSetOptionsStatus.ready);
        expect(repository.getOptionsCalls, 1);

        await cubit.saveOption(
          draft: const CatalogOptionDraft(
            name: 'Large',
            code: 'L',
            sortOrder: 2,
          ),
        );
        expect(repository.createdOptionSetIds, [12]);
        expect(repository.getOptionsCalls, 2);

        await cubit.setActive(optionId: 41, isActive: false);
        expect(repository.optionActiveChanges, [(41, false)]);
        expect(repository.getOptionsCalls, 3);
      },
    );
  });
}

class _FakeOptionSetsRepository implements OptionSetsRepository {
  final List<OptionSetListQuery> queries = [];
  final List<int> createdOptionSetIds = [];
  final List<(int, bool)> optionActiveChanges = [];
  int deleteCalls = 0;
  int getOptionsCalls = 0;
  int getStatsCalls = 0;
  final List<OptionSetDraft> createdGroupDrafts = [];
  final List<int> updatedGroupIds = [];

  static const _option = CatalogOption(
    id: 41,
    name: 'Small',
    code: 'S',
    sortOrder: 1,
    isActive: true,
  );

  static const _set = OptionSet(
    id: 12,
    name: 'Size',
    code: 'SIZE',
    selectionType: OptionSelectionType.single,
    isActive: true,
    options: [_option],
    usageCount: 0,
    optionCount: 1,
  );

  @override
  Future<Either<Failure, OptionSetStats>> getOptionSetStats() async {
    getStatsCalls++;
    return const Right(OptionSetStats(total: 1, active: 1, inactive: 0));
  }

  @override
  Future<Either<Failure, PaginatedResult<OptionSet>>> getOptionSets(
    OptionSetListQuery query,
  ) async {
    queries.add(query);
    return Right(
      PaginatedResult(
        items: const [_set],
        totalCount: 1,
        currentPage: query.page,
        totalPages: 5,
      ),
    );
  }

  @override
  Future<Either<Failure, List<CatalogOption>>> getOptions({
    required int optionSetId,
    String search = '',
  }) async {
    getOptionsCalls++;
    return const Right([_option]);
  }

  @override
  Future<Either<Failure, OptionSet>> createOptionSet(
    OptionSetDraft draft,
  ) async {
    createdGroupDrafts.add(draft);
    return const Right(_set);
  }

  @override
  Future<Either<Failure, OptionSet>> updateOptionSet({
    required int id,
    required OptionSetDraft draft,
  }) async {
    updatedGroupIds.add(id);
    return const Right(_set);
  }

  @override
  Future<Either<Failure, Unit>> deleteOptionSet(int id) async {
    deleteCalls++;
    return const Right(unit);
  }

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
    createdOptionSetIds.add(optionSetId);
    return const Right(unit);
  }

  @override
  Future<Either<Failure, Unit>> updateOption({
    required int optionId,
    required CatalogOptionDraft draft,
  }) async => const Right(unit);

  @override
  Future<Either<Failure, Unit>> setOptionActive({
    required int optionId,
    required bool isActive,
  }) async {
    optionActiveChanges.add((optionId, isActive));
    return const Right(unit);
  }
}
