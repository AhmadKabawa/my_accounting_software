import 'package:accounting_software/app/core/localization/translations/app_key.dart';

class FilterBarSortOption {
  const FilterBarSortOption({required this.key, required this.label});
  final String key;
  final AppKey label;
}

class FilterBarSort {
  const FilterBarSort(this.key, this.ascending);
  final String key;
  final bool ascending;

  @override
  bool operator ==(Object other) =>
      other is FilterBarSort && other.key == key && other.ascending == ascending;

  @override
  int get hashCode => Object.hash(key, ascending);
}

List<T> mapFilterBarSorts<F, T>(
  List<FilterBarSort> sorts, {
  required F? Function(String key) parse,
  required T Function(F field, bool ascending) build,
}) {
  final result = <T>[];
  for (final sort in sorts) {
    final field = parse(sort.key);
    if (field != null) result.add(build(field, sort.ascending));
  }
  return result;
}

List<FilterBarSort> toggleSort(
  List<FilterBarSort> current,
  String key,
  bool ascending, {
  int maxSorts = 0,
}) {
  final next = current.toList();
  final index = next.indexWhere((sort) => sort.key == key);
  if (index >= 0) { next[index] = FilterBarSort(key, ascending); return next; }
  final limit = maxSorts > 0 ? maxSorts : next.length + 1;
  if (next.length >= limit) return next;
  return [...next, FilterBarSort(key, ascending)];
}
