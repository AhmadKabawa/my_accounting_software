import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// UI quality gate: mistakes that were already made once (see
/// docs/architecture/KNOWN_PITFALLS.md) must fail CI instead of being
/// found again by hand. Each rule names the pitfall id it protects.
///
/// `on_boarding` is demo code that predates the rules (same as
/// `no_raw_ui_in_features_test.dart`).
const _legacy = {'on_boarding'};

/// Presentation files (pages/widgets/sections) stay small enough to review.
/// Split by responsibility into `widgets/` or `sections/` before exceeding it.
const _maxPresentationLines = 250;

Iterable<File> _featureFiles({String pathContains = ''}) sync* {
  final features = Directory('lib/app/features').listSync().whereType<Directory>();
  for (final feature in features) {
    final name = feature.path.split(Platform.pathSeparator).last;
    if (_legacy.contains(name)) continue;
    for (final file in feature.listSync(recursive: true).whereType<File>()) {
      final path = file.path.replaceAll('\\', '/');
      if (!path.endsWith('.dart')) continue;
      if (path.endsWith('.freezed.dart') || path.endsWith('.g.dart')) continue;
      if (!path.contains(pathContains)) continue;
      yield file;
    }
  }
}

List<String> _scan(
  Iterable<File> files,
  RegExp pattern,
  String message,
) {
  final found = <String>[];
  for (final file in files) {
    final lines = file.readAsLinesSync();
    for (var i = 0; i < lines.length; i++) {
      final line = lines[i].trimLeft();
      if (line.startsWith('//')) continue;
      if (pattern.hasMatch(line)) found.add('${file.path}:${i + 1} $message');
    }
  }
  return found;
}

void main() {
  test('P-06: presentation files stay under the line limit', () {
    final tooLong = <String>[];
    for (final file in _featureFiles(pathContains: '/presentation/')) {
      final path = file.path.replaceAll('\\', '/');
      final isUi = path.contains('/pages/') ||
          path.contains('/widgets/') ||
          path.contains('/sections/');
      if (!isUi) continue;
      final lines = file.readAsLinesSync().length;
      if (lines > _maxPresentationLines) tooLong.add('$path ($lines lines)');
    }
    expect(tooLong, isEmpty, reason: 'Split into widgets/ or sections/');
  });

  test('P-07: no hand-made SnackBar; use MessageViewWidgets', () {
    final violations = _scan(
      _featureFiles(),
      RegExp(r'SnackBar\(|ScaffoldMessenger'),
      'uses a raw SnackBar',
    );
    expect(violations, isEmpty, reason: violations.join('\n'));
  });

  test('P-08: no hard-coded placeholder text or string concatenation', () {
    final violations = [
      ..._scan(_featureFiles(pathContains: '/presentation/'), RegExp("['\"]—['\"]"),
          "hard-coded '—' (use a localized key)"),
      ..._scan(_featureFiles(pathContains: '/presentation/'),
          RegExp(r"\.tr\(context: context\)\s*\+|\+\s*['\"]:\s?['\"]"),
          'builds a sentence by concatenation (use a key with {variables})'),
    ];
    expect(violations, isEmpty, reason: violations.join('\n'));
  });

  test('P-09: row actions are icons (AppRowActions), not text buttons', () {
    final violations = <String>[];
    for (final file in _featureFiles(pathContains: '/presentation/')) {
      final lines = file.readAsLinesSync();
      for (var i = 0; i < lines.length; i++) {
        if (!lines[i].contains('rowActionsBuilder')) continue;
        final window = lines.skip(i).take(25).join('\n');
        if (window.contains('AppButton(')) {
          violations.add('${file.path}:${i + 1} rowActionsBuilder uses AppButton');
        }
      }
    }
    expect(violations, isEmpty, reason: violations.join('\n'));
  });

  test('P-10: list pages use ListPageTemplate (whole page scrolls)', () {
    final violations = <String>[];
    for (final file in _featureFiles(pathContains: '/pages/')) {
      final text = file.readAsStringSync();
      if (text.contains('AppDataTable<') &&
          !text.contains('ListPageTemplate(')) {
        violations.add('${file.path} uses AppDataTable without ListPageTemplate');
      }
    }
    expect(violations, isEmpty, reason: violations.join('\n'));
  });
}
