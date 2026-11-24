import 'package:flutter_test/flutter_test.dart';
import 'package:accounting_software/app/core/error/failures/failure.dart';
import 'package:accounting_software/app/core/foundation/types/paged_query.dart';
import 'package:accounting_software/app/core/foundation/types/paginated_result.dart';
import 'package:accounting_software/app/core/presentation/state_management/paged_list/paged_list_state.dart';
import 'package:accounting_software/app/core/presentation/widgets/crud_list/crud_list_config.dart';

void main() {
  const query = _TestQuery();

  group('CrudListStateView', () {
    test('projects initial loading without rows or failures', () {
      final view = CrudListStateView<int, _TestQuery>.from(
        const PagedListState<int, _TestQuery>(
          query: query,
          status: PagedListStatus.loading,
        ),
      );
      expect(view.loading, isTrue);
      expect(view.refreshing, isFalse);
      expect(view.rows, isEmpty);
      expect(view.total, 0);
      expect(view.failure, isNull);
      expect(view.refreshFailure, isNull);
    });

    test('projects first-load failure as a page failure', () {
      const failure = NetworkFailure();
      final view = CrudListStateView<int, _TestQuery>.from(
        const PagedListState<int, _TestQuery>(
          query: query,
          status: PagedListStatus.failed,
          failure: failure,
        ),
      );
      expect(view.loading, isFalse);
      expect(view.failure, same(failure));
      expect(view.refreshFailure, isNull);
      expect(view.rows, isEmpty);
    });

    test('preserves stale rows and separates refresh failure', () {
      const failure = NetworkFailure();
      const result = PaginatedResult<int>(
        items: [4, 8],
        totalCount: 12,
        currentPage: 1,
        totalPages: 6,
      );
      final view = CrudListStateView<int, _TestQuery>.from(
        const PagedListState<int, _TestQuery>(
          query: query,
          status: PagedListStatus.failed,
          result: result,
          failure: failure,
        ),
      );
      expect(view.loading, isFalse);
      expect(view.rows, [4, 8]);
      expect(view.total, 12);
      expect(view.failure, isNull);
      expect(view.refreshFailure, same(failure));
    });

    test('projects active refresh while preserving current data', () {
      const result = PaginatedResult<int>(
        items: [3],
        totalCount: 1,
        currentPage: 1,
        totalPages: 1,
      );
      final view = CrudListStateView<int, _TestQuery>.from(
        const PagedListState<int, _TestQuery>(
          query: query,
          status: PagedListStatus.refreshing,
          result: result,
        ),
      );
      expect(view.refreshing, isTrue);
      expect(view.rows, [3]);
      expect(view.failure, isNull);
      expect(view.refreshFailure, isNull);
    });

    test('projects successful empty content without a failure', () {
      const result = PaginatedResult<int>(
        items: [],
        totalCount: 0,
        currentPage: 1,
        totalPages: 0,
      );
      final view = CrudListStateView<int, _TestQuery>.from(
        const PagedListState<int, _TestQuery>(
          query: query,
          status: PagedListStatus.ready,
          result: result,
        ),
      );
      expect(view.loading, isFalse);
      expect(view.rows, isEmpty);
      expect(view.total, 0);
      expect(view.failure, isNull);
      expect(view.refreshFailure, isNull);
    });
  });
}

class _TestQuery implements PagedQuery<_TestQuery> {
  const _TestQuery();
  @override
  String get search => '';
  @override
  int get page => 1;
  @override
  int get pageSize => 20;
  @override
  bool get hasActiveFilters => false;
  @override
  _TestQuery withSearch(String value) => this;
  @override
  _TestQuery withPage(int value) => this;
  @override
  _TestQuery cleared() => this;
}
