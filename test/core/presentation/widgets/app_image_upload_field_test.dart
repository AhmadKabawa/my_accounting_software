import 'dart:async';
import 'dart:typed_data';

import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:accounting_software/app/core/error/failures/failure.dart';
import 'package:accounting_software/app/core/foundation/image/image_policy.dart';
import 'package:accounting_software/app/core/foundation/image/image_upload_cubit.dart';
import 'package:accounting_software/app/core/localization/keys/error_keys.dart';
import 'package:accounting_software/app/core/localization/keys/image_keys.dart';
import 'package:accounting_software/app/core/platform/file_drop/file_drop_target.dart';
import 'package:accounting_software/app/core/platform/platform_capabilities.dart';
import 'package:accounting_software/app/core/platform/image_picker/image_picker_port.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_image_upload/app_image_upload_field.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_logo_thumb/app_logo_thumb.dart';
import '../../../helpers/localized_app.dart';
import '../../../helpers/test_key.dart';

const _policy = ImagePolicy(maxBytes: 32, allowedMimeTypes: {'image/png'});
const _labels = AppImageUploadFieldLabels(
  sectionTitle: TestKey('test.image.section'),
  upload: TestKey('test.image.upload'),
  replace: TestKey('test.image.replace'),
  remove: TestKey('test.image.remove'),
  dropHint: TestKey('test.image.drop'),
);

class _Picker implements ImagePickerPort {
  _Picker(this.image);
  final PickedImage? image;
  int calls = 0;
  @override
  Future<PickedImage?> pickImage() async {
    calls++;
    return image;
  }
}

class _Failure extends Failure {
  const _Failure() : super(messageKey: ErrorKeys.conflict);
}

PickedImage _png() => PickedImage(
  bytes: Uint8List.fromList([0x89, 0x50, 0x4e, 0x47, 0x0d, 0x0a, 0x1a, 0x0a]),
  fileName: 'logo.png',
  mimeType: 'image/png',
);

PickedImage _textAsPng() => PickedImage(
  bytes: Uint8List.fromList([0x68, 0x65, 0x6c, 0x6c, 0x6f]),
  fileName: 'fake.png',
  mimeType: 'image/png',
);

class _PassThroughDropAdapter implements FileDropTargetAdapter {
  const _PassThroughDropAdapter();

  @override
  Widget build({
    required Widget child,
    required DroppedImagesCallback onFilesDropped,
    required ValueChanged<bool> onHover,
  }) => child;
}

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
        key: const ValueKey('test-drop'),
        onPressed: () => onFilesDropped([image]),
        child: const Text('drop'),
      ),
    ],
  );
}

Widget _field({
  String? value,
  ImagePickerPort? picker,
  ImageUploader? uploader,
  ValueChanged<String?>? onChanged,
  ValueChanged<bool>? onBusyChanged,
  FileDropTargetAdapter? dropAdapter,
}) => AppImageUploadField(
  value: value,
  onChanged: onChanged ?? (_) {},
  label: 'Brand logo',
  policy: _policy,
  uploader: uploader ?? (_) async => const Right('https://cdn.test/logo.png'),
  labels: _labels,
  previewSize: AppLogoSize.small,
  picker: picker ?? _Picker(_png()),
  dropTargetAdapter: dropAdapter ?? const _PassThroughDropAdapter(),
  onBusyChanged: onBusyChanged,
);

Future<void> _pump(
  WidgetTester tester,
  Widget child, {
  Size size = const Size(800, 700),
  TextDirection direction = TextDirection.rtl,
  double textScale = 1,
}) async {
  useTranslations(const Locale('en'));
  setScreenSize(tester, size);
  await tester.pumpWidget(
    buildTestApp(
      direction: direction,
      textScale: textScale,
      home: Scaffold(body: SingleChildScrollView(child: child)),
    ),
  );
}

Finder _action(String label) => find.byWidgetPredicate(
  (widget) =>
      widget is Semantics &&
      widget.properties.button == true &&
      widget.properties.label == label,
);

