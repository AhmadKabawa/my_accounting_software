// lib/core/network/endpoints/app_endpoints.dart

// lib/core/network/endpoints/app_endpoint.dart

/// Wrapper خفيف — يُستخدم كـ String تماماً
/// لكن يجبر المطور يمر بـ AppEndpoints
extension type const AppEndpoint(String path) {
  @override
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
final class _AuthEndpoints {
  const _AuthEndpoints();
  static const String base = '/auth';
  AppEndpoint get login => const AppEndpoint('$base/login');
  AppEndpoint get getCurrentUser => const AppEndpoint('$base/getCurrentUser');
  AppEndpoint get register => const AppEndpoint('$base/register');
  AppEndpoint get logout => const AppEndpoint('$base/logout');
  AppEndpoint get refresh => const AppEndpoint('$base/refresh');
  AppEndpoint get forgotPass => const AppEndpoint('$base/forgot-password');
  AppEndpoint get resetPass => const AppEndpoint('$base/reset-password');
  AppEndpoint get verifyEmail => const AppEndpoint('$base/verify-email');
  AppEndpoint get googleSignIn => const AppEndpoint('$base/verify-email');
  AppEndpoint get sendResetCode => const AppEndpoint('$base/googleSignIn');
  AppEndpoint get verifyResetCode => const AppEndpoint('$base/logout');
  AppEndpoint get resetPassword => const AppEndpoint('$base/resetPassword');
  AppEndpoint get confirmNewPassword =>
      const AppEndpoint('$base/confirmNewPassword');
  AppEndpoint get changePassword => const AppEndpoint('$base/changePassword');
  AppEndpoint get updateProfile => const AppEndpoint('$base/updateProfile');
}

// ─────────────────────────────────────────────────────────────
// ─────────────────────────────────────────────────────────────
final class _ProductEndpoints {
  const _ProductEndpoints();
  static const String base = '/products';
  // قائمة ثابتة
  AppEndpoint get list => const AppEndpoint('$base');
  AppEndpoint get featured => const AppEndpoint('$base/featured');
  AppEndpoint get categories => const AppEndpoint('$base/categories');

  // دوال ديناميكية (باستثناء التحويل إلى AppEndpoint في الدالة نفسها)
  AppEndpoint byId(String id) => AppEndpoint('$base/$id');
  AppEndpoint reviews(String id) => AppEndpoint('$base/$id/reviews');
  AppEndpoint related(String id) => AppEndpoint('$base/$id/related');
  AppEndpoint byCategory(String category) =>
      AppEndpoint('$base/category/$category');
}
// ─────────────────────────────────────────────────────────────
 
// ─────────────────────────────────────────────────────────────
 


// import 'package:accounting_software/app/core/foundation/config/env_config.dart';

// /// API endpoints
// class ApiEndpoints {
//   static String baseUrl = EnvConfig.supabaseUrl;

//   // Auth endpoints (handled by Supabase SDK)
//   static const String login = '/auth/v1/token?grant_type=password';
//   static const String refreshToken = '/auth/v1/token?grant_type=refresh_token';

//   static const String register = '/auth/v1/signup';
//   static const String logout = '/auth/v1/logout';
//   static const String resetPassword = '/auth/v1/resetPassword';
//   static const String googleSignIn = '/auth/v1/googleSignIn';

//   static const String changePassword = '/auth/v1/changePassword';

//   static const String sendResetCode = '/auth/v1/sendResetCode';

//   static const String verifyResetCode = '/auth/v1/verifyResetCode';
//   static const String getCurrentUser = '/auth/v1/getCurrentUser';

//   static const String confirmNewPassword = '/auth/v1/confirmNewPassword';
//   static const String updateProfile = '/auth/v1/updateProfile';
//   static const String products = '/rest/v1/products';
//   static const String tickets = '/auth/v1/support_tickets';
//   static const String messages = '/auth/v1/messages';
//   static const String rpcSendMessage = '/auth/v1/rpc/send_message';
//   static const String rpcCreateTicket = '/auth/v1/messages';
// }
