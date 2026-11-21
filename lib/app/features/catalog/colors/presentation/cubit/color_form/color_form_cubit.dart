import 'package:accounting_software/app/core/error/failures/failure.dart';
import 'package:accounting_software/app/core/localization/translations/app_key.dart';
import 'package:accounting_software/app/core/presentation/state_management/base_cubit.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_message/flash_messages.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_message/message_view_widgets.dart';
import 'package:accounting_software/app/features/catalog/colors/domain/entity/catalog_color_draft.dart';
import 'package:accounting_software/app/features/catalog/colors/domain/failures/color_failures.dart';
import 'package:accounting_software/app/features/catalog/colors/domain/usecase/create_color_use_case.dart';
import 'package:accounting_software/app/features/catalog/colors/domain/usecase/update_color_use_case.dart';
import 'package:accounting_software/app/features/catalog/colors/presentation/cubit/color_form/color_form_effect.dart';
import 'package:accounting_software/app/features/catalog/colors/presentation/localization/colors_keys.dart';

enum ColorFormStatus { idle, saving }

class ColorFormCubit extends BaseCubit<ColorFormStatus, ColorFormEffect> {
  ColorFormCubit({
    required CreateColorUseCase createColor,
    required UpdateColorUseCase updateColor,
    required FlashMessages flashMessages,
  }) : _createColor = createColor,
       _updateColor = updateColor,
       _flashMessages = flashMessages,
       super(ColorFormStatus.idle);

  final CreateColorUseCase _createColor;
  final UpdateColorUseCase _updateColor;
  final FlashMessages _flashMessages;

  Future<void> save({required CatalogColorDraft draft, int? id}) async {
    if (state == ColorFormStatus.saving || isClosed) return;

    emit(ColorFormStatus.saving);
    final result = id == null
        ? await _createColor(draft)
        : await _updateColor(UpdateColorParams(id: id, draft: draft));
    if (isClosed) return;

    result.fold(
      (failure) {
        emitEffect(ColorSaveFailedEffect(_messageKey(failure)));
      },
      (color) {
        emitEffect(ColorSavedEffect(color));
        _flashMessages.post(ColorsKeys.saved, MessageType.success);
      },
    );
    if (!isClosed) emit(ColorFormStatus.idle);
  }

  AppKey _messageKey(Failure failure) => switch (failure) {
    ColorDuplicateFailure() => ColorsKeys.duplicateError,
    _ => failure.messageKey,
  };
}
