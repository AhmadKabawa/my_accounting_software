import 'package:flutter_test/flutter_test.dart';
import 'package:accounting_software/app/core/foundation/validation/hex_color.dart';
import 'package:accounting_software/app/features/catalog/colors/presentation/widgets/color_presets.dart';

void main() {
  test('catalog palette contains 24 valid HEX colors', () {
    expect(ColorPresets.hexes, hasLength(24));
    expect(ColorPresets.hexes.every(HexColor.isValid), isTrue);
  });
}
