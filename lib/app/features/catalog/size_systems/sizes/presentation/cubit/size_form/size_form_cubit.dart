import 'package:accounting_software/app/core/error/failures/failure.dart';
import 'package:accounting_software/app/core/localization/translations/app_key.dart';
import 'package:accounting_software/app/core/presentation/state_management/base_cubit.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_message/flash_messages.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_message/message_view_widgets.dart';
import 'package:accounting_software/app/features/catalog/size_systems/presentation/localization/size_systems_keys.dart';
import 'package:accounting_software/app/features/catalog/size_systems/shared/domain/failures/size_system_failures.dart';
import 'package:accounting_software/app/features/catalog/size_systems/sizes/domain/entity/catalog_size_draft.dart';
import 'package:accounting_software/app/features/catalog/size_systems/sizes/domain/usecase/sizes_use_cases.dart';
import 'package:accounting_software/app/features/catalog/size_systems/sizes/presentation/cubit/size_form/size_form_effect.dart';

enum SizeFormStatus { idle, saving }

class SizeFormCubit extends BaseCubit<SizeFormStatus, SizeFormEffect> {
  SizeFormCubit({
    required CreateSizeUseCase create,
    required UpdateSizeUseCase update,
    required FlashMessages flashMessages,
  }) : _create = create,
       _update = update,
       _flash = flashMessages,
       super(SizeFormStatus.idle);

  final CreateSizeUseCase _create;
  final UpdateSizeUseCase _update;
  final FlashMessages _flash;

  Future<void> save({required CatalogSizeDraft draft, int? id}) async {
    if (state == SizeFormStatus.saving || isClosed) return;
    emit(SizeFormStatus.saving);
    final result = id == null
        ? await _create(draft)
        : await _update(UpdateSizeParams(id: id, draft: draft));
    if (isClosed) return;
    result.fold(
      (failure) => emitEffect(SizeSaveFailedEffect(_key(failure))),
      (size) {
        emitEffect(SizeSavedEffect(size));
        _flash.post(SizeSystemsKeys.saved, MessageType.success);
      },
    );
    if (!isClosed) emit(SizeFormStatus.idle);
  }

  AppKey _key(Failure failure) => switch (failure) {
    SizeCodeDuplicateFailure() => SizeSystemsKeys.duplicateSize,
    _ => failure.messageKey,
  };
}
