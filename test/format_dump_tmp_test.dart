import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('temporary formatter dump', () async {
    final result = await Process.run('dart', [
      'format',
      '--output=show',
      'test/features/catalog/brands/presentation/sections/brands_table_section_test.dart',
    ]);
    print('FORMATTED_TABLE_START');
    print(result.stdout);
    print('FORMATTED_TABLE_END');
    expect(result.exitCode, 0);
  });
}
