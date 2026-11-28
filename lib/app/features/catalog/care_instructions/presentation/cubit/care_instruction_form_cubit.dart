import 'package:equatable/equatable.dart';
import 'package:accounting_software/app/core/localization/translations/app_key.dart';
import 'package:accounting_software/app/core/presentation/state_management/base_cubit.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_message/flash_messages.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_message/message_view_widgets.dart';
import 'package:accounting_software/app/features/catalog/care_instructions/domain/entity/care_instruction_draft.dart';
import 'package:accounting_software/app/features/catalog/care_instructions/domain/failures/care_instruction_failures.dart';
import 'package:accounting_software/app/features/catalog/care_instructions/domain/usecase/create_care_instruction_use_case.dart';
import 'package:accounting_software/app/features/catalog/care_instructions/domain/usecase/update_care_instruction_use_case.dart';
import 'package:accounting_software/app/features/catalog/care_instructions/presentation/localization/care_instructions_keys.dart';

sealed class CareInstructionFormState extends Equatable {
  const CareInstructionFormState();
}

final class CareInstructionFormIdle extends CareInstructionFormState {
  const CareInstructionFormIdle();
  @override
  List<Object?> get props => [];
}

final class CareInstructionFormSaving extends CareInstructionFormState {
  const CareInstructionFormSaving();
  @override
  List<Object?> get props => [];
}

sealed class CareInstructionFormEffect {
  const CareInstructionFormEffect();
}

final class CareInstructionSavedEffect extends CareInstructionFormEffect {
  const CareInstructionSavedEffect();
}

final class CareInstructionSaveFailedEffect extends CareInstructionFormEffect {
  const CareInstructionSaveFailedEffect(this.messageKey);
  final AppKey messageKey;
}

class CareInstructionFormCubit
    extends BaseCubit<CareInstructionFormState, CareInstructionFormEffect> {
  CareInstructionFormCubit({
    required CreateCareInstructionUseCase create,
    required UpdateCareInstructionUseCase update,
    required FlashMessages flashMessages,
  }) : _create = create,
       _update = update,
       _flash = flashMessages,
       super(const CareInstructionFormIdle());

  final CreateCareInstructionUseCase _create;
  final UpdateCareInstructionUseCase _update;
  final FlashMessages _flash;

  Future<void> save({required CareInstructionDraft draft, int? id}) async {
    if (state is CareInstructionFormSaving || isClosed) return;
    emit(const CareInstructionFormSaving());
    final result = id == null
        ? await _create(draft)
        : await _update(UpdateCareInstructionParams(id, draft));
    if (isClosed) return;
    result.fold(
      (failure) => emitEffect(
        CareInstructionSaveFailedEffect(
          failure is CareInstructionDuplicateFailure
              ? CareInstructionsKeys.duplicateError
              : failure.messageKey,
        ),
      ),
      (_) {
        emitEffect(const CareInstructionSavedEffect());
        _flash.post(CareInstructionsKeys.saved, MessageType.success);
      },
    );
    if (!isClosed) emit(const CareInstructionFormIdle());
  }
}
