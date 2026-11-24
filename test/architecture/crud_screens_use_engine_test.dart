import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Legacy CRUD list pages must be migrated deliberately, never added silently.
const _exceptions = <String>{};

/// A feature's list config stays reviewable. Move widgets to `widgets/` and
/// shared behavior to the engine before exceeding it.
const _maxListConfigLines = 250;
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

Map<String, String> _readListConfigs() => {
  for (final file
      in Directory('lib/app/features')
          .listSync(recursive: true)
          .whereType<File>()
          .where(
            (file) =>
                file.path.replaceAll('\\', '/').endsWith('_list_config.dart'),
          ))
    file.path.replaceAll('\\', '/'): file.readAsStringSync(),
};

Set<String> listConfigSizeViolations(
  Map<String, String> sources, {
  int max = _maxListConfigLines,
}) => {
  for (final entry in sources.entries)
    if (const LineSplitter().convert(entry.value).length > max) entry.key,
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

  test('every *_list_config.dart stays within $_maxListConfigLines lines', () {
    final sources = _readListConfigs();
    expect(sources, isNotEmpty, reason: 'No list config sources were found.');

    final violations = listConfigSizeViolations(sources);
    expect(
      violations,
      isEmpty,
      reason:
          'ملف إعداد قائمة CRUD تجاوز $_maxListConfigLines سطراً؛ انقل '
              'الودجتات إلى widgets/ والسلوك المشترك إلى الماكينة. انظر '
              'docs/ui/new_crud_feature_recipe.md.\n' +
          violations.join('\n'),
    );
  });

  test('the size gate flags an oversized config (self-check)', () {
    final oversized = List.filled(251, 'x').join('\n');
    expect(
      listConfigSizeViolations({
        'lib/app/features/demo/presentation/demo_list_config.dart': oversized,
        'lib/app/features/demo/presentation/small_list_config.dart': 'x',
      }),
      {'lib/app/features/demo/presentation/demo_list_config.dart'},
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
