/// Minimal result contract shared by generic paginated-list state.
abstract interface class PagedResult<T> {
  List<T> get items;
  int get totalCount;
}
