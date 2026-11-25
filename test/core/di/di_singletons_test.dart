import 'package:accounting_software/app/core/di/service_locator.dart';
import 'package:accounting_software/app/core/network/api_end_points.dart';
import 'package:accounting_software/app/core/network/storage/storage_image_uploader.dart';
import 'package:accounting_software/app/core/storage/secure/token_manager.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues({});
    await sl.reset();
    await initCoreDI(refreshEndpoint: const AppEndpoint('/auth/v1/token'));
  });

  tearDown(() => sl.reset());

  test('TokenManager is a singleton', () {
    expect(identical(sl<TokenManager>(), sl<TokenManager>()), isTrue);
  });

  test('StorageImageUploader is registered as shared core infrastructure', () {
    expect(sl.isRegistered<StorageImageUploader>(), isTrue);
  });
}
