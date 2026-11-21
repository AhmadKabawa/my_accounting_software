import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:accounting_software/app/core/error/failures/failure.dart';
import 'package:accounting_software/app/features/auth/domain/usecase/force_change_password_usecase.dart';
import 'package:accounting_software/app/features/auth/presentation/cubit/session/session_cubit.dart';

enum ForcePasswordChangeStatus { idle, saving, completed }

class ForcePasswordChangeState extends Equatable {
  const ForcePasswordChangeState({
    this.status = ForcePasswordChangeStatus.idle,
    this.failure,
  });
  final ForcePasswordChangeStatus status;
  final Failure? failure;
  @override
  List<Object?> get props => [status, failure];
}

class ForcePasswordChangeCubit extends Cubit<ForcePasswordChangeState> {
  ForcePasswordChangeCubit({
    required ForceChangePasswordUseCase changePassword,
    required SessionCubit session,
  }) : _changePassword = changePassword,
       _session = session,
       super(const ForcePasswordChangeState());

  final ForceChangePasswordUseCase _changePassword;
  final SessionCubit _session;

  Future<void> submit(String newPassword) async {
    if (state.status == ForcePasswordChangeStatus.saving) return;
    emit(
      const ForcePasswordChangeState(status: ForcePasswordChangeStatus.saving),
    );
    final result = await _changePassword(
      ForceChangePasswordParams(newPassword: newPassword),
    );
    await result.fold<Future<void>>(
      (failure) async => emit(ForcePasswordChangeState(failure: failure)),
      (_) async {
        await _session.passwordChangeCompleted();
        if (!isClosed) {
          emit(
            const ForcePasswordChangeState(
              status: ForcePasswordChangeStatus.completed,
            ),
          );
        }
      },
    );
  }
}
