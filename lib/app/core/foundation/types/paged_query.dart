/// Domain-safe contract for a paginated list query.
///
/// Kept in foundation so domain query objects can implement it without
/// depending on presentation/state-management.
abstract interface class PagedQuery<Q extends PagedQuery<Q>> {
  String get search;
  int get page;
  int get pageSize;

  /// True when search or a non-default filter is active.
  bool get hasActiveFilters;

  /// Returns the query with the new search and page reset to 1.
  Q withSearch(String value);

  /// Returns the query with the requested page.
  Q withPage(int value);

  /// Clears search and filters, resets page, and preserves sorting.
  Q cleared();
}
