import 'package:accounting_software/app/core/error/failures/failure.dart';
import 'package:accounting_software/app/core/localization/translations/app_key.dart';
import 'package:accounting_software/app/core/presentation/state_management/base_cubit.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_message/flash_messages.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_message/message_view_widgets.dart';
import 'package:accounting_software/app/features/catalog/size_systems/groups/domain/entity/size_group_draft.dart';
import 'package:accounting_software/app/features/catalog/size_systems/groups/domain/usecase/size_groups_use_cases.dart';
import 'package:accounting_software/app/features/catalog/size_systems/groups/presentation/cubit/size_group_form/size_group_form_effect.dart';
import 'package:accounting_software/app/features/catalog/size_systems/presentation/localization/size_systems_keys.dart';
import 'package:accounting_software/app/features/catalog/size_systems/shared/domain/failures/size_system_failures.dart';

enum SizeGroupFormStatus { idle, saving }

class SizeGroupFormCubit
    extends BaseCubit<SizeGroupFormStatus, SizeGroupFormEffect> {
  SizeGroupFormCubit({
    required CreateSizeGroupUseCase create,
    required UpdateSizeGroupUseCase update,
    required FlashMessages flashMessages,
  }) : _create = create,
       _update = update,
       _flash = flashMessages,
       super(SizeGroupFormStatus.idle);

  final CreateSizeGroupUseCase _create;
  final UpdateSizeGroupUseCase _update;
  final FlashMessages _flash;

  Future<void> save({required SizeGroupDraft draft, int? id}) async {
    if (state == SizeGroupFormStatus.saving || isClosed) return;
    emit(SizeGroupFormStatus.saving);
    final result = id == null
        ? await _create(draft)
        : await _update(UpdateSizeGroupParams(id: id, draft: draft));
    if (isClosed) return;
    result.fold(
      (failure) => emitEffect(SizeGroupSaveFailedEffect(_key(failure))),
      (group) {
        emitEffect(SizeGroupSavedEffect(group));
        _flash.post(SizeSystemsKeys.saved, MessageType.success);
      },
    );
    if (!isClosed) emit(SizeGroupFormStatus.idle);
  }

  AppKey _key(Failure failure) => switch (failure) {
    SizeCodeDuplicateFailure() => SizeSystemsKeys.duplicateGroup,
    _ => failure.messageKey,
  };
}
