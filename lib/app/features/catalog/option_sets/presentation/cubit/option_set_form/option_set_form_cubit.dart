import 'package:accounting_software/app/core/error/failures/failure.dart';
import 'package:accounting_software/app/core/localization/translations/app_key.dart';
import 'package:accounting_software/app/core/presentation/state_management/base_cubit.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_message/flash_messages.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_message/message_view_widgets.dart';
import 'package:accounting_software/app/features/catalog/option_sets/domain/entity/option_set_draft.dart';
import 'package:accounting_software/app/features/catalog/option_sets/domain/usecase/create_option_set_use_case.dart';
import 'package:accounting_software/app/features/catalog/option_sets/domain/usecase/update_option_set_use_case.dart';
import 'package:accounting_software/app/features/catalog/option_sets/presentation/cubit/option_set_form/option_set_form_effect.dart';
import 'package:accounting_software/app/features/catalog/option_sets/presentation/localization/option_sets_keys.dart';

enum OptionSetFormStatus { idle, saving }

class OptionSetFormCubit extends BaseCubit<OptionSetFormStatus, OptionSetFormEffect> {
  OptionSetFormCubit({
    required CreateOptionSetUseCase create,
    required UpdateOptionSetUseCase update,
    required FlashMessages flashMessages,
  }) : _create = create,
       _update = update,
       _flashMessages = flashMessages,
       super(OptionSetFormStatus.idle);

  final CreateOptionSetUseCase _create;
  final UpdateOptionSetUseCase _update;
  final FlashMessages _flashMessages;

  Future<void> save({required OptionSetDraft draft, int? id}) async {
    if (state == OptionSetFormStatus.saving || isClosed) return;
    emit(OptionSetFormStatus.saving);
    final result = id == null
        ? await _create(draft)
        : await _update(UpdateOptionSetParams(id: id, draft: draft));
    if (isClosed) return;
    result.fold(
      (failure) => emitEffect(OptionSetSaveFailedEffect(_messageKey(failure))),
      (set) {
        emitEffect(OptionSetSavedEffect(set.id));
        _flashMessages.post(OptionSetsKeys.saved, MessageType.success);
      },
    );
    if (!isClosed) emit(OptionSetFormStatus.idle);
  }

  AppKey _messageKey(Failure failure) => failure.messageKey;
}
