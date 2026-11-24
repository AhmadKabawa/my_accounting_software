import 'dart:typed_data';

import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:accounting_software/app/core/error/failures/failure.dart';
import 'package:accounting_software/app/core/foundation/image/image_policy.dart';
import 'package:accounting_software/app/core/foundation/image/image_upload.dart';
import 'package:accounting_software/app/core/foundation/image/image_upload_cubit.dart';
import 'package:accounting_software/app/core/localization/keys/error_keys.dart';
import 'package:accounting_software/app/core/localization/keys/image_keys.dart';
import 'package:accounting_software/app/core/platform/image_picker/image_picker_port.dart';

class _Picker implements ImagePickerPort {
  _Picker(this.value);
  final PickedImage? value;
  @override
  Future<PickedImage?> pickImage() async => value;
}

class _Failure extends Failure {
  const _Failure() : super(messageKey: ErrorKeys.conflict);
}

PickedImage _validImage() => PickedImage(
  bytes: Uint8List.fromList([0x89, 0x50, 0x4e, 0x47, 0x0d, 0x0a, 0x1a, 0x0a]),
  fileName: 'logo.png',
  mimeType: 'image/png',
);

void main() {
  const policy = ImagePolicy(maxBytes: 32, allowedMimeTypes: {'image/png'});
  test('uploads a valid image and emits its URL', () async {
    final cubit = ImageUploadCubit(
      picker: _Picker(_validImage()),
      policy: policy,
      uploader: (_) async => const Right('https://cdn.test/image.png'),
    );
    await cubit.pickAndUpload();
    expect(cubit.state, isA<ImageUploadUploaded>());
    expect((cubit.state as ImageUploadUploaded).url, 'https://cdn.test/image.png');
    await cubit.close();
  });

  test('picker cancellation returns to idle without upload', () async {
    var uploads = 0;
    final cubit = ImageUploadCubit(
      picker: _Picker(null),
      policy: policy,
      uploader: (_) async { uploads++; return const Right('unused'); },
    );
    await cubit.pickAndUpload();
    expect(cubit.state, isA<ImageUploadIdle>());
    expect(uploads, 0);
    await cubit.close();
  });

  test('surfaces uploader failures', () async {
    final cubit = ImageUploadCubit(
      picker: _Picker(_validImage()),
      policy: policy,
      uploader: (_) async => const Left(_Failure()),
    );
    await cubit.pickAndUpload();
    expect(cubit.state, const ImageUploadFailed(ErrorKeys.conflict));
    await cubit.close();
  });

  test('rejects policy failures without calling uploader', () async {
    var uploads = 0;
    final cubit = ImageUploadCubit(
      picker: _Picker(PickedImage(
        bytes: Uint8List.fromList([1, 2, 3]),
        fileName: 'wrong.png',
        mimeType: 'image/png',
      )),
      policy: policy,
      uploader: (_) async { uploads++; return const Right('unused'); },
    );
    await cubit.pickAndUpload();
    expect(cubit.state, const ImageUploadFailed(ImageKeys.unsupportedType));
    expect(uploads, 0);
    await cubit.close();
  });

  test('ignores a duplicate pick while busy', () async {
    var pickCount = 0;
    var finishUpload = false;
    final picker = _CountingPicker(() { pickCount++; return _validImage(); });
    final cubit = ImageUploadCubit(
      picker: picker,
      policy: policy,
      uploader: (_) async {
        while (!finishUpload) { await Future<void>.delayed(Duration.zero); }
        return const Right('https://cdn.test/image.png');
      },
    );
    final first = cubit.pickAndUpload();
    await Future<void>.delayed(Duration.zero);
    final second = cubit.pickAndUpload();
    expect(pickCount, 1);
    finishUpload = true;
    await Future.wait([first, second]);
    await cubit.close();
  });
}

class _CountingPicker implements ImagePickerPort {
  _CountingPicker(this.create);
  final PickedImage Function() create;
  @override
  Future<PickedImage?> pickImage() async => create();
}
