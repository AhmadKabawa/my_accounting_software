import 'dart:typed_data';

import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:accounting_software/app/core/error/failures/failure.dart';
import 'package:accounting_software/app/core/localization/keys/error_keys.dart';
import 'package:accounting_software/app/core/platform/image_picker/image_picker_port.dart';
import 'package:accounting_software/app/features/catalog/brands/domain/entity/brand_logo_upload.dart';
import 'package:accounting_software/app/features/catalog/brands/domain/usecase/upload_brand_logo_use_case.dart';
import 'package:accounting_software/app/features/catalog/brands/presentation/cubit/brand_logo_upload_cubit.dart';
import 'package:accounting_software/app/features/catalog/brands/presentation/localization/brands_keys.dart';
import 'support/fake_brands_repository.dart';

class _FakePicker implements ImagePickerPort {
  _FakePicker(this.image);
  PickedImage? image;
  @override
  Future<PickedImage?> pickImage() async => image;
}

class _TestFailure extends Failure {
  const _TestFailure() : super(messageKey: ErrorKeys.conflict);
}

PickedImage _image({String mime = 'image/png', int size = 10}) => PickedImage(
  bytes: Uint8List(size),
  fileName: 'logo.png',
  mimeType: mime,
);

void main() {
  late FakeBrandsRepository repository;

  BrandLogoUploadCubit build(PickedImage? image) => BrandLogoUploadCubit(
    uploadLogo: UploadBrandLogoUseCase(repository),
    picker: _FakePicker(image),
  );

  setUp(() => repository = FakeBrandsRepository());

  test('uploads a valid image and exposes its public URL', () async {
    final cubit = build(_image());
    await cubit.pickAndUpload();
    expect(cubit.state, const BrandLogoUploaded('https://cdn.test/logo.png'));
    expect(repository.lastUpload?.mimeType, 'image/png');
  });

  test('cancelling the picker changes nothing', () async {
    final cubit = build(null);
    await cubit.pickAndUpload();
    expect(cubit.state, const BrandLogoIdle());
    expect(repository.lastUpload, isNull);
  });

  test('rejects an unsupported type without uploading', () async {
    final cubit = build(_image(mime: 'image/gif'));
    await cubit.pickAndUpload();
    expect(cubit.state, const BrandLogoUploadFailed(BrandsKeys.logoFileType));
    expect(repository.lastUpload, isNull);
  });

  test('rejects a file over 5 MB without uploading', () async {
    final cubit = build(_image(size: BrandLogoUpload.maxBytes + 1));
    await cubit.pickAndUpload();
    expect(
      cubit.state,
      const BrandLogoUploadFailed(BrandsKeys.logoFileTooLarge),
    );
    expect(repository.lastUpload, isNull);
  });

  test('surfaces the server failure message', () async {
    repository.uploadResult = const Left(_TestFailure());
    final cubit = build(_image());
    await cubit.pickAndUpload();
    expect(cubit.state, const BrandLogoUploadFailed(ErrorKeys.conflict));
  });
}
