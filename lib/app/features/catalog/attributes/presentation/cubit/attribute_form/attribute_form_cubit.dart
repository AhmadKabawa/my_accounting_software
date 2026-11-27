import 'package:accounting_software/app/core/error/failures/failure.dart';
import 'package:accounting_software/app/core/presentation/state_management/base_cubit.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_message/flash_messages.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_message/message_view_widgets.dart';
import 'package:accounting_software/app/features/catalog/attributes/domain/entity/attribute_draft.dart';
import 'package:accounting_software/app/features/catalog/attributes/domain/usecase/create_attribute_use_case.dart';
import 'package:accounting_software/app/features/catalog/attributes/domain/usecase/update_attribute_use_case.dart';
import 'package:accounting_software/app/features/catalog/attributes/domain/usecase/update_attribute_use_case.dart' show UpdateAttributeParams;
import 'package:accounting_software/app/features/catalog/attributes/presentation/localization/attributes_keys.dart';

enum AttributeFormStatus { idle, saving }

sealed class AttributeFormEffect {
  const AttributeFormEffect();
}
class AttributeSavedEffect extends AttributeFormEffect {
  const AttributeSavedEffect(this.id);
  final int id;
}
class AttributeSaveFailedEffect extends AttributeFormEffect {
  const AttributeSaveFailedEffect(this.messageKey);
  final dynamic messageKey;
}

class AttributeFormCubit extends BaseCubit<AttributeFormStatus, AttributeFormEffect> {
  AttributeFormCubit({
    required CreateAttributeUseCase createAttribute,
    required UpdateAttributeUseCase updateAttribute,
    required FlashMessages flashMessages,
  }) : _create = createAttribute, _update = updateAttribute,
       _flash = flashMessages, super(AttributeFormStatus.idle);

  final CreateAttributeUseCase _create;
  final UpdateAttributeUseCase _update;
  final FlashMessages _flash;

  Future<void> save({required AttributeDraft draft, int? id}) async {
    if (isClosed || state == AttributeFormStatus.saving) return;
    emit(AttributeFormStatus.saving);
    final result = id == null ? await _create(draft) :
        await _update(UpdateAttributeParams(id: id, draft: draft));
    if (isClosed) return;
    result.fold(
      (failure) => emitEffect(AttributeSaveFailedEffect(failure.messageKey)),
      (attribute) {
        emitEffect(AttributeSavedEffect(attribute.id));
        _flash.post(AttributesKeys.saved, MessageType.success);
      },
    );
    if (!isClosed) emit(AttributeFormStatus.idle);
  }
}
