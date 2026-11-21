/// Small helpers shared by every PostgREST data source.
abstract final class PostgrestValue {
  /// Escapes a user-typed value so it can sit inside a quoted filter such as
  /// `name.ilike."*value*"`. Backslash and quote are escaped; `*` stays a
  /// wildcard (see the audit item S-1 for `%` and `_`).
  static String escapeFilter(String value) =>
      value.replaceAll(r'\', r'\\').replaceAll('"', r'\"');

  /// The trimmed text, or null when it is blank (empty columns are stored as
  /// NULL, not as an empty string).
  static String? nullableTrim(String? value) {
    final trimmed = value?.trim() ?? '';
    return trimmed.isEmpty ? null : trimmed;
  }

  /// The only row of a `Prefer: return=representation` response.
  static T single<T>(
    List<dynamic> rows,
    T Function(Map<String, dynamic> json) fromJson, {
    required String what,
  }) {
    if (rows.length != 1 || rows.single is! Map<String, dynamic>) {
      throw FormatException('Expected one $what from PostgREST');
    }
    return fromJson(rows.single as Map<String, dynamic>);
  }
}
