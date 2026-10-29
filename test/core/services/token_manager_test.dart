import 'package:accounting_software/app/core/services/local_storage/secure_storage/token_manager.dart';
import 'package:accounting_software/app/core/services/local_storage/storage_key.dart';
import 'package:accounting_software/app/core/services/local_storage/storage_keys.dart';
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
  sessionSignalTests();
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

/// Fails writes to one specific key.
class _KeyFailingStorage extends MemoryStorage {
  _KeyFailingStorage(this.failingKey);
  final StorageKey failingKey;

  @override
  Future<void> write<T>(StorageKey key, T value) async {
    if (key == failingKey) throw StateError('disk full');
    await super.write(key, value);
  }
}

void sessionSignalTests() {
  test('a failed login write rolls back WITHOUT signalling sessionCleared',
      () async {
    final tokens = TokenManager(storage: _FailingStorage(2));
    var signals = 0;
    tokens.sessionCleared.listen((_) => signals++);

    await expectLater(
      tokens.saveAuthTokens(accessToken: 'a', refreshToken: 'r', userId: 'u'),
      throwsStateError,
    );

    expect(await tokens.getAccessToken(), isNull);
    expect(signals, 0);
  });

  test('a failed refresh-token write keeps the new access token', () async {
    final storage = _KeyFailingStorage(StorageKeys.refreshToken);
    final tokens = TokenManager(storage: storage);
    storage.values[StorageKeys.accessToken] = 'old-access';
    storage.values[StorageKeys.refreshToken] = 'old-refresh';
    var signals = 0;
    tokens.sessionCleared.listen((_) => signals++);

    await tokens.saveTokens(accessToken: 'new-access', refreshToken: 'new-r');

    expect(await tokens.getAccessToken(), 'new-access');
    expect(await tokens.getRefreshToken(), 'old-refresh');
    expect(signals, 0);
  });

  test('a failed access-token write during refresh ends the session visibly',
      () async {
    final storage = _KeyFailingStorage(StorageKeys.accessToken);
    final tokens = TokenManager(storage: storage);
    storage.values[StorageKeys.refreshToken] = 'old-refresh';
    var signals = 0;
    tokens.sessionCleared.listen((_) => signals++);

    await expectLater(
      tokens.saveTokens(accessToken: 'new-access', refreshToken: 'new-r'),
      throwsStateError,
    );

    expect(await tokens.getRefreshToken(), isNull);
    expect(signals, 1);
  });
}
