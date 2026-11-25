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

bool _isPresentationFile(String path) {
  final normalized = path.replaceAll('\\', '/');
  return normalized.contains('/pages/') ||
      normalized.contains('/widgets/') ||
      normalized.contains('/sections/') ||
      normalized.contains('/dialogs/');
}

Iterable<File> _featureFiles({String pathContains = ''}) sync* {
  final features = Directory(
    'lib/app/features',
  ).listSync().whereType<Directory>();
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

List<String> _scan(Iterable<File> files, RegExp pattern, String message) {
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
  test('presentation classifier includes dialogs and excludes domain', () {
    expect(
      _isPresentationFile(
        'lib/app/features/catalog/brands/presentation/dialogs/editor.dart',
      ),
      isTrue,
    );
    expect(
      _isPresentationFile(
        'lib/app/features/catalog/brands/domain/entity/brand.dart',
      ),
      isFalse,
    );
  });

  test('P-06: presentation files stay under the line limit', () {
    final tooLong = <String>[];
    for (final file in _featureFiles(pathContains: '/presentation/')) {
      final path = file.path.replaceAll('\\', '/');
      if (!_isPresentationFile(path)) continue;
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
      ..._scan(
        _featureFiles(pathContains: '/presentation/'),
        RegExp(r"""['"]—['"]"""),
        "hard-coded '—' (use a localized key)",
      ),
      ..._scan(
        _featureFiles(pathContains: '/presentation/'),
        RegExp(r"""\.tr\(context: context\)\s*\+|\+\s*['"]:\s?['"]"""),
        'builds a sentence by concatenation (use a key with {variables})',
      ),
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
          violations.add(
            '${file.path}:${i + 1} rowActionsBuilder uses AppButton',
          );
        }
      }
    }
    expect(violations, isEmpty, reason: violations.join('\n'));
  });

  test('P-10: list pages use ListPageTemplate (whole page scrolls)', () {
    final violations = <String>[];
    for (final file in _featureFiles(pathContains: '/pages/')) {
      final path = file.path.replaceAll('\\', '/');
      // Sections/widgets are parts of a page; the page itself owns the frame.
      if (path.contains('/sections/') || path.contains('/widgets/')) continue;
      final text = file.readAsStringSync();
      if ((text.contains('AppDataTable<') || text.contains('AppDataView<')) &&
          !text.contains('ListPageTemplate(')) {
        violations.add(
          '${file.path} uses AppDataTable/AppDataView without ListPageTemplate',
        );
      }
    }
    expect(violations, isEmpty, reason: violations.join('\n'));
  });
}
