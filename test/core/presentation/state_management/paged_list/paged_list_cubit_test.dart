import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:accounting_software/app/core/error/failures/failure.dart';
import 'package:accounting_software/app/core/foundation/types/paged_query.dart';
import 'package:accounting_software/app/core/foundation/types/paged_result.dart';
import 'package:accounting_software/app/core/localization/translations/app_key.dart';
import 'package:accounting_software/app/core/presentation/state_management/paged_list/paged_list_cubit.dart';
import 'package:accounting_software/app/core/presentation/state_management/paged_list/paged_list_state.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_message/flash_messages.dart';

enum _TestKey implements AppKey {
  loadError,
  deleted;

  @override
  String get key => 'test.${name}';
  @override
  String get ar => name;
  @override
  String get en => name;
}

class _TestFailure extends Failure {
  const _TestFailure() : super(messageKey: _TestKey.loadError);
}

class _TestQuery implements PagedQuery<_TestQuery> {
  const _TestQuery({
    this.search = '',
    this.page = 1,
    this.pageSize = 10,
    this.filtered = false,
    this.sort = 0,
  });

  @override
  final String search;
  @override
  final int page;
  @override
  final int pageSize;
  final bool filtered;
  final int sort;

  @override
  bool get hasActiveFilters => search.isNotEmpty || filtered;

  @override
  _TestQuery withSearch(String value) =>
      _TestQuery(search: value, page: 1, pageSize: pageSize,
          filtered: filtered, sort: sort);

  @override
  _TestQuery withPage(int value) =>
      _TestQuery(search: search, page: value, pageSize: pageSize,
          filtered: filtered, sort: sort);

  @override
  _TestQuery cleared() => _TestQuery(page: 1, pageSize: pageSize, sort: sort);
}

class _TestPage implements PagedResult<int> {
  const _TestPage(this.items);
  @override
  final List<int> items;
  @override
  int get totalCount => items.length;
}

class _TestCubit extends PagedListCubit<int, _TestQuery, PagedMutationKind> {
  _TestCubit({
    _TestQuery query = const _TestQuery(),
    FlashMessages? flashMessages,
  }) : super(
         initialQuery: query,
         flashMessages: flashMessages ?? FlashMessages(),
       );

  final requests = <Completer<Either<Failure, PagedResult<int>>>>[];
  final requestedQueries = <_TestQuery>[];
  int deleteCalls = 0;

  @override
  Future<Either<Failure, PagedResult<int>>> fetch(_TestQuery query) {
    requestedQueries.add(query);
    final request = Completer<Either<Failure, PagedResult<int>>>();
    requests.add(request);
    return request.future;
  }

  @override
  Future<Either<Failure, Unit>> deleteItem(int item) async {
    deleteCalls++;
    return const Right(unit);
  }

  @override
  AppKey get deletedMessageKey => _TestKey.deleted;

  @override
  PagedMutationKind buildMutationEffect(PagedMutationKind kind) => kind;
}

