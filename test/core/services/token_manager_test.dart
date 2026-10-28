import 'package:accounting_software/app/core/services/local_storage/secure_storage/token_manager.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/memory_storage.dart';

void main() {
  late TokenManager tokens;
  late int cleared;

  setUp(() async {
    tokens = TokenManager(storage: MemoryStorage());
    cleared = 0;
    tokens.sessionCleared.listen((_) => cleared++);
    await tokens.saveAuthTokens(
      accessToken: 'a',
      refreshToken: 'r',
      userId: 'u',
    );
  });

  test('saving tokens does not signal a cleared session', () {
    expect(cleared, 0);
  });

  test('clearTokens removes the session and signals once', () async {
    await tokens.clearTokens();

    expect(await tokens.getAccessToken(), isNull);
    expect(await tokens.getRefreshToken(), isNull);
    expect(cleared, 1);
  });
}
