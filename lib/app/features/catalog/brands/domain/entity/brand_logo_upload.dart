import 'dart:typed_data';

import 'package:equatable/equatable.dart';

/// A brand logo file to upload. Limits mirror the Storage bucket
/// (`product-images`: 5 MB; JPEG, PNG, WebP) in docs/backend.
class BrandLogoUpload extends Equatable {
  const BrandLogoUpload({
    required this.bytes,
    required this.fileName,
    required this.mimeType,
  });

  static const maxBytes = 5 * 1024 * 1024;
  static const allowedMimeTypes = {'image/jpeg', 'image/png', 'image/webp'};

  final Uint8List bytes;
  final String fileName;
  final String mimeType;

  String get normalizedMimeType => mimeType.trim().toLowerCase();
  bool get hasAllowedType => allowedMimeTypes.contains(normalizedMimeType);
  bool get isTooLarge => bytes.length > maxBytes;
  bool get isEmpty => bytes.isEmpty;

  @override
  List<Object?> get props => [bytes.length, fileName, mimeType];
}
