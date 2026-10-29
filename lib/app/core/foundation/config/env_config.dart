import 'package:flutter/foundation.dart' show kIsWeb, visibleForTesting;

/// Client-side configuration, injected at build time:
/// `flutter run --dart-define-from-file=config/dart_defines.json`.
///
/// Only public client values belong here (Supabase URL, anon key, Google
/// client ID). The anon key is
/// not a secret (access is enforced by RLS); the service_role key must never
/// be placed in the client or in this repository.
class EnvConfig {
  static const String supabaseUrl = String.fromEnvironment('SUPABASE_URL');
  static const String supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
  );

  /// OAuth client ID for Google Sign-In. Optional: null when not provided,
  /// in which case the platform's own configuration is used.
  static const String _googleClientId = String.fromEnvironment(
    'GOOGLE_CLIENT_ID',
  );
  static String? get googleClientId =>
      _googleClientId.isEmpty ? null : _googleClientId;

  /// Fails fast with a clear message instead of failing later and silently:
  /// requests to an empty URL, or a Google button that does nothing on Web.
  static void ensureConfigured() => validate(
    supabaseUrl: supabaseUrl,
    supabaseAnonKey: supabaseAnonKey,
    googleClientId: _googleClientId,
    isWeb: kIsWeb,
  );

  @visibleForTesting
  static void validate({
    required String supabaseUrl,
    required String supabaseAnonKey,
    required String googleClientId,
    required bool isWeb,
  }) {
    if (supabaseUrl.isEmpty || supabaseAnonKey.isEmpty) {
      throw StateError(
        'Missing SUPABASE_URL / SUPABASE_ANON_KEY. Run with '
        '--dart-define-from-file=config/dart_defines.json '
        '(see config/dart_defines.example.json).',
      );
    }
    // google_sign_in on Web cannot work without an OAuth client ID.
    if (isWeb && googleClientId.isEmpty) {
      throw StateError(
        'Missing GOOGLE_CLIENT_ID. Google Sign-In on Web requires an OAuth '
        'client ID: set it in config/dart_defines.json '
        '(see README.md, "Configuration").',
      );
    }
  }
}
