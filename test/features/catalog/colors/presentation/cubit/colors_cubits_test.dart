import 'package:dartz/dartz.dart';
import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:accounting_software/app/core/error/failures/failure.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_message/flash_messages.dart';
import 'package:accounting_software/app/features/catalog/colors/domain/entity/catalog_color_draft.dart';
import 'package:accounting_software/app/features/catalog/colors/domain/entity/color_list_query.dart';
import 'package:accounting_software/app/features/catalog/colors/domain/entity/color_stats.dart';
import 'package:accounting_software/app/features/catalog/colors/domain/failures/color_failures.dart';
import 'package:accounting_software/app/features/catalog/colors/domain/usecase/create_color_use_case.dart';
import 'package:accounting_software/app/features/catalog/colors/domain/usecase/get_colors_use_case.dart';
import 'package:accounting_software/app/features/catalog/colors/domain/usecase/get_color_stats_use_case.dart';
import 'package:accounting_software/app/features/catalog/colors/presentation/cubit/color_stats/color_stats_cubit.dart';
import 'package:accounting_software/app/features/catalog/colors/presentation/cubit/color_stats/color_stats_state.dart';
import 'package:accounting_software/app/features/catalog/colors/domain/usecase/delete_color_use_case.dart';
import 'package:accounting_software/app/features/catalog/colors/domain/usecase/set_color_active_use_case.dart';
import 'package:accounting_software/app/features/catalog/colors/domain/usecase/update_color_use_case.dart';
import 'package:accounting_software/app/features/catalog/colors/presentation/cubit/color_form/color_form_cubit.dart';
import 'package:accounting_software/app/features/catalog/colors/presentation/cubit/color_form/color_form_effect.dart';
import 'package:accounting_software/app/features/catalog/colors/presentation/cubit/colors_list/colors_list_cubit.dart';
import 'package:accounting_software/app/features/catalog/colors/presentation/cubit/colors_list/colors_list_effect.dart';
import 'package:accounting_software/app/core/presentation/state_management/paged_list/paged_list_state.dart';
import 'package:accounting_software/app/features/catalog/colors/presentation/localization/colors_keys.dart';

import '../../support/fake_colors_repository.dart';

class _Failure extends Failure {
  const _Failure() : super(messageKey: ColorsKeys.loadError);
}

ColorsListCubit _list(FakeColorsRepository repository) => ColorsListCubit(
  getColors: GetColorsUseCase(repository),
  setColorActive: SetColorActiveUseCase(repository),
  deleteColor: DeleteColorUseCase(repository),
  flashMessages: FlashMessages(),
);

ColorFormCubit _form(FakeColorsRepository repository) => ColorFormCubit(
  createColor: CreateColorUseCase(repository),
  updateColor: UpdateColorUseCase(repository),
  flashMessages: FlashMessages(),
);

