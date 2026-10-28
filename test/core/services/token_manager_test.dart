import 'package:accounting_software/app/core/services/local_storage/secure_storage/token_manager.dart';
import 'package:accounting_software/app/core/services/local_storage/storage_key.dart';
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

  partialFailureTests();
}

/// Fails the n-th write to simulate a partial failure.
class _FailingStorage extends MemoryStorage {
  _FailingStorage(this.failOnWrite);
  final int failOnWrite;
  int _writes = 0;

  @override
  Future<void> write<T>(StorageKey key, T value) async {
    if (++_writes == failOnWrite) throw StateError('disk full');
    await super.write(key, value);
  }
}

void partialFailureTests() {
  test('a failed write rolls the whole session back', () async {
    final tokens = TokenManager(storage: _FailingStorage(2));

    await expectLater(
      tokens.saveAuthTokens(accessToken: 'a', refreshToken: 'r', userId: 'u'),
      throwsStateError,
    );

    expect(await tokens.getAccessToken(), isNull);
    expect(await tokens.getRefreshToken(), isNull);
    expect(await tokens.getUserId(), isNull);
  });

  test('saveTokens replaces the refresh token only when one is given', () async {
    final tokens = TokenManager(storage: MemoryStorage());
    await tokens.saveAuthTokens(accessToken: 'a', refreshToken: 'r', userId: 'u');

    await tokens.saveTokens(accessToken: 'a2');
    expect(await tokens.getAccessToken(), 'a2');
    expect(await tokens.getRefreshToken(), 'r');

    await tokens.saveTokens(accessToken: 'a3', refreshToken: 'r3');
    expect(await tokens.getRefreshToken(), 'r3');
  });
}
