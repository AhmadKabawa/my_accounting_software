import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Platform-bound APIs may live only in the platform layer
/// (`lib/app/core/platform/`) and in the files listed in [_allowed].
/// Everything else must ask a platform-independent interface, so a new
/// platform (mobile, Windows) is added by writing implementations, not by
/// changing features. See docs/architecture/PLATFORM_STRATEGY.md.
const _platformLayer = 'lib/app/core/platform/';

/// Files with a documented, justified use. Keep this list short; remove an
/// entry when the use moves into the platform layer.
const _allowed = {
  // Build-time check only: Google Sign-In on Web needs an OAuth client ID.
  'lib/app/core/foundation/config/env_config.dart',
};

final _imports = RegExp(
  r'''^\s*(import|export)\s+['"](dart:(io|html|js|js_interop|js_util)|package:web/)''',
);
final _checks = RegExp(
  r'(?<![\w.])(kIsWeb|defaultTargetPlatform)\b|Platform\.is\w+',
);
final _restrictedPackageImports = RegExp(
  r'''^\s*(import|export)\s+['"]package:(file_picker|desktop_drop)/''',
);

void main() {
  test('platform APIs and file picker packages appear only in platform layer', () {
    final violations = <String>[];

    for (final file
        in Directory('lib')
            .listSync(recursive: true)
            .whereType<File>()
            .where((f) => f.path.endsWith('.dart'))) {
      final path = file.path.replaceAll(r'\', '/');
      if (path.startsWith(_platformLayer) || _allowed.contains(path)) continue;

      final lines = file.readAsLinesSync();
      for (var i = 0; i < lines.length; i++) {
        final line = lines[i];
        if (line.trimLeft().startsWith('//')) continue;
        if (_imports.hasMatch(line) ||
            _checks.hasMatch(line) ||
            _restrictedPackageImports.hasMatch(line)) {
          violations.add('$path:${i + 1}: ${line.trim()}');
        }
      }
    }

    expect(
      violations,
      isEmpty,
      reason:
          'Move platform-bound code and file_picker/desktop_drop imports behind '
          'an interface in $_platformLayer '
          '(docs/architecture/PLATFORM_STRATEGY.md):\n'
          '${violations.join('\n')}',
    );
  });

  test('the allow-list only names files that exist', () {
    for (final path in _allowed) {
      expect(File(path).existsSync(), isTrue, reason: path);
    }
  });
}
