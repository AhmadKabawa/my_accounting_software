import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:accounting_software/app/core/localization/translations/app_key.dart';
import 'package:accounting_software/app/core/platform/image_picker/image_picker_port.dart';
import 'package:accounting_software/app/features/catalog/brands/domain/entity/brand_logo_upload.dart';
import 'package:accounting_software/app/features/catalog/brands/domain/usecase/upload_brand_logo_use_case.dart';
import 'package:accounting_software/app/features/catalog/brands/presentation/localization/brands_keys.dart';

sealed class BrandLogoUploadState extends Equatable {
  const BrandLogoUploadState();
  @override
  List<Object?> get props => [];
}

final class BrandLogoIdle extends BrandLogoUploadState {
  const BrandLogoIdle();
}

final class BrandLogoUploading extends BrandLogoUploadState {
  const BrandLogoUploading();
}

/// [url] is the public URL to store in `brands.logo`.
final class BrandLogoUploaded extends BrandLogoUploadState {
  const BrandLogoUploaded(this.url);
  final String url;
  @override
  List<Object?> get props => [url];
}

final class BrandLogoUploadFailed extends BrandLogoUploadState {
  const BrandLogoUploadFailed(this.messageKey);
  final AppKey messageKey;
  @override
  List<Object?> get props => [messageKey];
}

/// Picks an image, checks type/size, uploads it, and exposes the public URL.
class BrandLogoUploadCubit extends Cubit<BrandLogoUploadState> {
  BrandLogoUploadCubit({
    required UploadBrandLogoUseCase uploadLogo,
    required ImagePickerPort picker,
  }) : _uploadLogo = uploadLogo,
       _picker = picker,
       super(const BrandLogoIdle());

  final UploadBrandLogoUseCase _uploadLogo;
  final ImagePickerPort _picker;

  Future<void> pickAndUpload() async {
    if (state is BrandLogoUploading) return;
    final picked = await _picker.pickImage();
    if (picked == null || isClosed) return; // cancelled
    final upload = BrandLogoUpload(
      bytes: picked.bytes,
      fileName: picked.fileName,
      mimeType: picked.mimeType,
    );
    if (!upload.hasAllowedType) {
      emit(const BrandLogoUploadFailed(BrandsKeys.logoFileType));
      return;
    }
    if (upload.isTooLarge) {
      emit(const BrandLogoUploadFailed(BrandsKeys.logoFileTooLarge));
      return;
    }
    emit(const BrandLogoUploading());
    final result = await _uploadLogo(upload);
    if (isClosed) return;
    result.fold(
      (failure) => emit(BrandLogoUploadFailed(failure.messageKey)),
      (url) => emit(BrandLogoUploaded(url)),
    );
  }

  void reset() => emit(const BrandLogoIdle());
}
