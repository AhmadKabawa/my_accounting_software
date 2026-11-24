import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:accounting_software/app/core/platform/file_drop/file_drop_target.dart';
import 'package:accounting_software/app/core/platform/image_picker/image_picker_port.dart';

class _FakeDropAdapter implements FileDropTargetAdapter {
  _FakeDropAdapter(this.image);
  final PickedImage image;

  @override
  Widget build({
    required Widget child,
    required DroppedImagesCallback onFilesDropped,
    required ValueChanged<bool> onHover,
  }) => Column(
    children: [
      child,
      TextButton(
        key: const ValueKey('fake-drop'),
        onPressed: () => onFilesDropped([image]),
        child: const Text('Drop'),
      ),
      TextButton(
        key: const ValueKey('fake-hover'),
        onPressed: () => onHover(true),
        child: const Text('Hover'),
      ),
    ],
  );
}

void main() {
  testWidgets('forwards dropped files and hover changes through test adapter', (
    tester,
  ) async {
    final image = PickedImage(
      bytes: Uint8List.fromList([1, 2, 3]),
      fileName: 'test.png',
      mimeType: 'image/png',
    );
    List<PickedImage>? received;
    bool? hovering;

    await tester.pumpWidget(
      MaterialApp(
        home: FileDropTarget(
          child: const Text('Target'),
          adapter: _FakeDropAdapter(image),
          onFilesDropped: (files) async => received = files,
          onHover: (value) => hovering = value,
        ),
      ),
    );

    await tester.tap(find.byKey(const ValueKey('fake-hover')));
    await tester.pump();
    expect(hovering, isTrue);

    await tester.tap(find.byKey(const ValueKey('fake-drop')));
    await tester.pump();
    expect(received, hasLength(1));
    expect(received!.single.fileName, 'test.png');
  });
}
