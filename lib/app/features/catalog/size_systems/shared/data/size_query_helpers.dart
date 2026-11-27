import 'package:accounting_software/app/core/network/postgrest_helpers.dart';
import 'package:accounting_software/app/features/catalog/size_systems/shared/domain/size_status_filter.dart';

/// PostgREST query fragments shared by the size data sources.
abstract final class SizeQueryHelpers {
  /// `or=(col.ilike."*term*",...)` or null for a blank search.
  static String? searchFilter(String raw, List<String> columns) {
    final term = PostgrestValue.escapeFilter(raw.trim());
    if (term.isEmpty) return null;
    return '(${columns.map((c) => '$c.ilike."*$term*"').join(',')})';
  }

  static String? statusFilter(SizeStatusFilter status) => switch (status) {
    SizeStatusFilter.all => null,
    SizeStatusFilter.active => 'eq.true',
    SizeStatusFilter.inactive => 'eq.false',
  };

  /// Primary sort plus an `id` tie-breaker so page boundaries stay stable.
  static String order(String column, bool ascending) =>
      '$column.${ascending ? 'asc' : 'desc'},id.asc';
}
