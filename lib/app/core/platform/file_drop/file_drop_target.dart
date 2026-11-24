import 'package:desktop_drop/desktop_drop.dart';
import 'package:flutter/material.dart';
import 'package:accounting_software/app/core/platform/image_picker/image_picker_port.dart';

typedef DroppedImagesCallback = Future<void> Function(List<PickedImage> images);

/// Adapter seam lets widget tests simulate a native drop without platform I/O.
abstract interface class FileDropTargetAdapter {
  Widget build({
    required Widget child,
    required DroppedImagesCallback onFilesDropped,
    required ValueChanged<bool> onHover,
  });
}

/// The only project file allowed to import the desktop_drop package.
class DesktopFileDropTargetAdapter implements FileDropTargetAdapter {
  const DesktopFileDropTargetAdapter();

  static const _mimeByExtension = {
    'jpg': 'image/jpeg',
    'jpeg': 'image/jpeg',
    'png': 'image/png',
    'webp': 'image/webp',
  };

  @override
  Widget build({
    required Widget child,
    required DroppedImagesCallback onFilesDropped,
    required ValueChanged<bool> onHover,
  }) => DropTarget(
    onDragDone: (details) async {
      final images = <PickedImage>[];
      for (final file in details.files) {
        final extension = file.name.split('.').last.toLowerCase();
        images.add(
          PickedImage(
            bytes: await file.readAsBytes(),
            fileName: file.name,
            mimeType: _mimeByExtension[extension] ?? 'application/octet-stream',
          ),
        );
      }
      if (images.isNotEmpty) await onFilesDropped(images);
      onHover(false);
    },
    onDragEntered: (_) => onHover(true),
    onDragExited: (_) => onHover(false),
    child: child,
  );
}

/// Platform-independent drop target. Tests may inject a fake adapter.
class FileDropTarget extends StatelessWidget {
  const FileDropTarget({
    super.key,
    required this.child,
    required this.onFilesDropped,
    required this.onHover,
    this.adapter = const DesktopFileDropTargetAdapter(),
  });

  final Widget child;
  final DroppedImagesCallback onFilesDropped;
  final ValueChanged<bool> onHover;
  final FileDropTargetAdapter adapter;

  @override
  Widget build(BuildContext context) => adapter.build(
    child: child,
    onFilesDropped: onFilesDropped,
    onHover: onHover,
  );
}
