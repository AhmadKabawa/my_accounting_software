import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:accounting_software/app/core/error/failures/failure.dart';
import 'package:accounting_software/app/core/foundation/types/paginated_result.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_message/flash_messages.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_message/message_view_widgets.dart';
import 'package:accounting_software/app/features/catalog/brands/domain/entity/brand.dart';
import 'package:accounting_software/app/features/catalog/brands/domain/entity/brand_list_query.dart';
import 'package:accounting_software/app/features/catalog/brands/domain/entity/brand_draft.dart';
import 'package:accounting_software/app/features/catalog/brands/domain/failures/brand_failures.dart';
import 'package:accounting_software/app/features/catalog/brands/domain/usecase/create_brand_use_case.dart';
import 'package:accounting_software/app/features/catalog/brands/domain/usecase/delete_brand_use_case.dart';
import 'package:accounting_software/app/features/catalog/brands/domain/usecase/get_brands_use_case.dart';
import 'package:accounting_software/app/features/catalog/brands/domain/usecase/set_brand_active_use_case.dart';
import 'package:accounting_software/app/features/catalog/brands/domain/usecase/update_brand_use_case.dart';
import 'package:accounting_software/app/features/catalog/brands/presentation/cubit/brand_form/brand_form_cubit.dart';
import 'package:accounting_software/app/features/catalog/brands/presentation/cubit/brand_form/brand_form_effect.dart';
import 'package:accounting_software/app/features/catalog/brands/presentation/cubit/brands_list/brands_list_cubit.dart';
import 'package:accounting_software/app/features/catalog/brands/presentation/cubit/brands_list/brands_list_effect.dart';
import 'package:accounting_software/app/features/catalog/brands/presentation/cubit/brands_list/brands_list_state.dart';
import 'package:accounting_software/app/features/catalog/brands/presentation/localization/brands_keys.dart';

import '../../support/fake_brands_repository.dart';

class _Failure extends Failure {
  const _Failure() : super(messageKey: BrandsKeys.loadError);
}

