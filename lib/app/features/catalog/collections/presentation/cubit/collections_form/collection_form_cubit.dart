import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:accounting_software/app/core/error/failures/failure.dart';
import 'package:accounting_software/app/core/foundation/image/image_upload.dart';
import 'package:accounting_software/app/core/localization/translations/app_key.dart';
import 'package:accounting_software/app/core/presentation/state_management/base_cubit.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_message/flash_messages.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_message/message_view_widgets.dart';
import 'package:accounting_software/app/features/catalog/collections/domain/entity/collection_draft.dart';
import 'package:accounting_software/app/features/catalog/collections/domain/failures/collection_failures.dart';
import 'package:accounting_software/app/features/catalog/collections/domain/usecase/create_collection_use_case.dart';
import 'package:accounting_software/app/features/catalog/collections/domain/usecase/update_collection_use_case.dart';
import 'package:accounting_software/app/features/catalog/collections/domain/usecase/upload_collection_image_use_case.dart';
import 'package:accounting_software/app/features/catalog/collections/presentation/localization/collections_keys.dart';

sealed class CollectionFormState extends Equatable {
  const CollectionFormState();
}

final class CollectionFormIdle extends CollectionFormState {
  const CollectionFormIdle();
  @override
  List<Object?> get props => [];
}

final class CollectionFormSaving extends CollectionFormState {
  const CollectionFormSaving();
  @override
  List<Object?> get props => [];
}

sealed class CollectionFormEffect {
  const CollectionFormEffect();
}

final class CollectionSavedEffect extends CollectionFormEffect {
  const CollectionSavedEffect();
}

final class CollectionSaveFailedEffect extends CollectionFormEffect {
  const CollectionSaveFailedEffect(this.messageKey);
  final AppKey messageKey;
}

class CollectionFormCubit
    extends BaseCubit<CollectionFormState, CollectionFormEffect> {
  CollectionFormCubit({
    required CreateCollectionUseCase create,
    required UpdateCollectionUseCase update,
    required UploadCollectionImageUseCase uploadImage,
    required FlashMessages flashMessages,
  }) : _create = create,
       _update = update,
       _uploadImage = uploadImage,
       _flash = flashMessages,
       super(const CollectionFormIdle());

  final CreateCollectionUseCase _create;
  final UpdateCollectionUseCase _update;
  final UploadCollectionImageUseCase _uploadImage;
  final FlashMessages _flash;

  Future<Either<Failure, String>> uploadImage(ImageUpload image) =>
      _uploadImage(image);

  Future<void> save({required CollectionDraft draft, int? id}) async {
    if (state is CollectionFormSaving || isClosed) return;
    emit(const CollectionFormSaving());
    final result = id == null
        ? await _create(draft)
        : await _update(UpdateCollectionParams(id, draft));
    if (isClosed) return;
    result.fold(
      (failure) => emitEffect(
        CollectionSaveFailedEffect(
          failure is CollectionDuplicateFailure
              ? CollectionsKeys.duplicateError
              : failure.messageKey,
        ),
      ),
      (_) {
        emitEffect(const CollectionSavedEffect());
        _flash.post(CollectionsKeys.saved, MessageType.success);
      },
    );
    if (!isClosed) emit(const CollectionFormIdle());
  }
}
