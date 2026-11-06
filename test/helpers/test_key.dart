import 'package:accounting_software/app/core/localization/translations/app_key.dart';

/// Minimal [AppKey] for tests that need an arbitrary key.
class TestKey implements AppKey {
  const TestKey(this.key);

  @override
  final String key;

  @override
  String get ar => key;

  @override
  String get en => key;
}