void main() {
  group('ColorsListCubit', () {
    test('load reaches ready with rows', () async {
      final cubit = _list(FakeColorsRepository());
      await cubit.load();
      expect(cubit.state.status, PagedListStatus.ready);
      expect(cubit.state.result?.items, [sampleColor]);
      await cubit.close();
    });

    test('a failed first load keeps no data and records the failure', () async {
      final repository = FakeColorsRepository()
        ..onGetColors = (_) async => const Left(_Failure());
      final cubit = _list(repository);
      await cubit.load();
      expect(cubit.state.status, PagedListStatus.failed);
      expect(cubit.state.hasData, isFalse);
      expect(cubit.state.failure, isA<_Failure>());
      await cubit.close();
    });

    test('a failed refresh keeps the previous rows', () async {
      final repository = FakeColorsRepository();
      final cubit = _list(repository);
      await cubit.load();
      repository.onGetColors = (_) async => const Left(_Failure());
      await cubit.refresh();
      expect(cubit.state.status, ColorsListStatus.failed);
      expect(cubit.state.result?.items, [sampleColor]);
      await cubit.close();
    });

    test('status filter and sort reset to page 1 and reload', () async {
      final repository = FakeColorsRepository();
      final cubit = _list(repository);
      await cubit.load();
      await cubit.setPage(2);
      await cubit.setStatus(ColorStatusFilter.active);
      expect(repository.queries.last.page, 1);
      expect(repository.queries.last.status, ColorStatusFilter.active);

      await cubit.setSorts([
        const ColorSort(ColorSortField.code, false),
        const ColorSort(ColorSortField.name, true),
      ]);
      expect(repository.queries.last.sortField, ColorSortField.code);
      expect(repository.queries.last.sortAscending, isFalse);
      expect(repository.queries.last.thenSorts, [
        const ColorSort(ColorSortField.name, true),
      ]);
      await cubit.close();
    });

    test('the same filter does not trigger another request', () async {
      final repository = FakeColorsRepository();
      final cubit = _list(repository);
      await cubit.load();
      final before = repository.queries.length;
      await cubit.setStatus(ColorStatusFilter.all);
      await cubit.setSorts([const ColorSort(ColorSortField.order, true)]);
      expect(repository.queries.length, before);
      await cubit.close();
    });

    test('search is debounced into one request', () {
      fakeAsync((async) {
        final repository = FakeColorsRepository();
        final cubit = _list(repository);
        cubit.searchChanged('n');
        cubit.searchChanged('na');
        cubit.searchChanged('nav');
        async.elapse(const Duration(milliseconds: 299));
        expect(repository.queries, isEmpty);
        async.elapse(const Duration(milliseconds: 2));
        async.flushMicrotasks();
        expect(repository.queries, hasLength(1));
        expect(repository.queries.single.search, 'nav');
        cubit.close();
      });
    });

    test('clearFilters resets search and status', () async {
      final repository = FakeColorsRepository();
      final cubit = _list(repository);
      await cubit.setStatus(ColorStatusFilter.inactive);
      await cubit.clearFilters();
      expect(repository.queries.last.status, ColorStatusFilter.all);
      expect(repository.queries.last.search, isEmpty);
      await cubit.close();
    });

    test('activate calls the use case, emits an effect and reloads', () async {
      final repository = FakeColorsRepository();
      final cubit = _list(repository);
      final effects = <ColorsListEffect>[];
      final sub = cubit.effectStream.listen(effects.add);
      await cubit.activate(7);
      await Future<void>.delayed(Duration.zero);

      expect(repository.statusUpdates, [(7, true)]);
      expect(repository.queries, hasLength(1));
      expect(effects.single, isA<ColorsMutatedEffect>());
      await sub.cancel();
      await cubit.close();
    });

    test('delete calls the repository, emits deleted and reloads', () async {
      final repository = FakeColorsRepository();
      final cubit = _list(repository);
      final effects = <ColorsListEffect>[];
      final sub = cubit.effectStream.listen(effects.add);
      await cubit.setPage(2);

      final result = await cubit.delete(sampleColor);
      await Future<void>.delayed(Duration.zero);

      expect(result.isRight(), isTrue);
      expect(repository.deleted, [7]);
      expect(repository.queries, hasLength(2));
      expect(repository.queries.last.page, 1);
      expect(
        (effects.single as ColorsMutatedEffect).kind,
        ColorsMutationKind.deleted,
      );
      await sub.cancel();
      await cubit.close();
    });

    test('a failed deactivate returns the failure, no reload', () async {
      final repository = FakeColorsRepository()
        ..statusResult = const Left(_Failure());
      final cubit = _list(repository);
      final result = await cubit.deactivate(7);
      expect(result.isLeft(), isTrue);
      expect(repository.queries, isEmpty);
      await cubit.close();
    });
  });

  group('ColorStatsCubit', () {
    test('loads independent server statistics', () async {
      final repository = FakeColorsRepository();
      final cubit = ColorStatsCubit(
        getColorStats: GetColorStatsUseCase(repository),
      );

      await cubit.load();

      expect(cubit.state.status, ColorStatsStatus.ready);
      expect(cubit.state.stats?.total, 1);
      expect(cubit.state.stats?.active, 1);
      expect(cubit.state.stats?.inactive, 0);

      repository.stats = const ColorStats(total: 4, active: 3, inactive: 1);
      await cubit.refresh();
      expect(cubit.state.stats?.total, 4);
      expect(cubit.state.stats?.inactive, 1);
      await cubit.close();
    });
  });

  group('ColorFormCubit', () {
    const draft = CatalogColorDraft(name: 'Navy', code: 'NAVY');

    test('creates when there is no id and emits saved', () async {
      final repository = FakeColorsRepository();
      final cubit = _form(repository);
      final effects = <ColorFormEffect>[];
      final sub = cubit.effectStream.listen(effects.add);

      await cubit.save(draft: draft);
      await Future<void>.delayed(Duration.zero);

      expect(repository.created, [draft]);
      expect(effects.single, isA<ColorSavedEffect>());
      expect(cubit.state, ColorFormStatus.idle);
      await sub.cancel();
      await cubit.close();
    });

    test('updates when an id is given', () async {
      final repository = FakeColorsRepository();
      final cubit = _form(repository);
      await cubit.save(draft: draft, id: 7);
      expect(repository.updated, [(7, draft)]);
      expect(repository.created, isEmpty);
      await cubit.close();
    });

    test('a duplicate is shown with the specific message', () async {
      final repository = FakeColorsRepository()
        ..saveResult = const Left(ColorDuplicateFailure());
      final cubit = _form(repository);
      final effects = <ColorFormEffect>[];
      final sub = cubit.effectStream.listen(effects.add);

      await cubit.save(draft: draft);
      await Future<void>.delayed(Duration.zero);

      final effect = effects.single as ColorSaveFailedEffect;
      expect(effect.messageKey, ColorsKeys.duplicateError);
      await sub.cancel();
      await cubit.close();
    });
  });
}
