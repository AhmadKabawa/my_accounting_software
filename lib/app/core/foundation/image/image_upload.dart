import 'dart:typed_data';

import 'package:equatable/equatable.dart';

/// Image bytes and their picker-provided metadata. No local file path is used.
class ImageUpload extends Equatable {
  const ImageUpload({
    required this.bytes,
    required this.fileName,
    required this.mimeType,
  });

  final Uint8List bytes;
  final String fileName;
  final String mimeType;

  String get normalizedMimeType => mimeType.trim().toLowerCase();

  @override
  List<Object?> get props => [bytes.length, fileName, normalizedMimeType];
}
