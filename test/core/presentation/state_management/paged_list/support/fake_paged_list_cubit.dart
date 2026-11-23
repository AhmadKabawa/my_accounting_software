import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:accounting_software/app/core/error/failures/failure.dart';
import 'package:accounting_software/app/core/foundation/types/paged_query.dart';
import 'package:accounting_software/app/core/foundation/types/paginated_result.dart';
import 'package:accounting_software/app/core/presentation/state_management/paged_list/paged_result.dart';
import 'package:accounting_software/app/core/localization/translations/app_key.dart';
import 'package:accounting_software/app/core/presentation/state_management/paged_list/paged_list_cubit.dart';
import 'package:accounting_software/app/core/foundation/types/bulk_result.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_message/flash_messages.dart';

enum TestPagedKey implements AppKey {
  loadError,
  deleted;

  @override
  String get key => 'test.$name';
  @override
  String get ar => name;
  @override
  String get en => name;
}

class TestPagedFailure extends Failure {
  const TestPagedFailure() : super(messageKey: TestPagedKey.loadError);
}

class TestPagedQuery implements PagedQuery<TestPagedQuery> {
  const TestPagedQuery({
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
  TestPagedQuery withSearch(String value) => TestPagedQuery(
    search: value,
    page: 1,
    pageSize: pageSize,
    filtered: filtered,
    sort: sort,
  );

  @override
  TestPagedQuery withPage(int value) => TestPagedQuery(
    search: search,
    page: value,
    pageSize: pageSize,
    filtered: filtered,
    sort: sort,
  );

  @override
  TestPagedQuery cleared() =>
      TestPagedQuery(page: 1, pageSize: pageSize, sort: sort);
}

class TestPagedPage extends PaginatedResult<int> {
  TestPagedPage(List<int> items)
    : super(
        items: items,
        totalCount: items.length,
        currentPage: 1,
        totalPages: 1,
      );
}

class TestPagedCubit
    extends PagedListCubit<int, TestPagedQuery, PagedMutationKind> {
  TestPagedCubit({
    TestPagedQuery query = const TestPagedQuery(),
    FlashMessages? flashMessages,
  }) : super(
         initialQuery: query,
         flashMessages: flashMessages ?? FlashMessages(),
       );

  final requests = <Completer<Either<Failure, PagedResult<int>>>>[];
  final requestedQueries = <TestPagedQuery>[];
  int deleteCalls = 0;

  Future<BulkResult<int>> bulkItems(
    Iterable<int> items,
    Future<Either<Failure, Unit>> Function(int item) action,
  ) => runBulk(
    items: items,
    action: action,
    kind: PagedMutationKind.updated,
    successMessage: TestPagedKey.deleted,
  );

  @override
  Future<Either<Failure, PagedResult<int>>> fetch(TestPagedQuery query) {
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
  AppKey get deletedMessageKey => TestPagedKey.deleted;

  @override
  PagedMutationKind buildMutationEffect(PagedMutationKind kind) => kind;
}
