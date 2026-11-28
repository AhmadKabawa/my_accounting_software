import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:accounting_software/app/core/foundation/image/image_upload.dart';
import 'package:accounting_software/app/core/foundation/image/image_validation.dart';
import 'package:accounting_software/app/features/catalog/collections/data/collections_endpoint.dart';
import 'package:accounting_software/app/features/catalog/collections/domain/collection_image_policy.dart';

void main() {
  group('collection image policy', () {
    test('uses the dedicated collections folder in the public image bucket', () {
      expect(CollectionsEndpoint.imageBucket, 'product-images');
      expect(CollectionsEndpoint.imageFolder, 'collections');
      expect(collectionImagePolicy.maxBytes, 5 * 1024 * 1024);
      expect(
        collectionImagePolicy.allowedMimeTypes,
        {'image/jpeg', 'image/png', 'image/webp'},
      );
    });

    test('accepts a JPEG signature within the size limit', () {
      final upload = ImageUpload(
        bytes: Uint8List.fromList([0xff, 0xd8, 0xff, 0x00]),
        fileName: 'collection.jpg',
        mimeType: 'image/jpeg',
      );
      expect(
        ImageValidation.validate(upload, collectionImagePolicy).isValid,
        isTrue,
      );
    });

    test('rejects unsupported MIME types and oversized files', () {
      final unsupported = ImageUpload(
        bytes: Uint8List.fromList([0x47, 0x49, 0x46, 0x38]),
        fileName: 'collection.gif',
        mimeType: 'image/gif',
      );
      expect(
        ImageValidation.validate(unsupported, collectionImagePolicy).status,
        ImageValidationStatus.wrongType,
      );

      final oversized = ImageUpload(
        bytes: Uint8List(collectionImagePolicy.maxBytes + 1),
        fileName: 'large.png',
        mimeType: 'image/png',
      );
      expect(
        ImageValidation.validate(oversized, collectionImagePolicy).status,
        ImageValidationStatus.tooLarge,
      );
    });
  });
}
