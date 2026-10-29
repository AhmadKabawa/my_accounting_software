// lib/core/network/endpoints/app_endpoints.dart

// lib/core/network/endpoints/app_endpoint.dart

/// Wrapper خفيف — يُستخدم كـ String تماماً
/// لكن يجبر المطور يمر بـ AppEndpoints
extension type const AppEndpoint(String path) {
  String toStringPath() => path;
}

abstract final class AppEndpoints {
  // ── Auth ──────────────────────────────────────
  static const auth = _AuthEndpoints();

  // ── Products ──────────────────────────────────
  static const products = _ProductEndpoints();

  // ── Orders ────────────────────────────────────
  // static const orders = _OrderEndpoints();

  // // ── User ──────────────────────────────────────
  // static const user = _UserEndpoints();
}

// ─────────────────────────────────────────────────────────────
/// Supabase Auth (GoTrue) endpoints.
/// Flows that share a path are selected with a query parameter:
/// `token` → `grant_type=password | refresh_token | id_token`.
final class _AuthEndpoints {
  const _AuthEndpoints();
  static const String base = '/auth/v1';
  AppEndpoint get token => const AppEndpoint('$base/token');
  AppEndpoint get signup => const AppEndpoint('$base/signup');
  AppEndpoint get logout => const AppEndpoint('$base/logout');
  AppEndpoint get user => const AppEndpoint('$base/user');
  AppEndpoint get recover => const AppEndpoint('$base/recover');
  AppEndpoint get verify => const AppEndpoint('$base/verify');
}

// ─────────────────────────────────────────────────────────────
final class _ProductEndpoints {
  const _ProductEndpoints();
  static const String base = '/products';
  // قائمة ثابتة
  AppEndpoint get list => const AppEndpoint('$base');
  AppEndpoint get featured => const AppEndpoint('$base/featured');
  AppEndpoint get categories => const AppEndpoint('$base/categories');

  // دوال ديناميكية (باستثناء التحويل إلى AppEndpoint في الدالة نفسها)
  // المعاملات تُرمَّز دائمًا حتى لا يغيّر `/` أو `?` أو `#` في القيمة بنية المسار.
  AppEndpoint byId(String id) => AppEndpoint('$base/${_seg(id)}');
  AppEndpoint reviews(String id) => AppEndpoint('$base/${_seg(id)}/reviews');
  AppEndpoint related(String id) => AppEndpoint('$base/${_seg(id)}/related');
  AppEndpoint byCategory(String category) =>
      AppEndpoint('$base/category/${_seg(category)}');

  /// Encodes one dynamic path segment. `.` and `..` are rejected: they are not
  /// touched by percent-encoding, so `/products/..` could be normalised by a
  /// proxy or resolver into a different resource.
  static String _seg(String value) {
    if (value == '.' || value == '..') {
      throw ArgumentError.value(
        value,
        'value',
        'A path segment cannot be "." or ".."',
      );
    }
    return Uri.encodeComponent(value);
  }
}
// ─────────────────────────────────────────────────────────────
 
// ─────────────────────────────────────────────────────────────