void main() {
  testWidgets('empty field shows the clickable upload zone', (tester) async {
    await _pump(tester, _field());
    expect(find.byType(AppLogoThumb), findsNothing);
    expect(_action('test.image.upload'), findsOneWidget);
    if (PlatformCapabilities.supportsFileDrop) {
      expect(find.text(ImageKeys.dropHint.en), findsOneWidget);
    }
    expect(find.textContaining('Formats:'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('existing image shows centered preview, replace and remove', (
    tester,
  ) async {
    await _pump(tester, _field(value: 'https://cdn.test/logo.png'));
    expect(find.byType(AppLogoThumb), findsOneWidget);
    expect(_button(tester, 'test.image.replace'), findsOneWidget);
    expect(_button(tester, 'test.image.remove'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('uploading disables the whole zone and reports busy changes', (
    tester,
  ) async {
    final result = Completer<Either<Failure, String>>();
    final picker = _Picker(_png());
    final busy = <bool>[];
    String? changed;
    await _pump(
      tester,
      _field(
        picker: picker,
        uploader: (_) => result.future,
        onChanged: (value) => changed = value,
        onBusyChanged: busy.add,
      ),
    );

    await tester.tap(_button(tester, 'test.image.upload'));
    await tester.pump();
    expect(busy, [true]);
    expect(picker.calls, 1);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    await tester.tap(_button(tester, 'test.image.upload'), warnIfMissed: false);
    await tester.pump();
    expect(picker.calls, 1);

    result.complete(const Right('https://cdn.test/new.png'));
    await tester.pump();
    await tester.pump();
    expect(changed, 'https://cdn.test/new.png');
    expect(busy, [true, false]);
  });

  testWidgets('successful upload switches to replace and remove actions', (
    tester,
  ) async {
    String? changed;
    await _pump(tester, _field(onChanged: (value) => changed = value));
    await tester.tap(_button(tester, 'test.image.upload'));
    await tester.pumpAndSettle();

    expect(changed, 'https://cdn.test/logo.png');
    expect(_button(tester, 'test.image.replace'), findsOneWidget);
    expect(_button(tester, 'test.image.remove'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'success survives parent rebuilds from value and busy callbacks',
    (tester) async {
      String? value;
      var busy = false;
      await _pump(
        tester,
        StatefulBuilder(
          builder: (context, setState) => _field(
            value: value,
            onChanged: (next) => setState(() => value = next),
            onBusyChanged: (next) => setState(() => busy = next),
          ),
        ),
      );

      await tester.tap(_button(tester, 'test.image.upload'));
      await tester.pumpAndSettle();

      expect(value, 'https://cdn.test/logo.png');
      expect(busy, isFalse);
      expect(_button(tester, 'test.image.replace'), findsOneWidget);
      expect(_button(tester, 'test.image.remove'), findsOneWidget);
    },
  );

  testWidgets('upload failure is shown in the inline banner', (tester) async {
    await _pump(tester, _field(uploader: (_) async => const Left(_Failure())));
    await tester.tap(_button(tester, 'test.image.upload'));
    await tester.pumpAndSettle();
    expect(find.text(ErrorKeys.conflict.en), findsOneWidget);
  });

  testWidgets('delete is separate from picker and clears the image', (
    tester,
  ) async {
    String? changed = 'https://cdn.test/logo.png';
    final picker = _Picker(_png());
    await _pump(
      tester,
      _field(
        value: changed,
        picker: picker,
        onChanged: (value) => changed = value,
      ),
    );
    await tester.tap(_button(tester, 'test.image.remove'));
    await tester.pump();
    expect(changed, isNull);
    expect(picker.calls, 0);
  });

  testWidgets('drop target uploads only the first valid file', (tester) async {
    String? changed;
    await _pump(
      tester,
      _field(
        onChanged: (value) => changed = value,
        dropAdapter: _FakeDropAdapter(_png()),
      ),
    );
    await tester.tap(find.byKey(const ValueKey('test-drop')));
    await tester.pumpAndSettle();
    expect(changed, 'https://cdn.test/logo.png');
  });

  testWidgets('drop target rejects a renamed text file', (tester) async {
    var uploads = 0;
    await _pump(
      tester,
      _field(
        uploader: (_) async {
          uploads++;
          return const Right('unused');
        },
        dropAdapter: _FakeDropAdapter(_textAsPng()),
      ),
    );
    await tester.tap(find.byKey(const ValueKey('test-drop')));
    await tester.pumpAndSettle();
    expect(uploads, 0);
    expect(find.text(ImageKeys.unsupportedType.en), findsOneWidget);
  });

  testWidgets('280px RTL with 1.5 text scale has no overflow', (tester) async {
    await _pump(
      tester,
      _field(value: 'https://cdn.test/logo.png'),
      size: const Size(280, 800),
      direction: TextDirection.rtl,
      textScale: 1.5,
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });
}
