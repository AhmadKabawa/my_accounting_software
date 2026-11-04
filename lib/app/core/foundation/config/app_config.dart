import 'package:accounting_software/app/core/foundation/config/env_config.dart';

/// المدخل الوحيد لإعدادات التطبيق: إعدادات البيئة (من `EnvConfig`) والثوابت
/// العامة. الميزات تقرأ من هنا ولا تستورد `EnvConfig` مباشرة.
///
/// كل القيم ثابتة بعد التهيئة (لا إسناد وقت التشغيل).
class AppConfig {
  AppConfig._();

  /// وضع التطبيق.
  static const AppMode appMode = AppMode.development;

  // App Info
  // TODO: اسم مؤقت (خطأ إملائي ولا يخص المشروع)؛ الاسم الرسمي بانتظار التأكيد.
  static const String appName = 'sports srore app';
  static const String appVersion = '1.0.0';

  // ════════════════════════════════════════════════════
  //  🔧 API CONFIG  ← غيّر هذا حسب الـ backend اللي ستستخدمه
  // ════════════════════════════════════════════════════
  static const String baseUrl = EnvConfig.supabaseUrl;
  static const String supabaseAnonKey = EnvConfig.supabaseAnonKey;

  /// OAuth client ID لـ Google Sign-In؛ null إن لم يُمرَّر (تُستخدم تهيئة المنصة).
  static String? get googleClientId => EnvConfig.googleClientId;

  /// يفشل مبكراً برسالة واضحة إن كانت إعدادات البيئة ناقصة (يُستدعى من main).
  static void ensureConfigured() => EnvConfig.ensureConfigured();

  // ── Timeouts ──────────────────────────────────────
  // Short on purpose: a network that is "connected" but has no internet
  // should report "no connection" within seconds, not after 30s.
  static const int connectTimeout = 10000;
  static const int receiveTimeout = 30000;
  static const int sendTimeout = 30000;

  // ════════════════════════════════════════════════════
  //  📄 Pagination
  // ════════════════════════════════════════════════════
  static const int defaultPageSize = 10;
  static const int defaultPage = 1;

  // ════════════════════════════════════════════════════
  //  🔁 Retry
  // ════════════════════════════════════════════════════
  static const int maxRetries = 3;
  static const int retryDelay = 1000;

  // Supported Languages
  static const List<String> supportedLanguages = ['ar', 'en'];

  // Default Language
  static const String defaultLanguage = 'ar';

  // Cache Duration
  static const Duration cacheValidDuration = Duration(hours: 24);

  // Image Placeholder
  static const String placeholderImage = 'assets/images/placeholder.png';

  // Animation Duration
  static const Duration animationDuration = Duration(milliseconds: 300);

  // Max Image Size (in MB)
  static const int maxImageSize = 5;

  // Date Formats
  static const String dateFormat = 'yyyy-MM-dd';
  static const String dateTimeFormat = 'yyyy-MM-dd HH:mm:ss';
  static const String displayDateFormat = 'dd/MM/yyyy';
}

enum AppMode { development, production }
