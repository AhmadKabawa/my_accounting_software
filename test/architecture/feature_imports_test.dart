import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// A feature may import another feature **only through that feature's routes
/// file** (`features/<other>/presentation/routing/<other>_routes.dart`), so it
/// can navigate there without depending on its pages, cubits or data.
///
/// [_knownDebt] lists the imports that already crossed a feature boundary when
/// this rule was added. The list may only shrink: a new violation fails the
/// test, and so does an entry that no longer exists (remove it).
const _knownDebt = <String>{
  'lib/app/features/auth/presentation/cubit/profile/profile_cubit.dart -> lib/app/features/profile/presentation/localization/profile_keys.dart',
  'lib/app/features/home/presentation/sections/home_greeting_section.dart -> lib/app/features/auth/domain/session/session_gate.dart',
  'lib/app/features/home/presentation/sections/home_greeting_section.dart -> lib/app/features/auth/presentation/cubit/session/session_cubit.dart',
  'lib/app/features/profile/presentation/sections/profile_actions_section.dart -> lib/app/features/auth/presentation/localization/auth_keys.dart',
  'lib/app/features/profile/presentation/sections/profile_actions_section.dart -> lib/app/features/auth/presentation/cubit/session/session_cubit.dart',
  'lib/app/features/profile/presentation/sections/profile_header_section.dart -> lib/app/features/auth/domain/entity/user/user_entity.dart',
  'lib/app/features/profile/presentation/sections/profile_header_section.dart -> lib/app/features/auth/presentation/cubit/session/session_cubit.dart',
  'lib/app/features/profile/presentation/sections/profile_header_section.dart -> lib/app/features/auth/domain/session/session_gate.dart',
};

const _package = 'package:accounting_software/';
final _featureOf = RegExp(r'^lib/app/features/([^/]+)/');
final _directive = RegExp(
  r'''^\s*(?:import|export)\s+['"]([^'"]+)['"]''',
  multiLine: true,
);

String _posix(String path) => path.replaceAll(r'\', '/');

/// The project-relative path an import points at, or null for `dart:` and
/// third-party packages.
String? _resolve(String importer, String spec) {
  if (spec.startsWith('dart:')) return null;
  if (spec.startsWith('package:')) {
    return spec.startsWith(_package)
        ? 'lib/${spec.substring(_package.length)}'
        : null;
  }
  final segments = importer.split('/')..removeLast();
  for (final part in spec.split('/')) {
    if (part == '..') {
      if (segments.isNotEmpty) segments.removeLast();
    } else if (part != '.' && part.isNotEmpty) {
      segments.add(part);
    }
  }
  return segments.join('/');
}

/// `"<importer> -> <target>"` for every import that crosses a feature boundary
/// other than through the target's routes file. [sources] maps project-relative
/// paths (with `/`) to file contents.
Set<String> crossFeatureViolations(Map<String, String> sources) {
  final violations = <String>{};
  sources.forEach((importer, content) {
    final from = _featureOf.firstMatch(importer)?.group(1);
    if (from == null) return;

    for (final match in _directive.allMatches(content)) {
      final target = _resolve(importer, match.group(1)!);
      final to = target == null ? null : _featureOf.firstMatch(target)?.group(1);
      if (target == null || to == null || to == from) continue;

      final routesFile = 'lib/app/features/$to/presentation/routing/${to}_routes.dart';
      if (target != routesFile) violations.add('$importer -> $target');
    }
  });
  return violations;
}

Map<String, String> _readFeatureSources() => {
  for (final file in Directory('lib/app/features')
      .listSync(recursive: true)
      .whereType<File>()
      .where((f) => f.path.endsWith('.dart')))
    _posix(file.path): file.readAsStringSync(),
};

void main() {
  test('features import each other only through routes files', () {
    final sources = _readFeatureSources();
    expect(sources, isNotEmpty, reason: 'no feature source was found');

    final found = crossFeatureViolations(sources);

    expect(
      found.difference(_knownDebt),
      isEmpty,
      reason:
          'A feature may import another feature only through its routes file '
          '(presentation/routing/<feature>_routes.dart). Share the contract '
          'through core instead, or ask for a documented exception '
          '(docs/architecture/ARCHITECTURE_RULES.md).',
    );
    expect(
      _knownDebt.difference(found),
      isEmpty,
      reason: 'These imports no longer exist: remove them from _knownDebt.',
    );
  });

  test('the rule detects violations (self-check)', () {
    final found = crossFeatureViolations({
      'lib/app/features/a/presentation/x.dart': '''
import 'package:accounting_software/app/features/b/presentation/routing/b_routes.dart';
import 'package:accounting_software/app/features/b/presentation/pages/b_screen.dart';
import 'package:accounting_software/app/features/a/domain/thing.dart';
import '../../b/domain/thing.dart';
import 'package:flutter/material.dart';
// import 'package:accounting_software/app/features/d/data/d.dart';
export 'package:accounting_software/app/features/c/data/c_endpoints.dart';
''',
      'lib/app/other.dart': '''
import 'package:accounting_software/app/features/b/presentation/pages/b_screen.dart';
''',
    });

    expect(found, {
      'lib/app/features/a/presentation/x.dart -> lib/app/features/b/presentation/pages/b_screen.dart',
      'lib/app/features/a/presentation/x.dart -> lib/app/features/b/domain/thing.dart',
      'lib/app/features/a/presentation/x.dart -> lib/app/features/c/data/c_endpoints.dart',
    });
  });
}
