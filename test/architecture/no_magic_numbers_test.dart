import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// No raw numbers for visual values (sizes, radii, paddings, font sizes,
/// elevations, stroke widths). Use a token: `AppSpacing`, `AppRadius`,
/// `AppIconSize`, `AppFontSize`, `AppElevation`, `AppBorderWidth`,
/// `AppComponentSize`. A missing token is a gap in `core`: add it there.
///
/// Scanned: every feature (except [_legacyFeatures]) and
/// `core/presentation/widgets`. The token definitions themselves
/// (`design_system/`) are where the numbers live, so they are not scanned.
/// Zero is allowed (`width: 0`, `EdgeInsets.all(0)`).
const _legacyFeatures = {'on_boarding'};

const _label = r'width|height|size|fontSize|elevation|radius|strokeWidth|'
    r'thickness|dimension|blurRadius|spreadRadius|minHeight|minWidth|'
    r'maxWidth|maxHeight';

final _rules = <String, RegExp>{
  'a number after a size-like named argument':
      RegExp('(?<![\\w])(?:$_label)\\s*:\\s*(?!0\\b)\\d'),
  'Radius.circular(number)': RegExp(r'Radius\.circular\(\s*(?!0\b)\d'),
  'EdgeInsets with a number': RegExp(r'EdgeInsets\w*\.\w+\(\s*(?!0\b)\d'),
  'Size(number)': RegExp(r'(?<![\w])Size(?:\.square)?\(\s*(?!0\b)\d'),
};

Iterable<File> _dartFiles(Directory dir) => dir
    .listSync(recursive: true)
    .whereType<File>()
    .where(
      (f) =>
          f.path.endsWith('.dart') &&
          !f.path.endsWith('.freezed.dart') &&
          !f.path.endsWith('.g.dart'),
    );

List<String> _scan(Iterable<File> files) {
  final found = <String>[];
  for (final file in files) {
    final lines = file.readAsLinesSync();
    for (var i = 0; i < lines.length; i++) {
      if (lines[i].trimLeft().startsWith('//')) continue;
      for (final rule in _rules.entries) {
        if (rule.value.hasMatch(lines[i])) {
          found.add('${file.path}:${i + 1} has ${rule.key}');
        }
      }
    }
  }
  return found;
}

void main() {
  const how = 'Use a design token (docs/architecture/ARCHITECTURE_RULES.md, '
      'no-raw-numbers rule). If none fits, add one in core first.';

  test('features use tokens, not raw numbers', () {
    final files = Directory('lib/app/features')
        .listSync()
        .whereType<Directory>()
        .where((d) => !_legacyFeatures.contains(d.path.split(Platform.pathSeparator).last))
        .expand(_dartFiles);
    expect(_scan(files), isEmpty, reason: how);
  });

  test('core widgets use tokens, not raw numbers', () {
    final files = _dartFiles(Directory('lib/app/core/presentation/widgets'));
    expect(_scan(files), isEmpty, reason: how);
  });

  test('the rule actually detects violations (self-check)', () {
    final dir = Directory.systemTemp.createTempSync('magic_numbers');
    addTearDown(() => dir.deleteSync(recursive: true));
    final file = File('${dir.path}/bad.dart')
      ..writeAsStringSync('''
final a = SizedBox(width: 12);
final b = BorderRadius.circular(8);
final c = EdgeInsets.all(16);
final d = SizedBox(width: 0);
// SizedBox(height: 99)
''');
    expect(_scan([file]), hasLength(3));
  });
}
