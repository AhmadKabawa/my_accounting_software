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
      final to = target == null
          ? null
          : _featureOf.firstMatch(target)?.group(1);
      if (target == null || to == null || to == from) continue;

      final routesFile =
          'lib/app/features/$to/presentation/routing/${to}_routes.dart';
      if (target != routesFile) violations.add('$importer -> $target');
    }
  });
  return violations;
}


/// Feature screens must express icon intent with AppIconTone, not paint colors.
/// Explicit colors remain supported by AppIcon for compatibility in Core.
const _iconColorKnownDebt = <String>{};

Set<String> featureIconColorViolations(Map<String, String> sources) {
  final violations = <String>{};
  final invocation = RegExp(r'AppIcon(?:\\.fixed)?\\s*\\(');
  sources.forEach((path, content) {
    if (!path.startsWith('lib/app/features/')) return;
    final lines = content.split('\\n');
    for (var index = 0; index < lines.length; index++) {
      if (!invocation.hasMatch(lines[index])) continue;
      final window = lines.skip(index).take(24).join('\\n');
      final end = window.indexOf(')');
      final call = end < 0 ? window : window.substring(0, end + 1);
      if (RegExp(r'\\bcolor\\s*:').hasMatch(call)) {
        violations.add('$path:${index + 1}');
      }
    }
  });
  return violations;
}

Map<String, String> _readFeatureSources() => {
  for (final file
      in Directory('lib/app/features')
          .listSync(recursive: true)
          .whereType<File>()
          .where((f) => f.path.endsWith('.dart')))
    _posix(file.path): file.readAsStringSync(),
};

Set<String> coreFeatureImportViolations(Map<String, String> sources) {
  final violations = <String>{};
  sources.forEach((importer, content) {
    if (!importer.startsWith('lib/app/core/')) return;
    for (final match in _directive.allMatches(content)) {
      final target = _resolve(importer, match.group(1)!);
      if (target != null && _featureOf.hasMatch(target)) {
        violations.add('$importer -> $target');
      }
    }
  });
  return violations;
}

Map<String, String> _readCoreSources() => {
  for (final file
      in Directory('lib/app/core')
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

  test('core does not import features', () {
    final sources = _readCoreSources();
    expect(sources, isNotEmpty, reason: 'no core source was found');

    expect(
      coreFeatureImportViolations(sources),
      isEmpty,
      reason: 'Core must not import code from app/features.',
    );
  });

  test(
    'AccessStatusGate receives an optional sign-out action from outside',
    () {
      final source = File(
        'lib/app/core/access/presentation/access_status_gate.dart',
      ).readAsStringSync();

      expect(source, isNot(contains('features/auth/')));
      expect(source, contains('required this.signOutLabel'));
      expect(source, contains('if (widget.onSignOut != null)'));
      expect(source, contains('onPressed: widget.onSignOut'));
    },
  );


  test('features use semantic AppIconTone instead of direct icon colors', () {
    final sources = _readFeatureSources();
    final found = featureIconColorViolations(sources);

    expect(
      found.difference(_iconColorKnownDebt),
      isEmpty,
      reason:
          'Use AppIconTone for feature icon meaning. Direct color is retained '
          'only for compatibility and must be tracked as known debt.',
    );
    expect(
      _iconColorKnownDebt.difference(found),
      isEmpty,
      reason: 'These direct-color usages no longer exist: remove them from debt.',
    );
  });

  test('the AppIcon direct-color rule detects a violation (self-check)', () {
    expect(
      featureIconColorViolations({
        'lib/app/features/example/presentation/example_screen.dart': '''
AppIcon(AppIcons.add, color: Colors.red),
''',
      }),
      {'lib/app/features/example/presentation/example_screen.dart:1'},
    );
  });

  test('the core rule detects feature imports (self-check)', () {
    expect(
      coreFeatureImportViolations({
        'lib/app/core/example.dart': '''
import 'package:accounting_software/app/features/auth/presentation/cubit/session/session_cubit.dart';
''',
      }),
      {
        'lib/app/core/example.dart -> lib/app/features/auth/presentation/cubit/session/session_cubit.dart',
      },
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
