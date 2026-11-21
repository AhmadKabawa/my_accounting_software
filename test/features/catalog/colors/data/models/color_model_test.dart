import 'package:flutter_test/flutter_test.dart';
import 'package:accounting_software/app/features/catalog/colors/data/models/color_model.dart';

void main() {
  test('parses a row and maps it to the entity', () {
    final entity = ColorModel.fromJson(const {
      'id': 7,
      'name': 'Navy',
      'code': 'NAVY',
      'hex_code': '#1E3A8A',
      'is_active': false,
      'sort_order': 3,
    }).toEntity();

    expect(entity.id, 7);
    expect(entity.hexCode, '#1E3A8A');
    expect(entity.isActive, isFalse);
    expect(entity.sortOrder, 3);
  });

  test('missing optional columns fall back to defaults', () {
    final entity = ColorModel.fromJson(const {
      'id': '9',
      'name': 'Raw',
      'code': 'RAW',
    }).toEntity();

    expect(entity.id, 9);
    expect(entity.hexCode, isNull);
    expect(entity.isActive, isTrue);
    expect(entity.sortOrder, 0);
  });

  test('an invalid id is rejected', () {
    expect(
      () => ColorModel.fromJson(const {'id': 'x', 'name': 'a', 'code': 'b'}),
      throwsFormatException,
    );
  });
}
