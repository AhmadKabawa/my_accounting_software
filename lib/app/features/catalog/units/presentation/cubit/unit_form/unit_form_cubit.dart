import 'package:accounting_software/app/core/error/failures/failure.dart';
import 'package:accounting_software/app/core/presentation/state_management/base_cubit.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_message/flash_messages.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_message/message_view_widgets.dart';
import 'package:accounting_software/app/features/catalog/units/domain/entity/unit_draft.dart';
import 'package:accounting_software/app/features/catalog/units/domain/usecase/create_unit_use_case.dart';
import 'package:accounting_software/app/features/catalog/units/domain/usecase/update_unit_use_case.dart';
import 'package:accounting_software/app/features/catalog/units/presentation/cubit/unit_form/unit_form_effect.dart';
import 'package:accounting_software/app/features/catalog/units/presentation/localization/units_keys.dart';

enum UnitFormStatus { idle, saving }

class UnitFormCubit extends BaseCubit<UnitFormStatus, UnitFormEffect> {
  UnitFormCubit({
    required CreateUnitUseCase createUnit,
    required UpdateUnitUseCase updateUnit,
    required FlashMessages flashMessages,
  }) : _createUnit = createUnit,
       _updateUnit = updateUnit,
       _flashMessages = flashMessages,
       super(UnitFormStatus.idle);

  final CreateUnitUseCase _createUnit;
  final UpdateUnitUseCase _updateUnit;
  final FlashMessages _flashMessages;

  Future<void> save({required UnitDraft draft, int? id}) async {
    if (state == UnitFormStatus.saving || isClosed) return;
    emit(UnitFormStatus.saving);
    final result = id == null
        ? await _createUnit(draft)
        : await _updateUnit(UpdateUnitParams(id: id, draft: draft));
    if (isClosed) return;
    result.fold(
      (failure) => emitEffect(UnitSaveFailedEffect(_messageKey(failure))),
      (unit) {
        emitEffect(UnitSavedEffect(unit.id));
        _flashMessages.post(UnitsKeys.saved, MessageType.success);
      },
    );
    if (!isClosed) emit(UnitFormStatus.idle);
  }

  _messageKey(Failure failure) => failure.messageKey;
}
