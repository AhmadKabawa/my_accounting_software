import 'package:accounting_software/app/core/error/failures/failure.dart';
import 'package:accounting_software/app/core/localization/translations/app_key.dart';
import 'package:accounting_software/app/core/presentation/state_management/base_cubit.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_message/flash_messages.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_message/message_view_widgets.dart';
import 'package:accounting_software/app/features/catalog/sports/domain/entity/sport_draft.dart';
import 'package:accounting_software/app/features/catalog/sports/domain/failures/sport_failures.dart';
import 'package:accounting_software/app/features/catalog/sports/domain/usecase/create_sport_use_case.dart';
import 'package:accounting_software/app/features/catalog/sports/domain/usecase/update_sport_use_case.dart';
import 'package:accounting_software/app/features/catalog/sports/presentation/cubit/sport_form/sport_form_effect.dart';
import 'package:accounting_software/app/features/catalog/sports/presentation/localization/sports_keys.dart';

enum SportFormStatus { idle, saving }

class SportFormCubit extends BaseCubit<SportFormStatus, SportFormEffect> {
  SportFormCubit({
    required CreateSportUseCase createSport,
    required UpdateSportUseCase updateSport,
    required FlashMessages flashMessages,
  }) : _createSport = createSport,
       _updateSport = updateSport,
       _flashMessages = flashMessages,
       super(SportFormStatus.idle);

  final CreateSportUseCase _createSport;
  final UpdateSportUseCase _updateSport;
  final FlashMessages _flashMessages;

  Future<void> save({required SportDraft draft, int? id}) async {
    if (state == SportFormStatus.saving || isClosed) return;

    emit(SportFormStatus.saving);
    final result = id == null
        ? await _createSport(draft)
        : await _updateSport(UpdateSportParams(id: id, draft: draft));
    if (isClosed) return;

    result.fold(
      (failure) {
        emitEffect(SportSaveFailedEffect(_messageKey(failure)));
      },
      (sport) {
        emitEffect(SportSavedEffect(sport));
        _flashMessages.post(SportsKeys.saved, MessageType.success);
      },
    );
    if (!isClosed) emit(SportFormStatus.idle);
  }

  AppKey _messageKey(Failure failure) => switch (failure) {
    SportDuplicateFailure() => SportsKeys.duplicateError,
    _ => failure.messageKey,
  };
}
