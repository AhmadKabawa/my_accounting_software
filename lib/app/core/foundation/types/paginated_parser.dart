import 'package:accounting_software/app/core/foundation/types/paginated_result.dart';

class PaginatedParser {
  const PaginatedParser({
    this.itemsKey = 'data',
    this.totalKey = 'totalCount',
    this.pageKey = 'currentPage',
    this.totalPagesKey = 'totalPages',
    this.isSupabase = false, // ← جديد
  });

  final String itemsKey;
  final String totalKey;
  final String pageKey;
  final String totalPagesKey;
  final bool isSupabase; // ← جديد

  PaginatedResult<T> parse<T>(
    dynamic data,
    T Function(dynamic) fromJson, {
    int page = 1,
    int limit = 20,
    int? totalFromHeader, // ← من content-range header
  }) {
    // ✅ Supabase returns List directly
    if (isSupabase || data is List) {
      final list = data as List;
      final total = totalFromHeader ?? list.length;
      final totalPages = (total / limit).ceil();

      return PaginatedResult<T>(
        items: list.map((e) => fromJson(e)).toList(),
        totalCount: total,
        currentPage: page,
        totalPages: totalPages == 0 ? 1 : totalPages,
      );
    }

    // ✅ Standard Map response
    final map = data as Map<String, dynamic>;
    final itemsRaw = map[itemsKey];
    if (itemsRaw == null) {
      throw FormatException('Key "$itemsKey" not found in response');
    }

    return PaginatedResult<T>(
      items: (itemsRaw as List).map((e) => fromJson(e)).toList(),
      totalCount: map[totalKey] as int? ?? 0,
      currentPage: map[pageKey] as int? ?? 1,
      totalPages: map[totalPagesKey] as int? ?? 1,
    );
  }
}

extension PaginatedParserPresets on PaginatedParser {
  static const standard = PaginatedParser();
  static const supabase = PaginatedParser(isSupabase: true); // ← جديد
  static const alternative = PaginatedParser(
    itemsKey: 'items',
    totalKey: 'total',
    pageKey: 'page',
    totalPagesKey: 'pages',
  );
  static const laravel = PaginatedParser(
    itemsKey: 'data',
    totalKey: 'total',
    pageKey: 'current_page',
    totalPagesKey: 'last_page',
  );
}
