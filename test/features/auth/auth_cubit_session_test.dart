import 'dart:async';

import 'package:accounting_software/app/core/error/error_handling/failure/failure.dart';
import 'package:accounting_software/app/core/presentation/widgets/message_view_widgets.dart';
import 'package:accounting_software/app/features/auth/domain/entity/auth_result/auth_result.dart';
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

/// Complete fake: every method the tests do not drive throws, so an
/// unexpected call fails loudly instead of being swallowed.
class _FakeRepo implements AuthRepository {
  _FakeRepo(this.onLogout);
  final void Function() onLogout;
  Completer<Either<Failure, UserEntity>>? profile;
  Either<Failure, UserEntity?> currentUser = const Right(null);
  Object? currentUserError;
  Object? logoutError;

  @override
  Future<Either<Failure, Unit>> logout() async {
    onLogout();
    if (logoutError != null) throw logoutError!;
    return const Right(unit);
  }

  @override
  Future<Either<Failure, UserEntity?>> getCurrentUser() async {
    if (currentUserError != null) throw currentUserError!;
    return currentUser;
  }

  @override
  Future<Either<Failure, UserEntity>> updateProfile({
    String? fullName,
    String? avatarUrl,
    String? phone,
  }) => profile!.future;

  @override
  Future<Either<Failure, AuthResultEntity>> login({
    required String email,
    required String password,
  }) => throw UnimplementedError('login');

  @override
  Future<Either<Failure, AuthResultEntity>> register({
    required String email,
    required String password,
    required String name,
    String? phone,
  }) => throw UnimplementedError('register');

  @override
  Future<Either<Failure, AuthResultEntity>> signInWithGoogle() =>
      throw UnimplementedError('signInWithGoogle');

  @override
  Future<Either<Failure, Unit>> sendResetCode({required String email}) =>
      throw UnimplementedError('sendResetCode');

  @override
  Future<Either<Failure, Unit>> verifyResetCode({
    required String email,
    required String code,
  }) => throw UnimplementedError('verifyResetCode');

  @override
  Future<Either<Failure, Unit>> confirmNewPassword({
    required String email,
    required String code,
    required String newPassword,
  }) => throw UnimplementedError('confirmNewPassword');

  @override
  Future<Either<Failure, Unit>> resetPassword({
    required String token,
    required String newPassword,
  }) => throw UnimplementedError('resetPassword');

  @override
  Future<Either<Failure, Unit>> changePassword({
    required String currentPassword,
    required String newPassword,
  }) => throw UnimplementedError('changePassword');
}

/// The effect's message type, read through the generated pattern matching
/// instead of parsing `toString()`.
MessageType? messageTypeOf(AuthEffect effect) =>
    effect.whenOrNull(showMessage: (_, type) => type);

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
    expect(messageTypeOf(effects.single), MessageType.error);
  });

  test('a deliberate sign-out is not reported as an expired session', () async {
    await cubit.signOut();
    await Future<void>.delayed(Duration.zero);

    expect(cubit.state, isA<Unauthenticated>());
    expect(effects, hasLength(1));
    expect(messageTypeOf(effects.single), MessageType.success);
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

  test('a throwing sign-out still ends signed out with an error', () async {
    repo.logoutError = StateError('boom');

    await cubit.signOut();
    await Future<void>.delayed(Duration.zero);

    expect(cubit.state, isA<Unauthenticated>());
    expect(effects, hasLength(1));
    expect(messageTypeOf(effects.single), MessageType.error);
  });

  test('a failed session check says why instead of failing silently',
      () async {
    // ignore: invalid_use_of_protected_member
    cubit.emit(const AuthState.initial());
    repo.currentUser = Left(NetworkFailure());

    await cubit.checkAuthentication();
    await Future<void>.delayed(Duration.zero);

    expect(cubit.state, isA<Unauthenticated>());
    expect(effects, hasLength(1));
    expect(messageTypeOf(effects.single), MessageType.error);
  });
}
