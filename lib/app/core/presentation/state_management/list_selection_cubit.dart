import 'package:flutter_bloc/flutter_bloc.dart';

enum PageSelectionState { none, partial, all }

/// Tracks selected record IDs for the currently visible list page.
class ListSelectionCubit<ID> extends Cubit<Set<ID>> {
  ListSelectionCubit() : super(Set<ID>.unmodifiable(<ID>{}));

  bool isSelected(ID id) => state.contains(id);
  int get count => state.length;

  PageSelectionState pageState(Iterable<ID> pageIds) {
    final ids = pageIds.toSet();
    if (ids.isEmpty) return PageSelectionState.none;
    final selectedCount = ids.where(state.contains).length;
    if (selectedCount == 0) return PageSelectionState.none;
    if (selectedCount == ids.length) return PageSelectionState.all;
    return PageSelectionState.partial;
  }

  void toggle(ID id) {
    final next = Set<ID>.of(state);
    if (!next.add(id)) next.remove(id);
    _emit(next);
  }

  void selectPage(Iterable<ID> ids) {
    final next = Set<ID>.of(state)..addAll(ids);
    _emit(next);
  }

  void clear() {
    if (state.isEmpty) return;
    _emit(<ID>{});
  }

  void _emit(Set<ID> next) => emit(Set<ID>.unmodifiable(next));
}
