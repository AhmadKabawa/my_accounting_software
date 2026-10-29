import 'package:flutter/material.dart';
import 'package:accounting_software/app/core/foundation/config/env_config.dart';

// مغير مستخدم بالكامل حاجة لتطوير
class AppConfig {
  /// Development Mode
  static AppMode appMode = AppMode.development;
  // App Info
  static const String appName = 'sports srore app';
  static const String appVersion = '1.0.0';

  // // Screen Util Design Size
  // static const Size designSize = Size(375, 812);
  // static const Size mobileDesignSize = Size(375, 812);
  // static const Size tabletDesignSize = Size(700, 1024);
  // static const Size desktopDesignSize = Size(1000, 900);

  // static Size designSizeWithContext(BuildContext context) {
  //   if (ScreenEngine.isDesktop(context)) {
  //     return desktopDesignSize;
  //   } else if (ScreenEngine.isTablet(context)) {
  //     return tabletDesignSize;
  //   } else {
  //     return mobileDesignSize;
  //   }
  // }

  // ════════════════════════════════════════════════════
  //  🔧 API CONFIG  ← غيّر هذا حسب الـ backend اللي ستستخدمه
  // ════════════════════════════════════════════════════
  static String baseUrl = EnvConfig.supabaseUrl;
  static String supabaseAnonKey = EnvConfig.supabaseAnonKey;

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

  // Pagination
  static const int itemsPerPage = 20;

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
