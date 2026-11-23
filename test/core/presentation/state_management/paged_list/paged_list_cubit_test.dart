import 'package:dartz/dartz.dart';
import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:accounting_software/app/core/presentation/state_management/paged_list/paged_list_state.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_message/flash_messages.dart';
import 'support/fake_paged_list_cubit.dart';

void main() {
  test('a late response from an older request is ignored', () async {
    final cubit = TestPagedCubit();
    final oldLoad = cubit.load();
    final newLoad = cubit.load();

    cubit.requests[1].complete(const Right(TestPagedPage([2])));
    await newLoad;
    cubit.requests[0].complete(const Right(TestPagedPage([1])));
    await oldLoad;

    expect(cubit.state.result!.items, [2]);
    await cubit.close();
  });

  test('invalid and current page changes do not fetch', () async {
    final cubit = TestPagedCubit();
    await cubit.setPage(1);
    await cubit.setPage(0);
    expect(cubit.requests, isEmpty);
    await cubit.close();
  });

  test('search change invalidates an in-flight request immediately', () {
    fakeAsync((async) {
      final cubit = TestPagedCubit();
      final oldLoad = cubit.load();
      cubit.searchChanged('fresh');
      cubit.requests.first.complete(const Right(TestPagedPage([1])));
      async.flushMicrotasks();
      expect(cubit.state.result, isNull);

      async.elapse(const Duration(milliseconds: 300));
      async.flushMicrotasks();
      expect(cubit.requests, hasLength(2));
      expect(cubit.requestedQueries.last.search, 'fresh');
      cubit.requests.last.complete(const Right(TestPagedPage([2])));
      async.flushMicrotasks();
      oldLoad.then((_) {});
      cubit.close();
      async.flushMicrotasks();
    });
  });

  test('search debounce combines rapid changes into one request', () {
    fakeAsync((async) {
      final cubit = TestPagedCubit();
      cubit.searchChanged('a');
      cubit.searchChanged('ab');
      cubit.searchChanged('abc');

      async.elapse(const Duration(milliseconds: 299));
      expect(cubit.requests, isEmpty);
      async.elapse(const Duration(milliseconds: 1));
      async.flushMicrotasks();

      expect(cubit.requests, hasLength(1));
      expect(cubit.requestedQueries.single.search, 'abc');
      cubit.requests.single.complete(const Right(TestPagedPage([1])));
      async.flushMicrotasks();
      cubit.close();
      async.flushMicrotasks();
    });
  });

  test('manual load cancels the pending debounce timer', () {
    fakeAsync((async) {
      final cubit = TestPagedCubit();
      cubit.searchChanged('typed');
      final load = cubit.load();
      expect(cubit.requests, hasLength(1));
      cubit.requests.single.complete(const Right(TestPagedPage([1])));
      async.flushMicrotasks();
      async.elapse(const Duration(milliseconds: 300));
      async.flushMicrotasks();
      expect(cubit.requests, hasLength(1));
      load.then((_) {});
      cubit.close();
      async.flushMicrotasks();
    });
  });

  test('close cancels the pending debounce timer', () {
    fakeAsync((async) {
      final cubit = TestPagedCubit();
      cubit.searchChanged('typed');
      cubit.close();
      async.flushMicrotasks();
      async.elapse(const Duration(milliseconds: 300));
      async.flushMicrotasks();
      expect(cubit.requests, isEmpty);
    });
  });

  test('refresh failure retains previous data and records failure', () async {
    final cubit = TestPagedCubit();
    final firstLoad = cubit.load();
    cubit.requests[0].complete(const Right(TestPagedPage([7])));
    await firstLoad;

    final refresh = cubit.refresh();
    expect(cubit.state.status, PagedListStatus.refreshing);
    cubit.requests[1].complete(const Left(TestPagedFailure()));
    await refresh;

    expect(cubit.state.status, PagedListStatus.failed);
    expect(cubit.state.result!.items, [7]);
    expect(cubit.state.failure, isA<TestPagedFailure>());
    await cubit.close();
  });

  test('first load failure has no result', () async {
    final cubit = TestPagedCubit();
    final load = cubit.load();
    cubit.requests.single.complete(const Left(TestPagedFailure()));
    await load;

    expect(cubit.state.status, PagedListStatus.failed);
    expect(cubit.state.result, isNull);
    expect(cubit.state.failure, isA<TestPagedFailure>());
    await cubit.close();
  });

  test('deleting the last item on page two returns to page one', () async {
    final cubit = TestPagedCubit(query: const TestPagedQuery(page: 2));
    final initialLoad = cubit.load();
    cubit.requests[0].complete(const Right(TestPagedPage([22])));
    await initialLoad;

    final deletion = cubit.delete(22);
    await Future<void>.delayed(Duration.zero);
    expect(cubit.deleteCalls, 1);
    expect(cubit.requestedQueries, hasLength(2));
    expect(cubit.requestedQueries.last.page, 1);

    cubit.requests[1].complete(const Right(TestPagedPage([11])));
    await deletion;
    expect(cubit.state.query.page, 1);
    expect(cubit.state.result!.items, [11]);
    await cubit.close();
  });

  test('an emptied later page after reload triggers a previous-page load',
      () async {
    final cubit = TestPagedCubit(query: const TestPagedQuery(page: 2));
    final initialLoad = cubit.load();
    cubit.requests[0].complete(const Right(TestPagedPage([21, 22])));
    await initialLoad;

    final deletion = cubit.delete(21);
    await Future<void>.delayed(Duration.zero);
    expect(cubit.requestedQueries.last.page, 2);
    cubit.requests[1].complete(const Right(TestPagedPage([])));
    await Future<void>.delayed(Duration.zero);

    expect(cubit.requestedQueries, hasLength(3));
    expect(cubit.requestedQueries.last.page, 1);
    cubit.requests[2].complete(const Right(TestPagedPage([10])));
    await deletion;
    expect(cubit.state.query.page, 1);
    await cubit.close();
  });

  test('clearFilters cancels the pending search timer and preserves sort', () {
    fakeAsync((async) {
      final cubit = TestPagedCubit(
        query: const TestPagedQuery(search: 'old', page: 3, filtered: true, sort: 4),
      );
      cubit.searchChanged('pending');
      final clear = cubit.clearFilters();
      expect(cubit.state.query.search, isEmpty);
      expect(cubit.state.query.page, 1);
      expect(cubit.state.query.filtered, isFalse);
      expect(cubit.state.query.sort, 4);

      async.flushMicrotasks();
      expect(cubit.requests, hasLength(1));
      async.elapse(const Duration(milliseconds: 300));
      async.flushMicrotasks();
      expect(cubit.requests, hasLength(1));

      cubit.requests.single.complete(const Right(TestPagedPage([1])));
      async.flushMicrotasks();
      clear.then((_) {});
      cubit.close();
      async.flushMicrotasks();
    });
  });

  test('successful deletion posts its flash before its effect', () async {
    final messages = FlashMessages();
    final events = <String>[];
    final stopListening = messages.listen((_) => events.add('flash'));
    final cubit = TestPagedCubit(flashMessages: messages);
    final effects = cubit.effectStream.listen((_) => events.add('effect'));

    final initialLoad = cubit.load();
    cubit.requests[0].complete(const Right(TestPagedPage([4])));
    await initialLoad;

    final deletion = cubit.delete(4);
    await Future<void>.delayed(Duration.zero);
    cubit.requests[1].complete(const Right(TestPagedPage([])));
    await deletion;
    await Future<void>.delayed(Duration.zero);

    expect(events, ['flash', 'effect']);
    await effects.cancel();
    stopListening();
    await cubit.close();
  });

  test('responses completing after close do not emit another state', () async {
    final cubit = TestPagedCubit();
    var emissions = 0;
    final subscription = cubit.stream.listen((_) => emissions++);
    final load = cubit.load();
    await cubit.close();
    final atClose = emissions;
    cubit.requests.single.complete(const Right(TestPagedPage([1])));
    await load;

    expect(emissions, atClose);
    await subscription.cancel();
  });
}
