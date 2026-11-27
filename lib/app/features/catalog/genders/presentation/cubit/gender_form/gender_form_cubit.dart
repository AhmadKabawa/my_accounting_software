import 'package:accounting_software/app/core/error/failures/failure.dart';
import 'package:accounting_software/app/core/localization/translations/app_key.dart';
import 'package:accounting_software/app/core/presentation/state_management/base_cubit.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_message/flash_messages.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_message/message_view_widgets.dart';
import 'package:accounting_software/app/features/catalog/genders/domain/entity/gender_draft.dart';
import 'package:accounting_software/app/features/catalog/genders/domain/failures/gender_failures.dart';\nimport 'package:accounting_software/app/features/catalog/genders/domain/failures/gender_failure_keys.dart';
import 'package:accounting_software/app/features/catalog/genders/domain/usecase/create_gender_use_case.dart';
import 'package:accounting_software/app/features/catalog/genders/domain/usecase/update_gender_use_case.dart';
import 'package:accounting_software/app/features/catalog/genders/presentation/cubit/gender_form/gender_form_effect.dart';
import 'package:accounting_software/app/features/catalog/genders/presentation/localization/genders_keys.dart';

enum GenderFormStatus { idle, saving }

class GenderFormCubit extends BaseCubit<GenderFormStatus, GenderFormEffect> {
  GenderFormCubit({
    required CreateGenderUseCase create,
    required UpdateGenderUseCase update,
    required FlashMessages flashMessages,
  }) : _create = create,
       _update = update,
       _flash = flashMessages,
       super(GenderFormStatus.idle);

  final CreateGenderUseCase _create;
  final UpdateGenderUseCase _update;
  final FlashMessages _flash;

  Future<void> save({required GenderDraft draft, int? id}) async {
    if (state == GenderFormStatus.saving || isClosed) return;
    emit(GenderFormStatus.saving);
    final result = id == null
        ? await _create(draft)
        : await _update(UpdateGenderParams(id: id, draft: draft));
    if (isClosed) return;
    result.fold(
      (failure) => emitEffect(GenderSaveFailedEffect(_key(failure))),
      (gender) {
        emitEffect(GenderSavedEffect(gender));
        _flash.post(GendersKeys.saved, MessageType.success);
      },
    );
    if (!isClosed) emit(GenderFormStatus.idle);
  }

  AppKey _key(Failure failure) => switch (failure) {
    GenderDuplicateFailure() => GendersKeys.duplicateError,
    GenderInUseFailure() => GenderFailureKeys.inUse,
    GenderUsageUnknownFailure() => GenderFailureKeys.usageUnknown,
    _ => failure.messageKey,
  };
}
