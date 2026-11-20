import 'dart:typed_data';

/// An image the user chose, already read into memory.
class PickedImage {
  const PickedImage({
    required this.bytes,
    required this.fileName,
    required this.mimeType,
  });

  final Uint8List bytes;
  final String fileName;

  /// e.g. `image/png`; derived from the file extension.
  final String mimeType;
}

/// Platform-independent "choose one image" capability. Features depend on this
/// interface only; the implementation lives in the platform layer so mobile,
/// web and desktop need no feature change.
abstract interface class ImagePickerPort {
  /// Returns null when the user cancels.
  Future<PickedImage?> pickImage();
}
