import 'package:accounting_software/app/core/error/failures/failure.dart';
import 'package:accounting_software/app/core/localization/translations/app_key.dart';
import 'package:accounting_software/app/core/presentation/state_management/base_cubit.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_message/flash_messages.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_message/message_view_widgets.dart';
import 'package:accounting_software/app/features/catalog/size_systems/presentation/localization/size_systems_keys.dart';
import 'package:accounting_software/app/features/catalog/size_systems/shared/domain/failures/size_system_failures.dart';
import 'package:accounting_software/app/features/catalog/size_systems/systems/domain/entity/size_system_draft.dart';
import 'package:accounting_software/app/features/catalog/size_systems/systems/domain/usecase/size_systems_use_cases.dart';
import 'package:accounting_software/app/features/catalog/size_systems/systems/presentation/cubit/size_system_form/size_system_form_effect.dart';

enum SizeSystemFormStatus { idle, saving }

class SizeSystemFormCubit
    extends BaseCubit<SizeSystemFormStatus, SizeSystemFormEffect> {
  SizeSystemFormCubit({
    required CreateSizeSystemUseCase create,
    required UpdateSizeSystemUseCase update,
    required FlashMessages flashMessages,
  }) : _create = create,
       _update = update,
       _flash = flashMessages,
       super(SizeSystemFormStatus.idle);

  final CreateSizeSystemUseCase _create;
  final UpdateSizeSystemUseCase _update;
  final FlashMessages _flash;

  Future<void> save({required SizeSystemDraft draft, int? id}) async {
    if (state == SizeSystemFormStatus.saving || isClosed) return;
    emit(SizeSystemFormStatus.saving);
    final result = id == null
        ? await _create(draft)
        : await _update(UpdateSizeSystemParams(id: id, draft: draft));
    if (isClosed) return;
    result.fold(
      (failure) => emitEffect(SizeSystemSaveFailedEffect(_key(failure))),
      (system) {
        emitEffect(SizeSystemSavedEffect(system));
        _flash.post(SizeSystemsKeys.saved, MessageType.success);
      },
    );
    if (!isClosed) emit(SizeSystemFormStatus.idle);
  }

  AppKey _key(Failure failure) => switch (failure) {
    SizeCodeDuplicateFailure() => SizeSystemsKeys.duplicateSystem,
    _ => failure.messageKey,
  };
}