void main() {
  test('a late response from an older request is ignored', () async {
    final cubit = _TestCubit();
    final oldLoad = cubit.load();
    final newLoad = cubit.load();

    cubit.requests[1].complete(const Right(_TestPage([2])));
    await newLoad;
    cubit.requests[0].complete(const Right(_TestPage([1])));
    await oldLoad;

    expect(cubit.state.result!.items, [2]);
    await cubit.close();
  });

  test('search debounce combines rapid changes into one request', () {
    fakeAsync((async) {
      final cubit = _TestCubit();
      cubit.searchChanged('a');
      cubit.searchChanged('ab');
      cubit.searchChanged('abc');

      async.elapse(const Duration(milliseconds: 299));
      expect(cubit.requests, isEmpty);
      async.elapse(const Duration(milliseconds: 1));
      async.flushMicrotasks();

      expect(cubit.requests, hasLength(1));
      expect(cubit.requestedQueries.single.search, 'abc');
      cubit.requests.single.complete(const Right(_TestPage([1])));
      async.flushMicrotasks();
      cubit.close();
      async.flushMicrotasks();
    });
  });

  test('refresh failure retains previous data and records failure', () async {
    final cubit = _TestCubit();
    final firstLoad = cubit.load();
    cubit.requests[0].complete(const Right(_TestPage([7])));
    await firstLoad;

    final refresh = cubit.refresh();
    expect(cubit.state.status, PagedListStatus.refreshing);
    cubit.requests[1].complete(const Left(_TestFailure()));
    await refresh;

    expect(cubit.state.status, PagedListStatus.failed);
    expect(cubit.state.result!.items, [7]);
    expect(cubit.state.failure, isA<_TestFailure>());
    await cubit.close();
  });

  test('first load failure has no result', () async {
    final cubit = _TestCubit();
    final load = cubit.load();
    cubit.requests.single.complete(const Left(_TestFailure()));
    await load;

    expect(cubit.state.status, PagedListStatus.failed);
    expect(cubit.state.result, isNull);
    expect(cubit.state.failure, isA<_TestFailure>());
    await cubit.close();
  });

  test('deleting the last item on page two returns to page one', () async {
    final cubit = _TestCubit(query: const _TestQuery(page: 2));
    final initialLoad = cubit.load();
    cubit.requests[0].complete(const Right(_TestPage([22])));
    await initialLoad;

    final deletion = cubit.delete(22);
    await Future<void>.delayed(Duration.zero);
    expect(cubit.deleteCalls, 1);
    expect(cubit.requestedQueries, hasLength(2));
    expect(cubit.requestedQueries.last.page, 1);

    cubit.requests[1].complete(const Right(_TestPage([11])));
    await deletion;
    expect(cubit.state.query.page, 1);
    expect(cubit.state.result!.items, [11]);
    await cubit.close();
  });

  test('an emptied later page after reload triggers a previous-page load',
      () async {
    final cubit = _TestCubit(query: const _TestQuery(page: 2));
    final initialLoad = cubit.load();
    cubit.requests[0].complete(const Right(_TestPage([21, 22])));
    await initialLoad;

    final deletion = cubit.delete(21);
    await Future<void>.delayed(Duration.zero);
    expect(cubit.requestedQueries.last.page, 2);
    cubit.requests[1].complete(const Right(_TestPage([])));
    await Future<void>.delayed(Duration.zero);

    expect(cubit.requestedQueries, hasLength(3));
    expect(cubit.requestedQueries.last.page, 1);
    cubit.requests[2].complete(const Right(_TestPage([10])));
    await deletion;
    expect(cubit.state.query.page, 1);
    await cubit.close();
  });

  test('clearFilters cancels the pending search timer and preserves sort', () {
    fakeAsync((async) {
      final cubit = _TestCubit(
        query: const _TestQuery(search: 'old', page: 3, filtered: true, sort: 4),
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

      cubit.requests.single.complete(const Right(_TestPage([1])));
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
    final cubit = _TestCubit(flashMessages: messages);
    final effects = cubit.effectStream.listen((_) => events.add('effect'));

    final initialLoad = cubit.load();
    cubit.requests[0].complete(const Right(_TestPage([4])));
    await initialLoad;

    final deletion = cubit.delete(4);
    await Future<void>.delayed(Duration.zero);
    cubit.requests[1].complete(const Right(_TestPage([])));
    await deletion;

    expect(events, ['flash', 'effect']);
    await effects.cancel();
    stopListening();
    await cubit.close();
  });

  test('responses completing after close do not emit another state', () async {
    final cubit = _TestCubit();
    var emissions = 0;
    final subscription = cubit.stream.listen((_) => emissions++);
    final load = cubit.load();
    await cubit.close();
    final atClose = emissions;
    cubit.requests.single.complete(const Right(_TestPage([1])));
    await load;

    expect(emissions, atClose);
    await subscription.cancel();
  });
}
