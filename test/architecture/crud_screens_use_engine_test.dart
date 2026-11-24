import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Legacy CRUD list pages must be migrated deliberately, never added silently.
const _exceptions = <String>{};
final _listPageTemplate = RegExp(r'\bListPageTemplate(?:<[^>]+>)?\s*\(');
final _crudListScreen = RegExp(r'\bCrudListScreen(?:<[^>]+>)?\s*\(');

Map<String, String> _readFeaturePages() => {
  for (final file
      in Directory(
        'lib/app/features',
      ).listSync(recursive: true).whereType<File>().where((file) {
        final path = file.path.replaceAll('\\', '/');
        return path.contains('/pages/') &&
            path.endsWith('.dart') &&
            !path.endsWith('.freezed.dart') &&
            !path.endsWith('.g.dart');
      }))
    file.path.replaceAll('\\', '/'): file.readAsStringSync(),
};

Set<String> crudScreenEngineViolations(Map<String, String> sources) {
  final violations = <String>{};
  sources.forEach((path, source) {
    if (!_listPageTemplate.hasMatch(source) ||
        _crudListScreen.hasMatch(source) ||
        _exceptions.contains(path)) {
      return;
    }
    violations.add(path);
  });
  return violations;
}

void main() {
  test('CRUD pages use CrudListScreen or an explicit legacy exception', () {
    final sources = _readFeaturePages();
    expect(sources, isNotEmpty, reason: 'No feature page sources were found.');

    final violations = crudScreenEngineViolations(sources);
    expect(
      violations,
      isEmpty,
      reason:
          'شاشة CRUD جديدة تُبنى بـ CrudListScreen؛ انظر '
              'docs/ui/new_crud_feature_recipe.md.\n' +
          violations.join('\n'),
    );
  });

  test(
    'the gate rejects direct ListPageTemplate construction (self-check)',
    () {
      expect(
        crudScreenEngineViolations({
          'lib/app/features/demo/presentation/pages/demo_screen.dart':
              'return ListPageTemplate(titleKey: DemoKeys.title);',
        }),
        {'lib/app/features/demo/presentation/pages/demo_screen.dart'},
      );
    },
  );

  test('the gate accepts a page delegated to CrudListScreen (self-check)', () {
    expect(
      crudScreenEngineViolations({
        'lib/app/features/demo/presentation/pages/demo_screen.dart':
            'return CrudListScreen(config: demoConfig);',
      }),
      isEmpty,
    );
  });
}
