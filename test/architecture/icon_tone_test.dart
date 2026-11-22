import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Existing feature files that still pass a direct color to AppIcon.
/// This inventory is intentionally monotonic: remove entries as they are
/// migrated; adding debt requires an explicit architecture decision.
const _knownDebt = <String>{};

bool _hasTopLevelColorArgument(String source, int openParen) {
  var parens = 1;
  var brackets = 0;
  var braces = 0;
  String? quote;
  var escaped = false;
  for (var i = openParen + 1; i < source.length; i++) {
    final char = source[i];
    if (quote != null) {
      if (escaped) {
        escaped = false;
      } else if (char == String.fromCharCode(92)) {
        escaped = true;
      } else if (char == quote) {
        quote = null;
      }
      continue;
    }
    if (char == "'" || char == '"') {
      quote = char;
      continue;
    }
    if (char == '/' && i + 1 < source.length && source[i + 1] == '/') {
      final end = source.indexOf('\n', i);
      if (end == -1) return false;
      i = end;
      continue;
    }
    if (char == '/' && i + 1 < source.length && source[i + 1] == '*') {
      final end = source.indexOf('*/', i + 2);
      if (end == -1) return false;
      i = end + 1;
      continue;
    }
    if (char == '(') {
      parens++;
    } else if (char == ')') {
      parens--;
      if (parens == 0) return false;
    } else if (char == '[') {
      brackets++;
    } else if (char == ']') {
      brackets--;
    } else if (char == '{') {
      braces++;
    } else if (char == '}') {
      braces--;
    }
    if (parens == 1 && brackets == 0 && braces == 0) {
      final rest = source.substring(i);
      if (RegExp(r'^\s*color\s*:').hasMatch(rest)) return true;
    }
  }
  return false;
}

Set<String> featureIconColorViolations(Map<String, String> sources) {
  final violations = <String>{};
  final invocation = RegExp(r'\bAppIcon(?:\.fixed)?\s*\(');
  for (final entry in sources.entries) {
    if (!entry.key.startsWith('lib/app/features/')) continue;
    for (final match in invocation.allMatches(entry.value)) {
      final openParen = entry.value.indexOf('(', match.start);
      if (_hasTopLevelColorArgument(entry.value, openParen)) {
        violations.add(entry.key);
      }
    }
  }
  return violations;
}

Map<String, String> _readFeatureSources() => {
  for (final entity
      in Directory('lib/app/features')
          .listSync(recursive: true)
          .whereType<File>()
          .where((file) => file.path.endsWith('.dart')))
    entity.path.replaceAll(String.fromCharCode(92), '/'):
        entity.readAsStringSync(),
};

void main() {
  test('features use AppIconTone instead of direct AppIcon colors', () {
    final found = featureIconColorViolations(_readFeatureSources());
    expect(
      found.difference(_knownDebt),
      isEmpty,
      reason:
          'Use AppIconTone for semantic intent. Direct AppIcon colors are '
          'allowed only as tracked legacy debt.',
    );
    expect(
      _knownDebt.difference(found),
      isEmpty,
      reason: 'These files no longer violate the rule; remove them from debt.',
    );
  });

  test('detects direct color but ignores nested widget colors', () {
    expect(
      featureIconColorViolations({
        'lib/app/features/demo/presentation/demo.dart': '''
AppIcon(AppIcons.add, color: Colors.red);
''',
      }),
      {'lib/app/features/demo/presentation/demo.dart'},
    );
    expect(
      featureIconColorViolations({
        'lib/app/features/demo/presentation/demo.dart': '''
AppIcon(AppIcons.add, semanticsLabel: Text('x', style: TextStyle(color: Colors.red)));
''',
      }),
      isEmpty,
    );
  });
}
