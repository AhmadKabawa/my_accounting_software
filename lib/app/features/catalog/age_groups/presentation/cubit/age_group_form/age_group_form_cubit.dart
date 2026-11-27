import 'package:accounting_software/app/core/error/failures/failure.dart';
import 'package:accounting_software/app/core/localization/translations/app_key.dart';
import 'package:accounting_software/app/core/presentation/state_management/base_cubit.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_message/flash_messages.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_message/message_view_widgets.dart';
import 'package:accounting_software/app/features/catalog/age_groups/domain/entity/age_group_draft.dart';
import 'package:accounting_software/app/features/catalog/age_groups/domain/failures/age_group_failures.dart';
import 'package:accounting_software/app/features/catalog/age_groups/domain/failures/age_group_failure_keys.dart';
import 'package:accounting_software/app/features/catalog/age_groups/domain/usecase/age_groups_use_cases.dart';
import 'package:accounting_software/app/features/catalog/age_groups/presentation/cubit/age_group_form/age_group_form_effect.dart';
import 'package:accounting_software/app/features/catalog/age_groups/presentation/localization/age_groups_keys.dart';
enum AgeGroupFormStatus { idle, saving }
class AgeGroupFormCubit extends BaseCubit<AgeGroupFormStatus, AgeGroupFormEffect> {
  AgeGroupFormCubit({required CreateAgeGroupUseCase create, required UpdateAgeGroupUseCase update, required FlashMessages flashMessages})
    : _create=create, _update=update, _flash=flashMessages, super(AgeGroupFormStatus.idle);
  final CreateAgeGroupUseCase _create; final UpdateAgeGroupUseCase _update; final FlashMessages _flash;
  Future<void> save({required AgeGroupDraft draft, int? id}) async {
    if (state == AgeGroupFormStatus.saving || isClosed) return;
    emit(AgeGroupFormStatus.saving);
    final result=id==null ? await _create(draft) : await _update(UpdateAgeGroupParams(id:id,draft:draft));
    if (isClosed) return;
    result.fold((f)=>emitEffect(AgeGroupSaveFailedEffect(_key(f))), (item) {
      emitEffect(AgeGroupSavedEffect(item)); _flash.post(AgeGroupsKeys.saved, MessageType.success);
    });
    if (!isClosed) emit(AgeGroupFormStatus.idle);
  }
  AppKey _key(Failure f) => switch(f) {
    AgeGroupDuplicateFailure()=>AgeGroupFailureKeys.duplicate,
    AgeGroupInvalidRangeFailure()=>AgeGroupFailureKeys.invalidRange,
    AgeGroupInUseFailure()=>AgeGroupFailureKeys.inUse,
    AgeGroupUsageUnknownFailure()=>AgeGroupFailureKeys.usageUnknown,
    _=>f.messageKey,
  };
}
