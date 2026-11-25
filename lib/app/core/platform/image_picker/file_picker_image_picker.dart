import 'package:file_picker/file_picker.dart';
import 'package:accounting_software/app/core/platform/image_picker/image_picker_port.dart';

/// [ImagePickerPort] backed by the `file_picker` package (web, desktop, mobile).
/// This is the only file allowed to import `file_picker`.
class FilePickerImagePicker implements ImagePickerPort {
  const FilePickerImagePicker();

  static const _mimeByExtension = {
    'jpg': 'image/jpeg',
    'jpeg': 'image/jpeg',
    'png': 'image/png',
    'webp': 'image/webp',
  };

  @override
  Future<PickedImage?> pickImage() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      withData: true,
    );
    final file = result?.files.single;
    if (file == null) return null;
    final bytes = file.bytes;
    if (bytes == null) {
      throw StateError('The selected image could not be read.');
    }
    final extension = file.name.split('.').last.toLowerCase();
    return PickedImage(
      bytes: bytes,
      fileName: file.name,
      mimeType: _mimeByExtension[extension] ?? 'application/octet-stream',
    );
  }
}
