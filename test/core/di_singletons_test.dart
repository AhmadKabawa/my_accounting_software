import 'package:accounting_software/app/core/di/service_locator.dart';
import 'package:accounting_software/app/core/services/local_storage/secure_storage/token_manager.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues({});
    await sl.reset();
    await initCoreDI();
  });

  tearDown(() => sl.reset());

  // AuthCubit listens to TokenManager.sessionCleared. If the locator ever
  // built a new TokenManager per call, the cubit would listen to a stream
  // nobody emits on and "session expired" would silently never show.
  test('TokenManager is a singleton', () {
    expect(identical(sl<TokenManager>(), sl<TokenManager>()), isTrue);
  });
}
