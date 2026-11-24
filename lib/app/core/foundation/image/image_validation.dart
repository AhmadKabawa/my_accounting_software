import 'image_policy.dart';
import 'image_upload.dart';

enum ImageValidationStatus { ok, emptyFile, wrongType, tooLarge }

class ImageValidationResult {
  const ImageValidationResult(this.status);

  final ImageValidationStatus status;
  bool get isValid => status == ImageValidationStatus.ok;
}

/// Validates declared MIME type and the actual file signature.
abstract final class ImageValidation {
  static ImageValidationResult validate(
    ImageUpload upload,
    ImagePolicy policy,
  ) {
    if (upload.bytes.isEmpty) {
      return const ImageValidationResult(ImageValidationStatus.emptyFile);
    }
    if (upload.bytes.length > policy.maxBytes) {
      return const ImageValidationResult(ImageValidationStatus.tooLarge);
    }

    final mime = upload.normalizedMimeType;
    if (!policy.allowedMimeTypes.contains(mime) ||
        !_matchesSignature(upload, mime)) {
      return const ImageValidationResult(ImageValidationStatus.wrongType);
    }
    return const ImageValidationResult(ImageValidationStatus.ok);
  }

  static bool _matchesSignature(ImageUpload upload, String mime) {
    final bytes = upload.bytes;
    return switch (mime) {
      'image/jpeg' =>
        bytes.length >= 3 &&
            bytes[0] == 0xff &&
            bytes[1] == 0xd8 &&
            bytes[2] == 0xff,
      'image/png' =>
        bytes.length >= 8 &&
            bytes[0] == 0x89 &&
            bytes[1] == 0x50 &&
            bytes[2] == 0x4e &&
            bytes[3] == 0x47 &&
            bytes[4] == 0x0d &&
            bytes[5] == 0x0a &&
            bytes[6] == 0x1a &&
            bytes[7] == 0x0a,
      'image/webp' =>
        bytes.length >= 12 &&
            bytes[0] == 0x52 &&
            bytes[1] == 0x49 &&
            bytes[2] == 0x46 &&
            bytes[3] == 0x46 &&
            bytes[8] == 0x57 &&
            bytes[9] == 0x45 &&
            bytes[10] == 0x42 &&
            bytes[11] == 0x50,
      _ => false,
    };
  }
}
