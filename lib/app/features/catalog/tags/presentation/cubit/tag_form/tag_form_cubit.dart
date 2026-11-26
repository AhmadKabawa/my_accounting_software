import 'package:accounting_software/app/core/error/failures/failure.dart';
import 'package:accounting_software/app/core/localization/translations/app_key.dart';
import 'package:accounting_software/app/core/presentation/state_management/base_cubit.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_message/flash_messages.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_message/message_view_widgets.dart';
import 'package:accounting_software/app/features/catalog/tags/domain/entity/catalog_tag_draft.dart';
import 'package:accounting_software/app/features/catalog/tags/domain/failures/tag_failures.dart';
import 'package:accounting_software/app/features/catalog/tags/domain/usecase/create_tag_use_case.dart';
import 'package:accounting_software/app/features/catalog/tags/domain/usecase/update_tag_use_case.dart';
import 'package:accounting_software/app/features/catalog/tags/presentation/cubit/tag_form/tag_form_effect.dart';
import 'package:accounting_software/app/features/catalog/tags/presentation/localization/tags_keys.dart';

enum TagFormStatus { idle, saving }

class TagFormCubit extends BaseCubit<TagFormStatus, TagFormEffect> {
  TagFormCubit({
    required CreateTagUseCase createTag,
    required UpdateTagUseCase updateTag,
    required FlashMessages flashMessages,
  }) : _createTag = createTag,
       _updateTag = updateTag,
       _flashMessages = flashMessages,
       super(TagFormStatus.idle);

  final CreateTagUseCase _createTag;
  final UpdateTagUseCase _updateTag;
  final FlashMessages _flashMessages;

  Future<void> save({required CatalogTagDraft draft, int? id}) async {
    if (state == TagFormStatus.saving || isClosed) return;

    emit(TagFormStatus.saving);
    final result = id == null
        ? await _createTag(draft)
        : await _updateTag(UpdateTagParams(id: id, draft: draft));
    if (isClosed) return;

    result.fold(
      (failure) {
        emitEffect(TagSaveFailedEffect(_messageKey(failure)));
      },
      (tag) {
        emitEffect(TagSavedEffect(tag));
        _flashMessages.post(TagsKeys.saved, MessageType.success);
      },
    );
    if (!isClosed) emit(TagFormStatus.idle);
  }

  AppKey _messageKey(Failure failure) => switch (failure) {
    TagDuplicateFailure() => TagsKeys.duplicateError,
    _ => failure.messageKey,
  };
}
