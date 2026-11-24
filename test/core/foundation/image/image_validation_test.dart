import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:accounting_software/app/core/foundation/image/image_policy.dart';
import 'package:accounting_software/app/core/foundation/image/image_upload.dart';
import 'package:accounting_software/app/core/foundation/image/image_validation.dart';

void main() {
  const policy = ImagePolicy(
    maxBytes: 16,
    allowedMimeTypes: {'image/jpeg', 'image/png', 'image/webp'},
  );

  ImageUpload upload(List<int> bytes, String mime, {String name = 'image.bin'}) =>
      ImageUpload(bytes: Uint8List.fromList(bytes), fileName: name, mimeType: mime);

  test('accepts JPEG, PNG and WebP signatures', () {
    expect(ImageValidation.validate(upload([0xff, 0xd8, 0xff], 'image/jpeg'), policy).status,
        ImageValidationStatus.ok);
    expect(ImageValidation.validate(upload([0x89, 0x50, 0x4e, 0x47, 0x0d, 0x0a, 0x1a, 0x0a], 'image/png'), policy).status,
        ImageValidationStatus.ok);
    expect(ImageValidation.validate(upload([0x52, 0x49, 0x46, 0x46, 0, 0, 0, 0, 0x57, 0x45, 0x42, 0x50], 'image/webp'), policy).status,
        ImageValidationStatus.ok);
  });

  test('rejects empty files', () {
    expect(ImageValidation.validate(upload([], 'image/png'), policy).status,
        ImageValidationStatus.emptyFile);
  });

  test('rejects files over the policy size', () {
    expect(ImageValidation.validate(upload(List.filled(17, 0), 'image/png'), policy).status,
        ImageValidationStatus.tooLarge);
  });

  test('rejects a text file renamed to png', () {
    expect(ImageValidation.validate(upload([0x68, 0x65, 0x6c, 0x6c, 0x6f], 'image/png', name: 'renamed.png'), policy).status,
        ImageValidationStatus.wrongType);
  });

  test('rejects unsupported MIME even with image-like bytes', () {
    expect(ImageValidation.validate(upload([0xff, 0xd8, 0xff], 'image/gif'), policy).status,
        ImageValidationStatus.wrongType);
  });
}
