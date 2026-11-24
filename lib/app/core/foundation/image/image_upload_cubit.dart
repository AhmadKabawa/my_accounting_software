import 'package:dartz/dartz.dart';
import 'package:accounting_software/app/core/error/failures/failure.dart';
import 'package:accounting_software/app/core/foundation/image/image_policy.dart';
import 'package:accounting_software/app/core/foundation/image/image_upload.dart';
import 'package:accounting_software/app/core/foundation/image/image_validation.dart';
import 'package:accounting_software/app/core/localization/keys/error_keys.dart';
import 'package:accounting_software/app/core/localization/keys/image_keys.dart';
import 'package:accounting_software/app/core/localization/translations/app_key.dart';
import 'package:accounting_software/app/core/platform/image_picker/image_picker_port.dart';
import 'package:accounting_software/app/core/presentation/state_management/base_cubit.dart';

typedef ImageUploader =
    Future<Either<Failure, String>> Function(ImageUpload upload);

sealed class ImageUploadState {
  const ImageUploadState();
  bool get isBusy => false;
}

final class ImageUploadIdle extends ImageUploadState {
  const ImageUploadIdle();
}

final class ImageUploadPicking extends ImageUploadState {
  const ImageUploadPicking();
  @override
  bool get isBusy => true;
}

final class ImageUploadUploading extends ImageUploadState {
  const ImageUploadUploading();
  @override
  bool get isBusy => true;
}

final class ImageUploadUploaded extends ImageUploadState {
  const ImageUploadUploaded(this.url);
  final String url;
}

final class ImageUploadFailed extends ImageUploadState {
  const ImageUploadFailed(this.messageKey);
  final AppKey messageKey;
}

class ImageUploadCubit extends BaseCubit<ImageUploadState, void> {
  ImageUploadCubit({
    required ImagePickerPort picker,
    required ImagePolicy policy,
    required ImageUploader uploader,
  }) : _picker = picker,
       _policy = policy,
       _uploader = uploader,
       super(const ImageUploadIdle());

  final ImagePickerPort _picker;
  final ImagePolicy _policy;
  final ImageUploader _uploader;

  Future<void> pickAndUpload() async {
    if (state.isBusy || isClosed) return;
    emit(const ImageUploadPicking());

    final PickedImage? picked;
    try {
      picked = await _picker.pickImage();
    } catch (_) {
      if (!isClosed) emit(const ImageUploadFailed(ImageKeys.readFailed));
      return;
    }
    if (isClosed) return;
    if (picked == null) {
      emit(const ImageUploadIdle());
      return;
    }

    await upload(
      ImageUpload(
        bytes: picked.bytes,
        fileName: picked.fileName,
        mimeType: picked.mimeType,
      ),
    );
  }

  Future<void> upload(ImageUpload upload) async {
    if (state.isBusy || isClosed) return;
    final validation = ImageValidation.validate(upload, _policy);
    if (!validation.isValid) {
      final key = switch (validation.status) {
        ImageValidationStatus.tooLarge => ImageKeys.tooLarge,
        ImageValidationStatus.emptyFile ||
        ImageValidationStatus.wrongType => ImageKeys.unsupportedType,
        ImageValidationStatus.ok => ImageKeys.unsupportedType,
      };
      emit(ImageUploadFailed(key));
      return;
    }

    emit(const ImageUploadUploading());
    try {
      final result = await _uploader(upload);
      if (isClosed) return;
      result.fold(
        (failure) => emit(ImageUploadFailed(failure.messageKey)),
        (url) => emit(ImageUploadUploaded(url)),
      );
    } catch (_) {
      if (!isClosed) emit(const ImageUploadFailed(ErrorKeys.unknown));
    }
  }

  void reset() {
    if (!isClosed && !state.isBusy) emit(const ImageUploadIdle());
  }
}
