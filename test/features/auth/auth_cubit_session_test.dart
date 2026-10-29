import 'dart:async';

import 'package:accounting_software/app/core/error/error_handling/failure/failure.dart';
import 'package:accounting_software/app/features/auth/domain/entity/user/user_entity.dart';
import 'package:accounting_software/app/features/auth/domain/repositories/auth_repository.dart';
import 'package:accounting_software/app/features/auth/domain/usecase/change_password_usecase.dart';
import 'package:accounting_software/app/features/auth/domain/usecase/confirm_new_password_usecase.dart';
import 'package:accounting_software/app/features/auth/domain/usecase/get_cached_usecase.dart';
import 'package:accounting_software/app/features/auth/domain/usecase/login_usecase.dart';
import 'package:accounting_software/app/features/auth/domain/usecase/logout_usecase.dart';
import 'package:accounting_software/app/features/auth/domain/usecase/register_usecase.dart';
import 'package:accounting_software/app/features/auth/domain/usecase/reset_password_usecase.dart';
import 'package:accounting_software/app/features/auth/domain/usecase/send_reset_code_usecase.dart';
import 'package:accounting_software/app/features/auth/domain/usecase/signin_with_google_usecase.dart';
import 'package:accounting_software/app/features/auth/domain/usecase/update_profile_usecase.dart';
import 'package:accounting_software/app/features/auth/domain/usecase/verify_reset_code_usecase.dart';
import 'package:accounting_software/app/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:accounting_software/app/features/auth/presentation/cubit/effect/auth_effect.dart';
import 'package:accounting_software/app/features/auth/presentation/cubit/states/auth_states.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';

const _entity = UserEntity(id: 'u1', email: 'a@b.c');

class _FakeRepo implements AuthRepository {
  _FakeRepo(this.onLogout);
  final void Function() onLogout;
  Completer<Either<Failure, UserEntity>>? profile;

  @override
  Future<Either<Failure, Unit>> logout() async {
    onLogout();
    return const Right(unit);
  }

  Object? currentUserError;

  @override
  Future<Either<Failure, UserEntity?>> getCurrentUser() async {
    if (currentUserError != null) throw currentUserError!;
    return const Right(null);
  }

  @override
  Future<Either<Failure, UserEntity>> updateProfile({
    String? fullName,
    String? avatarUrl,
    String? phone,
  }) => profile!.future;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  late StreamController<void> session;
  late _FakeRepo repo;
  late AuthCubit cubit;
  late List<AuthEffect> effects;

  setUp(() {
    session = StreamController<void>.broadcast(sync: true);
    repo = _FakeRepo(() => session.add(null));
    cubit = AuthCubit(
      login: LoginUseCase(repository: repo),
      register: RegisterUseCase(repository: repo),
      logout: LogoutUseCase(repository: repo),
      sendResetCode: SendResetCodeUseCase(repository: repo),
      verifyResetCode: VerifyResetCodeUseCase(repository: repo),
      confirmNewPassword: ConfirmNewPasswordUseCase(repository: repo),
      resetPassword: ResetPasswordUseCase(repository: repo),
      changePassword: ChangePasswordUseCase(repository: repo),
      updateProfile: UpdateProfileUseCase(repository: repo),
      googleSignIn: SignInWithGoogleUseCase(repository: repo),
      getCurrentUserUseCase: GetCurrentUserUseCase(repository: repo),
      sessionCleared: session.stream,
    );
    effects = [];
    cubit.effectStream.listen(effects.add);
    // ignore: invalid_use_of_protected_member
    cubit.emit(const AuthState.authenticated(user: _entity));
  });

  tearDown(() async {
    await cubit.close();
    await session.close();
  });

  test('a cleared session moves Authenticated to Unauthenticated with an error',
      () async {
    session.add(null);
    await Future<void>.delayed(Duration.zero);

    expect(cubit.state, isA<Unauthenticated>());
    expect(effects, hasLength(1));
    expect(effects.single.toString(), contains('MessageType.error'));
  });

  test('a deliberate sign-out is not reported as an expired session', () async {
    await cubit.signOut();
    await Future<void>.delayed(Duration.zero);

    expect(cubit.state, isA<Unauthenticated>());
    expect(effects, hasLength(1));
    expect(effects.single.toString(), contains('MessageType.success'));
  });

  test('a session cleared during updateProfile is not overwritten', () async {
    repo.profile = Completer();
    final pending = cubit.updateProfile(fullName: 'x');
    expect(cubit.state, isA<AuthLoading>());

    session.add(null);
    repo.profile!.complete(Left(UnauthorizedFailure()));
    await pending;

    expect(cubit.state, isA<Unauthenticated>());
  });

  test('a throwing session check ends signed out, never stuck in checking',
      () async {
    // ignore: invalid_use_of_protected_member
    cubit.emit(const AuthState.initial());
    repo.currentUserError = StateError('boom');

    await cubit.checkAuthentication();

    expect(cubit.state, isA<Unauthenticated>());
  });
}
