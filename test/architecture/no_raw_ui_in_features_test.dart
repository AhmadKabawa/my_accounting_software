import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Features must build UI from `core` (AppText, AppButton, AppTextField,
/// AppIcon...), never from raw Material widgets or hard-coded visual values.
/// Raw elements are allowed only inside `lib/app/core/`.
///
/// `home` and `on_boarding` are demo code that predates the rule; they are
/// listed in [_legacy] so the rule protects every other feature now. Remove an
/// entry when that feature is cleaned up.
const _legacy = {'home', 'on_boarding'};

final _forbidden = <String, RegExp>{
  'Icon(': RegExp(r'(?<![\w.])Icon\('),
  'IconButton(': RegExp(r'(?<![\w])IconButton\('),
  'TextFormField(': RegExp(r'TextFormField\('),
  'TextButton(': RegExp(r'TextButton\('),
  'ElevatedButton(': RegExp(r'ElevatedButton\('),
  'AppBar(': RegExp(r'(?<![\w])AppBar\('),
  'TextStyle(': RegExp(r'(?<![\w])TextStyle\('),
  'Icons.': RegExp(r'(?<![\w])Icons\.'),
  'Colors.': RegExp(r'Colors\.(?!transparent)'),
  'EdgeInsets with numbers': RegExp(r'EdgeInsets\w*\.\w+\(\s*\d'),
};

void main() {
  test('features use core widgets, not raw Material elements', () {
    final violations = <String>[];
    final features = Directory('lib/app/features').listSync().whereType<Directory>();

    for (final feature in features) {
      final name = feature.path.split(Platform.pathSeparator).last;
      if (_legacy.contains(name)) continue;

      for (final file in feature
          .listSync(recursive: true)
          .whereType<File>()
          .where((f) => f.path.endsWith('.dart'))
          .where((f) => !f.path.endsWith('.freezed.dart') && !f.path.endsWith('.g.dart'))) {
        final lines = file.readAsLinesSync();
        for (var i = 0; i < lines.length; i++) {
          final line = lines[i].trimLeft();
          if (line.startsWith('//')) continue;
          for (final entry in _forbidden.entries) {
            if (entry.value.hasMatch(line)) {
              violations.add('${file.path}:${i + 1} uses ${entry.key}');
            }
          }
        }
      }
    }

    expect(
      violations,
      isEmpty,
      reason: 'Use a core widget (or extend core first): see '
          'docs/architecture/ARCHITECTURE_RULES.md (core-gap rule).\n'
          '${violations.join('\n')}',
    );
  });
}
