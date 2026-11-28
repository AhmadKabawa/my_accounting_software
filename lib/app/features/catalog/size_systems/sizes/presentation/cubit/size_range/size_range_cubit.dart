import 'package:accounting_software/app/core/error/failures/failure.dart';
import 'package:accounting_software/app/core/localization/translations/app_key.dart';
import 'package:accounting_software/app/core/presentation/state_management/base_cubit.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_message/flash_messages.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_message/message_view_widgets.dart';
import 'package:accounting_software/app/features/catalog/size_systems/presentation/localization/size_systems_keys.dart';
import 'package:accounting_software/app/features/catalog/size_systems/shared/domain/failures/size_system_failures.dart';
import 'package:accounting_software/app/features/catalog/size_systems/shared/domain/range/size_range_generator.dart';
import 'package:accounting_software/app/features/catalog/size_systems/sizes/domain/entity/catalog_size_draft.dart';
import 'package:accounting_software/app/features/catalog/size_systems/sizes/domain/usecase/sizes_use_cases.dart';
import 'package:accounting_software/app/features/catalog/size_systems/sizes/presentation/cubit/size_range/size_range_effect.dart';

enum SizeRangeStatus { idle, saving }

/// Saves the previewed range rows with ONE batch request.
class SizeRangeCubit extends BaseCubit<SizeRangeStatus, SizeRangeEffect> {
  SizeRangeCubit({
    required CreateSizesBatchUseCase createBatch,
    required FlashMessages flashMessages,
  }) : _createBatch = createBatch,
       _flash = flashMessages,
       super(SizeRangeStatus.idle);

  final CreateSizesBatchUseCase _createBatch;
  final FlashMessages _flash;

  Future<void> save({
    required int sizeGroupId,
    required List<GeneratedSizeRow> rows,
  }) async {
    if (state == SizeRangeStatus.saving || isClosed) return;
    if (rows.isEmpty) {
      emitEffect(const SizeRangeFailedEffect(SizeSystemsKeys.rangeNothing));
      return;
    }
    emit(SizeRangeStatus.saving);
    final result = await _createBatch([
      for (final row in rows)
        CatalogSizeDraft(
          sizeGroupId: sizeGroupId,
          name: row.name,
          code: row.code,
          numericValue: row.numericValue,
          sortOrder: row.sortOrder,
        ),
    ]);
    if (isClosed) return;
    result.fold(
      (failure) => emitEffect(SizeRangeFailedEffect(_key(failure))),
      (created) {
        emitEffect(SizeRangeSavedEffect(created.length));
        _flash.post(SizeSystemsKeys.rangeSaved, MessageType.success);
      },
    );
    if (!isClosed) emit(SizeRangeStatus.idle);
  }

  AppKey _key(Failure failure) => switch (failure) {
    SizeCodeDuplicateFailure() => SizeSystemsKeys.duplicateSize,
    _ => failure.messageKey,
  };
}