void main() {
  test('loading transitions to ready after a successful request', () async {
    final repository = FakeBrandsRepository();
    final pending = Completer<Either<Failure, PaginatedResult<Brand>>>();
    repository.onGetBrands = (_) => pending.future;
    final cubit = _listCubit(repository);

    final load = cubit.load();
    expect(cubit.state.status, BrandsListStatus.loading);
    pending.complete(const Right(_page()));
    await load;

    expect(cubit.state.status, BrandsListStatus.ready);
    expect(cubit.state.hasData, isTrue);
    await cubit.close();
  });

  test('refreshing retains the previous rows until the new result arrives',
      () async {
    final repository = FakeBrandsRepository();
    final cubit = _listCubit(repository);
    await cubit.load();
    final pending = Completer<Either<Failure, PaginatedResult<Brand>>>();
    repository.onGetBrands = (_) => pending.future;

    final refresh = cubit.refresh();
    expect(cubit.state.status, BrandsListStatus.refreshing);
    expect(cubit.state.result!.items.single.name, 'Northwind');
    pending.complete(const Right(_page(name: 'Updated')));
    await refresh;

    expect(cubit.state.result!.items.single.name, 'Updated');
    await cubit.close();
  });

  test('failure with data retains rows and exposes failure', () async {
    final repository = FakeBrandsRepository();
    final cubit = _listCubit(repository);
    await cubit.load();
    repository.onGetBrands = (_) async => const Left(_Failure());

    await cubit.refresh();

    expect(cubit.state.status, BrandsListStatus.failed);
    expect(cubit.state.hasData, isTrue);
    expect(cubit.state.result!.items.single.name, 'Northwind');
    expect(cubit.state.failure, isA<_Failure>());
    await cubit.close();
  });

  test('failure without data leaves result empty', () async {
    final repository = FakeBrandsRepository()
      ..onGetBrands = (_) async => const Left(_Failure());
    final cubit = _listCubit(repository);

    await cubit.load();

    expect(cubit.state.status, BrandsListStatus.failed);
    expect(cubit.state.hasData, isFalse);
    expect(cubit.state.failure, isA<_Failure>());
    await cubit.close();
  });

  test('latest request wins over an older in-flight request', () async {
    final repository = FakeBrandsRepository();
    final pending = <Completer<Either<Failure, PaginatedResult<Brand>>>>[];
    repository.onGetBrands = (_) {
      final request = Completer<Either<Failure, PaginatedResult<Brand>>>();
      pending.add(request);
      return request.future;
    };
    final cubit = _listCubit(repository);

    final first = cubit.load();
    final second = cubit.setSort(ascending: false);
    pending[1].complete(const Right(_page(name: 'Newest')));
    await second;
    pending[0].complete(const Right(_page(name: 'Old')));
    await first;

    expect(cubit.state.result!.items.single.name, 'Newest');
    await cubit.close();
  });

  test('search debounce waits 300ms and updates query immediately', () {
    fakeAsync((async) {
      final repository = FakeBrandsRepository();
      final cubit = _listCubit(repository);

      cubit.searchChanged('shoe');
      expect(cubit.state.query.search, 'shoe');
      expect(repository.queries, isEmpty);
      async.elapse(const Duration(milliseconds: 299));
      expect(repository.queries, isEmpty);
      async.elapse(const Duration(milliseconds: 1));
      async.flushMicrotasks();
      expect(repository.queries, hasLength(1));
      expect(repository.queries.single.search, 'shoe');
      cubit.close();
      async.flushMicrotasks();
    });
  });

  test('clearFilters cancels pending search and issues one reset load', () {
    fakeAsync((async) {
      final repository = FakeBrandsRepository();
      final cubit = _listCubit(repository);

      cubit.setStatus(BrandStatusFilter.active);
      async.flushMicrotasks();
      cubit.setPage(3);
      async.flushMicrotasks();
      cubit.searchChanged('pending');

      final requestCount = repository.queries.length;
      cubit.clearFilters();
      async.flushMicrotasks();

      expect(repository.queries, hasLength(requestCount + 1));
      expect(cubit.state.query.search, isEmpty);
      expect(cubit.state.query.status, BrandStatusFilter.all);
      expect(cubit.state.query.page, 1);
      expect(repository.queries.last.search, isEmpty);
      expect(repository.queries.last.status, BrandStatusFilter.all);
      expect(repository.queries.last.page, 1);

      async.elapse(const Duration(milliseconds: 300));
      async.flushMicrotasks();
      expect(repository.queries, hasLength(requestCount + 1));

      cubit.close();
      async.flushMicrotasks();
    });
  });

  test('delete with positive or unknown product count makes no request',
      () async {
    final repository = FakeBrandsRepository();
    final cubit = _listCubit(repository);
    const used = Brand(
      id: 1,
      name: 'Used',
      slug: 'used',
      isActive: true,
      productCount: 2,
    );
    const unknown = Brand(
      id: 2,
      name: 'Unknown',
      slug: 'unknown',
      isActive: true,
    );

    final usedResult = await cubit.delete(used);
    final unknownResult = await cubit.delete(unknown);

    expect(usedResult.isLeft(), isTrue);
    expect(
      usedResult.fold((failure) => failure, (_) => null),
      isA<BrandInUseFailure>(),
    );
    expect(unknownResult.isLeft(), isTrue);
    expect(
      unknownResult.fold((failure) => failure, (_) => null),
      isA<BrandUsageUnknownFailure>(),
    );
    expect(repository.deletedIds, isEmpty);
    expect(repository.queries, isEmpty);
    await cubit.close();
  });

  test('activate, deactivate and delete emit mutation effects and flashes',
      () async {
    final repository = FakeBrandsRepository();
    final messages = FlashMessages();
    final flashes = [];
    final stopListening = messages.listen(flashes.add);
    final cubit = _listCubit(repository, flashMessages: messages);
    final effects = <BrandsListEffect>[];
    final subscription = cubit.effectStream.listen(effects.add);

    await cubit.activate(12);
    await cubit.deactivate(12);
    await cubit.delete(FakeBrandsRepository.brand);
    await Future<void>.delayed(Duration.zero);

    expect(
      effects.map((effect) => (effect as BrandsMutatedEffect).kind),
      [
        BrandsMutationKind.statusChanged,
        BrandsMutationKind.statusChanged,
        BrandsMutationKind.deleted,
      ],
    );
    expect(flashes, hasLength(3));
    expect(
      flashes.every((message) => message.type == MessageType.success),
      isTrue,
    );
    await subscription.cancel();
    stopListening();
    await cubit.close();
  });

  test('activate failure posts an error flash without mutation effect',
      () async {
    final repository = FakeBrandsRepository();
    repository.statusMutationResult = const Left(_Failure());
    final messages = FlashMessages();
    final flashes = [];
    final stopListening = messages.listen(flashes.add);
    final cubit = _listCubit(repository, flashMessages: messages);
    final effects = <BrandsListEffect>[];
    final subscription = cubit.effectStream.listen(effects.add);

    await cubit.activate(12);

    expect(effects, isEmpty);
    expect(flashes, hasLength(1));
    expect(flashes.single.type, MessageType.error);
    await subscription.cancel();
    stopListening();
    await cubit.close();
  });

  test('deleting the last row on a later page moves to the previous page',
      () async {
    final repository = FakeBrandsRepository();
    repository.onGetBrands = (query) async {
      if (repository.deletedIds.isNotEmpty) {
        return const Right(
          PaginatedResult<Brand>(
            items: [],
            totalCount: 0,
            currentPage: 1,
            totalPages: 0,
          ),
        );
      }
      return Right(
        PaginatedResult<Brand>(
          items: const [FakeBrandsRepository.brand],
          totalCount: 26,
          currentPage: query.page,
          totalPages: 2,
        ),
      );
    };
    final cubit = _listCubit(repository);

    await cubit.setPage(2);
    await cubit.delete(FakeBrandsRepository.brand);

    expect(cubit.state.query.page, 1);
    expect(cubit.state.result!.items, isEmpty);
    await cubit.close();
  });

  test('no list state is emitted after close while a request is pending',
      () async {
    final repository = FakeBrandsRepository();
    final pending = Completer<Either<Failure, PaginatedResult<Brand>>>();
    repository.onGetBrands = (_) => pending.future;
    final cubit = _listCubit(repository);
    var emissions = 0;
    final subscription = cubit.stream.listen((_) => emissions++);
    final load = cubit.load();

    await cubit.close();
    final countAtClose = emissions;
    pending.complete(const Right(_page()));
    await load;

    expect(emissions, countAtClose);
    await subscription.cancel();
  });

  test('form save emits BrandSavedEffect and returns to idle', () async {
    final repository = FakeBrandsRepository();
    final messages = FlashMessages();
    final flashes = [];
    final stopListening = messages.listen(flashes.add);
    final cubit = _formCubit(repository, messages: messages);
    final effects = <BrandFormEffect>[];
    final subscription = cubit.effectStream.listen(effects.add);

    await cubit.save(draft: const BrandDraft(name: 'New', slug: 'new'));
    await Future<void>.delayed(Duration.zero);

    expect(cubit.state, BrandFormStatus.idle);
    expect(effects.single, isA<BrandSavedEffect>());
    expect(flashes.single.key, BrandsKeys.saved);
    await subscription.cancel();
    stopListening();
    await cubit.close();
  });

  test('ordinary form failure emits its key and returns to idle', () async {
    final repository = FakeBrandsRepository()
      ..onCreateBrand = (_) async => const Left(_Failure());
    final cubit = _formCubit(repository);
    final effects = <BrandFormEffect>[];
    final subscription = cubit.effectStream.listen(effects.add);

    await cubit.save(draft: const BrandDraft(name: 'New', slug: 'new'));
    await Future<void>.delayed(Duration.zero);

    expect(effects.single, isA<BrandSaveFailedEffect>());
    expect(
      (effects.single as BrandSaveFailedEffect).messageKey,
      BrandsKeys.loadError,
    );
    expect(cubit.state, BrandFormStatus.idle);
    await subscription.cancel();
    await cubit.close();
  });

  test('duplicate form failure maps to duplicateError', () async {
    final repository = FakeBrandsRepository()
      ..onCreateBrand = (_) async => const Left(BrandDuplicateFailure());
    final cubit = _formCubit(repository);
    final effects = <BrandFormEffect>[];
    final subscription = cubit.effectStream.listen(effects.add);

    await cubit.save(draft: const BrandDraft(name: 'New', slug: 'new'));
    await Future<void>.delayed(Duration.zero);

    expect(
      (effects.single as BrandSaveFailedEffect).messageKey,
      BrandsKeys.duplicateError,
    );
    await subscription.cancel();
    await cubit.close();
  });

  test('second save while saving is silently ignored', () async {
    final repository = FakeBrandsRepository();
    final pending = Completer<Either<Failure, Brand>>();
    repository.onCreateBrand = (_) => pending.future;
    final cubit = _formCubit(repository);
    final effects = <BrandFormEffect>[];
    final subscription = cubit.effectStream.listen(effects.add);

    final first = cubit.save(
      draft: const BrandDraft(name: 'New', slug: 'new'),
    );
    await Future<void>.delayed(Duration.zero);
    await cubit.save(
      draft: const BrandDraft(name: 'Ignored', slug: 'ignored'),
    );
    expect(cubit.state, BrandFormStatus.saving);
    pending.complete(const Right(FakeBrandsRepository.brand));
    await first;
    await Future<void>.delayed(Duration.zero);

    expect(effects.whereType<BrandSavedEffect>(), hasLength(1));
    await subscription.cancel();
    await cubit.close();
  });
}

BrandsListCubit _listCubit(
  FakeBrandsRepository repository, {
  FlashMessages? flashMessages,
}) => BrandsListCubit(
  getBrands: GetBrandsUseCase(repository),
  setBrandActive: SetBrandActiveUseCase(repository),
  deleteBrand: DeleteBrandUseCase(repository),
  flashMessages: flashMessages ?? FlashMessages(),
);

BrandFormCubit _formCubit(
  FakeBrandsRepository repository, {
  FlashMessages? messages,
}) => BrandFormCubit(
  createBrand: CreateBrandUseCase(repository),
  updateBrand: UpdateBrandUseCase(repository),
  flashMessages: messages ?? FlashMessages(),
);

PaginatedResult<Brand> _page({String name = 'Northwind'}) =>
    PaginatedResult<Brand>(
      items: [
        Brand(
          id: 12,
          name: name,
          slug: name.toLowerCase(),
          isActive: true,
          productCount: 0,
        ),
      ],
      totalCount: 1,
      currentPage: 1,
      totalPages: 1,
    );
