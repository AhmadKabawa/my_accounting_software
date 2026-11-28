import 'package:equatable/equatable.dart';
import 'package:accounting_software/app/core/localization/translations/app_key.dart';
import 'package:accounting_software/app/core/presentation/state_management/base_cubit.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_message/flash_messages.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_message/message_view_widgets.dart';
import 'package:accounting_software/app/features/catalog/seasons/domain/entity/season_draft.dart';
import 'package:accounting_software/app/features/catalog/seasons/domain/failures/season_failures.dart';
import 'package:accounting_software/app/features/catalog/seasons/domain/usecase/create_season_use_case.dart';
import 'package:accounting_software/app/features/catalog/seasons/domain/usecase/update_season_use_case.dart';
import 'package:accounting_software/app/features/catalog/seasons/presentation/localization/seasons_keys.dart';

sealed class SeasonFormState extends Equatable {
  const SeasonFormState();
}

final class SeasonFormIdle extends SeasonFormState {
  const SeasonFormIdle();
  @override
  List<Object?> get props => [];
}

final class SeasonFormSaving extends SeasonFormState {
  const SeasonFormSaving();
  @override
  List<Object?> get props => [];
}

sealed class SeasonFormEffect {
  const SeasonFormEffect();
}

final class SeasonSavedEffect extends SeasonFormEffect {
  const SeasonSavedEffect();
}

final class SeasonSaveFailedEffect extends SeasonFormEffect {
  const SeasonSaveFailedEffect(this.messageKey);
  final AppKey messageKey;
}

class SeasonFormCubit
    extends BaseCubit<SeasonFormState, SeasonFormEffect> {
  SeasonFormCubit({
    required CreateSeasonUseCase create,
    required UpdateSeasonUseCase update,
    required FlashMessages flashMessages,
  }) : _create = create,
       _update = update,
       _flash = flashMessages,
       super(const SeasonFormIdle());

  final CreateSeasonUseCase _create;
  final UpdateSeasonUseCase _update;
  final FlashMessages _flash;

  Future<void> save({required SeasonDraft draft, int? id}) async {
    if (state is SeasonFormSaving || isClosed) return;
    emit(const SeasonFormSaving());
    final result = id == null
        ? await _create(draft)
        : await _update(UpdateSeasonParams(id, draft));
    if (isClosed) return;
    result.fold(
      (failure) => emitEffect(
        SeasonSaveFailedEffect(
          failure is SeasonDuplicateFailure
              ? SeasonsKeys.duplicateError
              : failure.messageKey,
        ),
      ),
      (_) {
        emitEffect(const SeasonSavedEffect());
        _flash.post(SeasonsKeys.saved, MessageType.success);
      },
    );
    if (!isClosed) emit(const SeasonFormIdle());
  }
}
