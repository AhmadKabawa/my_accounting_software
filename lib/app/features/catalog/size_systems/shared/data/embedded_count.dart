/// PostgREST returns an embedded count as `[{count: n}]`. Missing or malformed
/// relation data is unknown, not zero: the UI must not enable deletion.
int? readEmbeddedCount(dynamic value) {
  if (value is num) return value.toInt();
  if (value is Map<String, dynamic>) {
    final count = value['count'];
    return count is num ? count.toInt() : null;
  }
  if (value is List && value.isNotEmpty) {
    final first = value.first;
    if (first is Map<String, dynamic>) {
      final count = first['count'];
      return count is num ? count.toInt() : null;
    }
  }
  return null;
}

int? readInt(dynamic value) => value is int ? value : int.tryParse('$value');
