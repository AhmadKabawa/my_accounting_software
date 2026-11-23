/// The subset of a paginated result needed by shared list state and behavior.
abstract interface class PagedResult<T> {
  List<T> get items;
  int get totalCount;
}
