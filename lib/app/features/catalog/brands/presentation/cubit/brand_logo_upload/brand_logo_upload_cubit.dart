import 'package:accounting_software/app/core/presentation/state_management/base_cubit.dart';
import 'package:accounting_software/app/core/platform/image_picker/image_picker_port.dart';
import 'package:accounting_software/app/features/catalog/brands/domain/entity/brand_logo_upload.dart';
import 'package:accounting_software/app/features/catalog/brands/domain/usecase/upload_brand_logo_use_case.dart';
import 'package:accounting_software/app/features/catalog/brands/presentation/cubit/brand_logo_upload/brand_logo_upload_state.dart';
import 'package:accounting_software/app/features/catalog/brands/presentation/localization/brands_keys.dart';

/// Picks an image, checks type/size, uploads it, and exposes the public URL.
class BrandLogoUploadCubit extends BaseCubit<BrandLogoUploadState, void> {
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
