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

  /// Fails fast with a clear message instead of sending requests to an empty URL.
  static void ensureConfigured() {
    if (supabaseUrl.isEmpty || supabaseAnonKey.isEmpty) {
      throw StateError(
        'Missing SUPABASE_URL / SUPABASE_ANON_KEY. Run with '
        '--dart-define-from-file=config/dart_defines.json '
        '(see config/dart_defines.example.json).',
      );
    }
  }
}
