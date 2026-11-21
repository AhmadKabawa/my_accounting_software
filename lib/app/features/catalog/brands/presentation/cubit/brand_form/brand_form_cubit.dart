import 'package:accounting_software/app/core/error/failures/failure.dart';
import 'package:accounting_software/app/core/localization/translations/app_key.dart';
import 'package:accounting_software/app/core/presentation/state_management/base_cubit.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_message/flash_messages.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_message/message_view_widgets.dart';
import 'package:accounting_software/app/features/catalog/brands/domain/entity/brand_draft.dart';
import 'package:accounting_software/app/features/catalog/brands/domain/failures/brand_failures.dart';
import 'package:accounting_software/app/features/catalog/brands/domain/usecase/create_brand_use_case.dart';
import 'package:accounting_software/app/features/catalog/brands/domain/usecase/update_brand_use_case.dart';
import 'package:accounting_software/app/features/catalog/brands/presentation/cubit/brand_form/brand_form_effect.dart';
import 'package:accounting_software/app/features/catalog/brands/presentation/localization/brands_keys.dart';

enum BrandFormStatus { idle, saving }

class BrandFormCubit extends BaseCubit<BrandFormStatus, BrandFormEffect> {
  BrandFormCubit({
    required CreateBrandUseCase createBrand,
    required UpdateBrandUseCase updateBrand,
    required FlashMessages flashMessages,
  }) : _createBrand = createBrand,
       _updateBrand = updateBrand,
       _flashMessages = flashMessages,
       super(BrandFormStatus.idle);

  final CreateBrandUseCase _createBrand;
  final UpdateBrandUseCase _updateBrand;
  final FlashMessages _flashMessages;

  Future<void> save({required BrandDraft draft, int? id}) async {
    if (state == BrandFormStatus.saving || isClosed) return;

    emit(BrandFormStatus.saving);
    final result = id == null
        ? await _createBrand(draft)
        : await _updateBrand(UpdateBrandParams(id: id, draft: draft));
    if (isClosed) return;

    result.fold(
      (failure) {
        emitEffect(BrandSaveFailedEffect(_messageKey(failure)));
      },
      (brand) {
        emitEffect(BrandSavedEffect(brand));
        _flashMessages.post(BrandsKeys.saved, MessageType.success);
      },
    );
    if (!isClosed) emit(BrandFormStatus.idle);
  }

  AppKey _messageKey(Failure failure) => switch (failure) {
    BrandDuplicateFailure() => BrandsKeys.duplicateError,
    _ => failure.messageKey,
  };
}
