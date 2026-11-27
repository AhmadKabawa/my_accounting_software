import 'package:accounting_software/app/core/error/failures/failure.dart';
import 'package:accounting_software/app/core/localization/translations/app_key.dart';
import 'package:accounting_software/app/core/presentation/state_management/base_cubit.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_message/flash_messages.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_message/message_view_widgets.dart';
import 'package:accounting_software/app/features/catalog/product_types/domain/entity/product_type_draft.dart';
import 'package:accounting_software/app/features/catalog/product_types/domain/repositories/product_types_repository.dart';
import 'package:accounting_software/app/features/catalog/product_types/presentation/cubit/product_type_form/product_type_form_effect.dart';
import 'package:accounting_software/app/features/catalog/product_types/presentation/localization/product_types_keys.dart';

enum ProductTypeFormStatus { idle, saving }

class ProductTypeFormCubit
    extends BaseCubit<ProductTypeFormStatus, ProductTypeFormEffect> {
  ProductTypeFormCubit({
    required ProductTypesRepository repository,
    required FlashMessages flashMessages,
  }) : _repository = repository,
       _flashMessages = flashMessages,
       super(ProductTypeFormStatus.idle);

  final ProductTypesRepository _repository;
  final FlashMessages _flashMessages;

  Future<void> save({required ProductTypeDraft draft, int? id}) async {
    if (state == ProductTypeFormStatus.saving || isClosed) return;
    emit(ProductTypeFormStatus.saving);
    final result = id == null
        ? await _repository.create(draft)
        : await _repository.update(id: id, draft: draft);
    if (isClosed) return;

    result.fold(
      (failure) =>
          emitEffect(ProductTypeSaveFailedEffect(_messageKey(failure))),
      (productType) {
        emitEffect(ProductTypeSavedEffect(productType));
        _flashMessages.post(ProductTypesKeys.saved, MessageType.success);
      },
    );
    if (!isClosed) emit(ProductTypeFormStatus.idle);
  }

  AppKey _messageKey(Failure failure) => failure.messageKey;
}
