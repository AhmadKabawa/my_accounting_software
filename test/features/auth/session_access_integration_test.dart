
import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:accounting_software/app/core/access/cubit/access_cubit.dart';
import 'package:accounting_software/app/core/access/domain/access_repository.dart';
import 'package:accounting_software/app/core/access/domain/get_my_access_usecase.dart';
import 'package:accounting_software/app/core/access/models/access_snapshot.dart';
import 'package:accounting_software/app/core/error/failures/failure.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_message/flash_messages.dart';
import 'package:accounting_software/app/features/auth/domain/usecase/get_cached_usecase.dart';
import 'package:accounting_software/app/features/auth/domain/usecase/get_must_change_password_usecase.dart';
import 'package:accounting_software/app/features/auth/domain/usecase/logout_usecase.dart';
import 'package:accounting_software/app/features/auth/domain/session/session_gate.dart';
import 'package:accounting_software/app/features/auth/presentation/cubit/session/session_cubit.dart';

import 'support/fake_auth_repository.dart';

class _AccessRepository implements AccessRepository {
  int calls = 0;
  Completer<Either<Failure, AccessSnapshot>>? pending;

  @override
  Future<Either<Failure, AccessSnapshot>> getMyAccess() async {
    calls++;
    final request = pending;
    if (request != null) return request.future;
    return const Right(
      AccessSnapshot(
        userId: 'u1',
        username: 'admin',
        email: null,
        isSuperAdmin: false,
        roles: [],
        permissions: {},
        branches: [],
        warehouses: [],
        posTerminals: [],
      ),
    );
  }
}

void main() {
  late StreamController<void> cleared;
  late FakeAuthRepository authRepository;
  late _AccessRepository accessRepository;
  late AccessCubit access;
  late SessionCubit session;

  setUp(() {
    cleared = StreamController<void>.broadcast(sync: true);
    authRepository = FakeAuthRepository();
    accessRepository = _AccessRepository();
    access = AccessCubit(getMyAccess: GetMyAccessUseCase(accessRepository));
    session = SessionCubit(
      getCurrentUser: GetCurrentUserUseCase(repository: authRepository),
      getMustChangePassword: GetMustChangePasswordUseCase(authRepository),
      logout: LogoutUseCase(repository: authRepository),
      sessionCleared: cleared.stream,
      flash: FlashMessages(),
      access: access,
    );
  });

  tearDown(() async {
    await session.close();
    await access.close();
    await cleared.close();
  });

  test('loads access after a restored authenticated session', () async {
    authRepository.currentUser = const Right(testUser);

    await session.checkAuthentication();
    await Future<void>.delayed(Duration.zero);

    expect(accessRepository.calls, 1);
    expect(access.state.isReady, isTrue);
  });

  test(
    'loads access after sign-in and clears it immediately on logout',
    () async {
      session.onAuthenticated(testUser);
      await Future<void>.delayed(Duration.zero);
      expect(access.state.isReady, isTrue);

      await session.signOut();
      expect(access.state.status, AccessStatus.initial);
      expect(access.state.snapshot, isNull);
    },
  );

  test(
    'password completion waits for refreshed access before releasing the gate',
    () async {
      authRepository.mustChangePassword = true;
      session.onAuthenticated(testUser);
      await Future<void>.delayed(Duration.zero);
      expect(
        (session.current as SessionAuthenticated).mustChangePassword,
        isTrue,
      );

      final pending = Completer<Either<Failure, AccessSnapshot>>();
      accessRepository.pending = pending;
      final completion = session.passwordChangeCompleted();
      await Future<void>.delayed(Duration.zero);

      expect(
        (session.current as SessionAuthenticated).mustChangePassword,
        isTrue,
      );
      expect(access.state.status, AccessStatus.loading);

      pending.complete(
        const Right(
          AccessSnapshot(
            userId: 'u1',
            username: 'admin',
            email: null,
            isSuperAdmin: false,
            roles: [],
            permissions: {},
            branches: [],
            warehouses: [],
            posTerminals: [],
          ),
        ),
      );
      await completion;

      expect(
        (session.current as SessionAuthenticated).mustChangePassword,
        isFalse,
      );
      expect(access.state.isReady, isTrue);
    },
  );

  test('sessionCleared clears the access snapshot', () async {
    session.onAuthenticated(testUser);
    await Future<void>.delayed(Duration.zero);
    expect(access.state.isReady, isTrue);

    cleared.add(null);
    expect(access.state.status, AccessStatus.initial);
    expect(access.state.snapshot, isNull);
  });
}
